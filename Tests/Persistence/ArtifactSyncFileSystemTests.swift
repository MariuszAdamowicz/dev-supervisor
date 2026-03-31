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
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectRoot.appendingPathComponent("State/sqlbase/prd/overview.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectRoot.appendingPathComponent("State/sqlbase/prd/constraints.md").path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: projectRoot.appendingPathComponent("State/sqlbase/prd/glossary.md").path))
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
