@testable import DevSupervisor
import XCTest

final class ArtifactSyncFileSystemTests: XCTestCase {
    func testSynchronize_exportAIToSQLBase_copiesMappedFiles() throws {
        let sut = ArtifactSyncFileSystem()
        let projectRoot = try makeProjectRoot()

        let result = sut.synchronize(
            ArtifactSyncRequest(
                projectPath: projectRoot.path,
                storageProfile: .sqlbase,
                direction: .exportAIToSQLBase
            )
        )

        XCTAssertTrue(result.result.isSuccess)
        let store = SQLProjectStore()
        XCTAssertNotNil(try store.artifactContent(relativePath: ".ai/prd/overview.md", projectRoot: projectRoot))
        XCTAssertNotNil(try store.artifactContent(relativePath: ".ai/prd/constraints.md", projectRoot: projectRoot))
        XCTAssertNotNil(try store.artifactContent(relativePath: ".ai/prd/glossary.md", projectRoot: projectRoot))
    }

    func testSynchronize_importSQLBaseToAI_restoresAIDocumentsFromState() throws {
        let sut = ArtifactSyncFileSystem()
        let projectRoot = try makeProjectRoot()

        _ = sut.synchronize(
            ArtifactSyncRequest(
                projectPath: projectRoot.path,
                storageProfile: .sqlbase,
                direction: .exportAIToSQLBase
            )
        )

        try FileManager.default.removeItem(at: projectRoot.appendingPathComponent(".ai/prd/glossary.md"))

        let result = sut.synchronize(
            ArtifactSyncRequest(
                projectPath: projectRoot.path,
                storageProfile: .sqlbase,
                direction: .importSQLBaseToAI
            )
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectRoot.appendingPathComponent(".ai/prd/glossary.md").path))
    }

    func testSynchronize_importSQLBaseToAI_importsLegacyStateArtifactsIntoDatabase() throws {
        let sut = ArtifactSyncFileSystem()
        let projectRoot = try makeProjectRoot()
        let legacyOverview = projectRoot.appendingPathComponent("State/sqlbase/prd/overview.md")
        try FileManager.default.createDirectory(at: legacyOverview.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "Legacy overview".write(to: legacyOverview, atomically: true, encoding: .utf8)
        try FileManager.default.createDirectory(
            at: projectRoot.appendingPathComponent("State/sqlbase/prd"),
            withIntermediateDirectories: true
        )
        try "Legacy constraints".write(
            to: projectRoot.appendingPathComponent("State/sqlbase/prd/constraints.md"),
            atomically: true,
            encoding: .utf8
        )
        try "Legacy glossary".write(
            to: projectRoot.appendingPathComponent("State/sqlbase/prd/glossary.md"),
            atomically: true,
            encoding: .utf8
        )
        try "[]".write(
            to: projectRoot.appendingPathComponent("State/sqlbase/ideas.md"),
            atomically: true,
            encoding: .utf8
        )
        try "{}".write(
            to: projectRoot.appendingPathComponent("State/sqlbase/project-profile.json"),
            atomically: true,
            encoding: .utf8
        )
        try FileManager.default.removeItem(at: projectRoot.appendingPathComponent("State/supervisor.sqlite3"))
        try FileManager.default.removeItem(at: projectRoot.appendingPathComponent(".ai/prd/overview.md"))

        let result = sut.synchronize(
            ArtifactSyncRequest(
                projectPath: projectRoot.path,
                storageProfile: .sqlbase,
                direction: .importSQLBaseToAI
            )
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertEqual(
            try String(contentsOf: projectRoot.appendingPathComponent(".ai/prd/overview.md"), encoding: .utf8),
            "Legacy overview"
        )
    }

    func testSynchronize_withNonSQLBaseProfile_returnsFailure() throws {
        let sut = ArtifactSyncFileSystem()
        let projectRoot = try makeProjectRoot()

        let result = sut.synchronize(
            ArtifactSyncRequest(
                projectPath: projectRoot.path,
                storageProfile: .fileAI,
                direction: .exportAIToSQLBase
            )
        )

        guard case let .failure(reason) = result.result else {
            XCTFail("Expected explicit failure")
            return
        }

        XCTAssertTrue(reason.message.contains("sqlbase"))
    }
}

private extension ArtifactSyncFileSystemTests {
    func makeProjectRoot() throws -> URL {
        let bootstrap = ProjectBootstrapFileSystem()
        let root = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

        let result = bootstrap.bootstrapProject(
            ProjectBootstrapInput(
                projectName: "Sync Demo",
                projectsRootPath: root.path,
                storageProfile: .sqlbase,
                initializeGitRepository: false
            )
        )

        let path = try XCTUnwrap(result.projectPath)
        return URL(fileURLWithPath: path)
    }
}
