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
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent(".ai/adr/0001-project-baseline.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent(".ai/architecture/use-cases.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent(".ai/architecture/port-contracts.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent(".ai/architecture/component-map.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent(".ai/ux/new-project.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent(".ai/runtime/v1/op-index.json").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent(".ai/runtime/v1/evidence.ndjson").path))
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
        XCTAssertTrue(summary.baselineArtifacts.allSatisfy { $0.exists })
        XCTAssertTrue(summary.allOps.contains(where: { $0.opType == "ActorRolePermission" && $0.state == "active" }))
        XCTAssertTrue(summary.allOps.contains(where: { $0.opType == "UseCase" }))
        XCTAssertTrue(summary.allOps.contains(where: { $0.opType == "PortContract" }))
        XCTAssertTrue(summary.allOps.contains(where: { $0.opType == "Component" }))
        XCTAssertGreaterThanOrEqual(summary.processEventCount, 12)
        XCTAssertEqual(summary.gateDecisionCount, 1)
        XCTAssertEqual(summary.evidenceCount, 1)
        XCTAssertEqual(summary.lastEvidenceClass, "runtime-capture")
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
        XCTAssertTrue(
            FileManager.default.fileExists(
                atPath: projectURL.appendingPathComponent(".ai/ux/add-idea.md").path
            )
        )

        let summary = sut.summarizeRuntime(at: projectURL.path)
        XCTAssertEqual(summary.projectState, "active")
        XCTAssertGreaterThanOrEqual(summary.processEventCount, 24)
        XCTAssertEqual(summary.gateDecisionCount, 2)
        XCTAssertEqual(summary.evidenceCount, 2)
        XCTAssertEqual(summary.lastEvidenceClass, "runtime-capture")
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
        XCTAssertGreaterThanOrEqual(summary.processEventCount, 10)
        XCTAssertEqual(summary.gateDecisionCount, 1)
        XCTAssertEqual(summary.evidenceCount, 1)
        XCTAssertEqual(summary.lastEvidenceClass, "runtime-capture")

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

    func testRunNewProject_sqlbasePersistsRuntimeToSQLite() throws {
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
                profileSelection: PlaybookProfileSelection(storage: .sqlbase),
                projectDescription: "DevSupervisor uruchamia projekt i baseline z audytem.",
                baselineGate: PlaybookGateInput(
                    decision: .approve,
                    reason: "baseline kompletny"
                ),
                createRemoteRepository: false
            )
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectURL.appendingPathComponent("State/supervisor.sqlite3").path))

        let stats = try SQLRuntimeStore().stats(projectRoot: projectURL)
        XCTAssertEqual(stats.opCount, 8)
        XCTAssertEqual(stats.gateDecisionCount, 1)
        XCTAssertEqual(stats.evidenceCount, 1)
        XCTAssertGreaterThanOrEqual(stats.processEventCount, 12)
        XCTAssertGreaterThanOrEqual(stats.relationCount, 8)
        XCTAssertNotNil(try SQLProjectStore().artifactContent(relativePath: ".ai/prd/overview.md", projectRoot: projectURL))
        XCTAssertNotNil(try SQLProjectStore().artifactContent(relativePath: ".ai/runtime/v1/playbook-instance.json", projectRoot: projectURL))
    }

    func testAddIdea_sqlbaseReadsRuntimeSummaryFromDatabase() throws {
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
                profileSelection: PlaybookProfileSelection(storage: .sqlbase),
                projectDescription: "DevSupervisor uruchamia projekt i baseline z audytem.",
                baselineGate: PlaybookGateInput(
                    decision: .approve,
                    reason: "baseline kompletny"
                ),
                createRemoteRepository: false
            )
        )

        let addIdea = sut.addIdea(
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

        XCTAssertTrue(addIdea.result.isSuccess)
        try FileManager.default.removeItem(at: projectURL.appendingPathComponent(".ai/runtime/v1/process-events.ndjson"))
        try FileManager.default.removeItem(at: projectURL.appendingPathComponent(".ai/runtime/v1/gate-decisions.ndjson"))
        try FileManager.default.removeItem(at: projectURL.appendingPathComponent(".ai/runtime/v1/evidence.ndjson"))
        try FileManager.default.removeItem(at: projectURL.appendingPathComponent(".ai/runtime/v1/ops"))

        let summary = sut.summarizeRuntime(at: projectURL.path)
        XCTAssertEqual(summary.projectState, "active")
        XCTAssertEqual(summary.gateDecisionCount, 2)
        XCTAssertEqual(summary.evidenceCount, 2)
        XCTAssertGreaterThanOrEqual(summary.processEventCount, 24)
        XCTAssertTrue(summary.allOps.contains(where: { $0.opType == "Idea" && $0.state == "converted" }))

        let stats = try SQLRuntimeStore().stats(projectRoot: projectURL)
        XCTAssertEqual(stats.gateDecisionCount, 2)
        XCTAssertEqual(stats.evidenceCount, 2)
        XCTAssertNotNil(
            try SQLProjectStore().artifactContent(
                relativePath: ".ai/features/uruchomienie-projektu-z-ui/prd.md",
                projectRoot: projectURL
            )
        )
        XCTAssertNotNil(try SQLProjectStore().artifactContent(relativePath: ".ai/ux/add-idea.md", projectRoot: projectURL))
    }

    func testSummarizeRuntime_sqlbaseImportsExistingFileAIRuntime() throws {
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

        try rewriteStorageProfile(to: .sqlbase, projectURL: projectURL)
        let summary = sut.summarizeRuntime(at: projectURL.path)

        XCTAssertEqual(summary.projectState, "active")
        XCTAssertTrue(summary.allOps.contains(where: { $0.opType == "Project" && $0.state == "active" }))

        let stats = try SQLRuntimeStore().stats(projectRoot: projectURL)
        XCTAssertEqual(stats.opCount, 8)
        XCTAssertEqual(stats.gateDecisionCount, 1)
        XCTAssertEqual(stats.evidenceCount, 1)
    }
}

private extension PlaybookRuntimeFileSystemTests {
    func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    func rewriteStorageProfile(to profile: StorageProfile, projectURL: URL) throws {
        let profileURL = projectURL.appendingPathComponent(".ai/project-profile.json")
        let data = try Data(contentsOf: profileURL)
        let rawObject = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        var object = rawObject
        object["storage"] = profile.rawValue
        let updatedData = try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        try updatedData.write(to: profileURL, options: .atomic)
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
