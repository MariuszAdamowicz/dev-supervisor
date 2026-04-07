@testable import DevSupervisor
import XCTest

final class PlaybookRuntimeFileSystemTests: XCTestCase {
    func testRunNewProject_createsBaselineProjectRuntimeAndGitRemote() throws {
        let root = try makeTemporaryDirectory()
        let projectURL = root.appendingPathComponent("starter-ds")
        let github = StubGitHubClient(remoteURL: "git@github.com:test/starter-ds.git")
        let sut = PlaybookRuntimeFileSystem(
            gitClient: StubGitClient(),
            githubClient: github,
            now: { Date(timeIntervalSince1970: 0) }
        )

        let result = sut.runNewProject(
            PlaybookNewProjectRequest(
                projectName: "Starter DS",
                projectRootPath: projectURL.path,
                projectDescription: "DevSupervisor uruchamia projekt i baseline z audytem.",
                baselineGate: PlaybookGateInput(
                    decision: .approve,
                    reason: "baseline kompletny"
                ),
                createRemoteRepository: true
            )
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertEqual(result.projectState, "active")
        XCTAssertEqual(result.remoteURL, "git@github.com:test/starter-ds.git")
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent(".ai/prd/overview.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent(".ai/prd/constraints.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent(".ai/prd/glossary.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent(".ai/runtime/v1/ops/project.ds/versions/000001.json").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent(".ai/runtime/v1/ops/project.ds/gates.ndjson").path))
        XCTAssertEqual(
            try String(
                contentsOf: projectURL.appendingPathComponent(".git/origin-url"),
                encoding: .utf8
            ).trimmingCharacters(in: .whitespacesAndNewlines),
            "git@github.com:test/starter-ds.git"
        )

        let summary = sut.summarizeRuntime(at: projectURL.path)
        XCTAssertEqual(summary.projectState, "active")
        XCTAssertEqual(summary.remoteURL, "git@github.com:test/starter-ds.git")
        XCTAssertEqual(summary.processEventCount, 8)
        XCTAssertEqual(summary.gateDecisionCount, 1)
    }

    func testAddIdea_createsDerivedOpsFeatureArtifactsAndAuditTrail() throws {
        let root = try makeTemporaryDirectory()
        let projectURL = root.appendingPathComponent("starter-ds")
        let sut = PlaybookRuntimeFileSystem(
            gitClient: StubGitClient(),
            githubClient: StubGitHubClient(remoteURL: "git@github.com:test/starter-ds.git"),
            now: { Date(timeIntervalSince1970: 0) }
        )

        _ = sut.runNewProject(
            PlaybookNewProjectRequest(
                projectName: "Starter DS",
                projectRootPath: projectURL.path,
                projectDescription: "DevSupervisor uruchamia projekt i baseline z audytem.",
                baselineGate: PlaybookGateInput(
                    decision: .approve,
                    reason: "baseline kompletny"
                ),
                createRemoteRepository: false
            )
        )

        let result = sut.addIdea(
            PlaybookAddIdeaRequest(
                projectRootPath: projectURL.path,
                ideaTitle: "Uruchomienie projektu z UI",
                ideaDescription: "Operator ma dostac baseline, OP i audyt w jednym flow.",
                convertGate: PlaybookGateInput(
                    decision: .approve,
                    reason: "idea gotowa"
                )
            )
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertEqual(result.ideaState, "converted")
        XCTAssertEqual(Set(result.derivedOps.map(\.opType)), Set(["Feature", "Requirement", "Term", "PromptTask"]))
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: projectURL.appendingPathComponent(".ai/features/uruchomienie-projektu-z-ui/prd.md").path
            )
        )
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: projectURL.appendingPathComponent(".ai/features/uruchomienie-projektu-z-ui/traceability.md").path
            )
        )

        let summary = sut.summarizeRuntime(at: projectURL.path)
        XCTAssertEqual(summary.projectState, "active")
        XCTAssertEqual(summary.processEventCount, 18)
        XCTAssertEqual(summary.gateDecisionCount, 2)
        XCTAssertTrue(summary.allOps.contains(where: { $0.opType == "Idea" && $0.state == "converted" }))
        XCTAssertTrue(summary.allOps.contains(where: { $0.opType == "Feature" && $0.state == "drafted" }))
    }

    func testRunNewProject_withRequestChangesKeepsProjectConfiguredAndBlocksAddIdea() throws {
        let root = try makeTemporaryDirectory()
        let projectURL = root.appendingPathComponent("starter-ds")
        let sut = PlaybookRuntimeFileSystem(
            gitClient: StubGitClient(),
            githubClient: StubGitHubClient(remoteURL: "git@github.com:test/starter-ds.git"),
            now: { Date(timeIntervalSince1970: 0) }
        )

        let result = sut.runNewProject(
            PlaybookNewProjectRequest(
                projectName: "Starter DS",
                projectRootPath: projectURL.path,
                projectDescription: "DevSupervisor uruchamia projekt i baseline z audytem.",
                baselineGate: PlaybookGateInput(
                    decision: .requestChanges,
                    reason: "potrzebna korekta baseline"
                ),
                createRemoteRepository: false
            )
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertEqual(result.projectState, "configured")

        let summary = sut.summarizeRuntime(at: projectURL.path)
        XCTAssertEqual(summary.projectState, "configured")
        XCTAssertEqual(summary.processEventCount, 6)
        XCTAssertEqual(summary.gateDecisionCount, 1)

        let addIdea = sut.addIdea(
            PlaybookAddIdeaRequest(
                projectRootPath: projectURL.path,
                ideaTitle: "Blocked idea",
                ideaDescription: "Nie powinna przejsc bez aktywnego projektu.",
                convertGate: PlaybookGateInput(
                    decision: .approve,
                    reason: "n/a"
                )
            )
        )

        guard case let .failure(reason) = addIdea.result else {
            XCTFail("Expected explicit failure")
            return
        }

        XCTAssertEqual(reason.message, "Project must be active before adding an idea.")
    }
}

private extension PlaybookRuntimeFileSystemTests {
    func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}

private struct StubGitHubClient: PlaybookGitHubClient {
    let remoteURL: String

    func ensureRepository(named _: String, visibility _: String, defaultBranch _: String) throws -> String {
        remoteURL
    }
}

private struct StubGitClient: PlaybookGitClient {
    func initializeRepository(at path: String) throws {
        let gitURL = URL(fileURLWithPath: path).appendingPathComponent(".git")
        try FileManager.default.createDirectory(at: gitURL, withIntermediateDirectories: true)
    }

    func addRemoteOrigin(at path: String, remoteURL: String) throws {
        let remoteFile = URL(fileURLWithPath: path).appendingPathComponent(".git/origin-url")
        try remoteURL.write(to: remoteFile, atomically: true, encoding: .utf8)
    }
}
