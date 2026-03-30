@testable import DevSupervisor
import XCTest

final class ProjectBootstrapFileSystemTests: XCTestCase {
    func testBootstrapProject_createsExpectedAIFilesAndScripts() throws {
        let sut = ProjectBootstrapFileSystem()
        let root = try makeTemporaryDirectory()

        let result = sut.bootstrapProject(
            ProjectBootstrapInput(
                projectName: "Demo Supervisor",
                projectsRootPath: root.path,
                storageProfile: .fileAI,
                initializeGitRepository: false
            )
        )

        XCTAssertTrue(result.result.isSuccess)
        let projectPath = try XCTUnwrap(result.projectPath)

        XCTAssertTrue(FileManager.default.fileExists(atPath: "\(projectPath)/.ai/prd/overview.md"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: "\(projectPath)/.ai/prd/constraints.md"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: "\(projectPath)/.ai/prd/glossary.md"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: "\(projectPath)/Scripts/build.sh"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: "\(projectPath)/.ai/project-profile.json"))
    }

    func testBootstrapProject_forExistingNonEmptyDirectory_returnsExplicitFailure() throws {
        let sut = ProjectBootstrapFileSystem()
        let root = try makeTemporaryDirectory()
        let existing = root.appendingPathComponent("demo-supervisor")

        try FileManager.default.createDirectory(at: existing, withIntermediateDirectories: true)
        try "occupied".write(to: existing.appendingPathComponent("README.md"), atomically: true, encoding: .utf8)

        let result = sut.bootstrapProject(
            ProjectBootstrapInput(
                projectName: "Demo Supervisor",
                projectsRootPath: root.path,
                storageProfile: .fileAI,
                initializeGitRepository: false
            )
        )

        guard case let .failure(reason) = result.result else {
            XCTFail("Expected explicit failure")
            return
        }

        XCTAssertFalse(reason.message.isEmpty)
    }

    func testInspectProject_detectsStorageProfileAndCoreFolders() throws {
        let sut = ProjectBootstrapFileSystem()
        let root = try makeTemporaryDirectory()

        let bootstrap = sut.bootstrapProject(
            ProjectBootstrapInput(
                projectName: "Demo Supervisor",
                projectsRootPath: root.path,
                storageProfile: .sqlbase,
                initializeGitRepository: false
            )
        )

        let projectPath = try XCTUnwrap(bootstrap.projectPath)
        let inspection = sut.inspectProject(at: projectPath)

        XCTAssertTrue(inspection.result.isSuccess)
        XCTAssertTrue(inspection.hasAI)
        XCTAssertTrue(inspection.hasScripts)
        XCTAssertEqual(inspection.detectedStorageProfile, .sqlbase)
    }
}

private extension ProjectBootstrapFileSystemTests {
    func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
