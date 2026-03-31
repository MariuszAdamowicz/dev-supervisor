@testable import DevSupervisor
import XCTest

final class ProjectRegistryPersistentFileSystemTests: XCTestCase {
    func testRegistry_persistsProjectsAndActiveProjectAcrossInstances() throws {
        let root = try makeTemporaryDirectory()
        let first = ProjectRegistryPersistentFileSystem(storageProfile: .fileAI, storageRootPath: root.path)

        let registration = first.registerProject(name: "Alpha", localPath: "/tmp/alpha")
        guard let createdID = registration.createdProjectID else {
            XCTFail("Expected created project ID")
            return
        }

        XCTAssertTrue(first.selectActiveWorkingProject(id: createdID).isSuccess)

        let second = ProjectRegistryPersistentFileSystem(storageProfile: .fileAI, storageRootPath: root.path)

        XCTAssertEqual(second.listProjects().count, 1)
        XCTAssertEqual(second.listProjects().first?.name, "Alpha")
        XCTAssertEqual(second.activeWorkingProjectID()?.rawValue, "P-1")
    }

    func testRegistry_persistsIndependentlyForFileAIAndSQLBaseProfiles() throws {
        let root = try makeTemporaryDirectory()

        let fileAIRegistry = ProjectRegistryPersistentFileSystem(storageProfile: .fileAI, storageRootPath: root.path)
        _ = fileAIRegistry.registerProject(name: "Alpha", localPath: "/tmp/alpha")

        let sqlbaseRegistry = ProjectRegistryPersistentFileSystem(storageProfile: .sqlbase, storageRootPath: root.path)
        _ = sqlbaseRegistry.registerProject(name: "Beta", localPath: "/tmp/beta")

        let reloadedFileAI = ProjectRegistryPersistentFileSystem(storageProfile: .fileAI, storageRootPath: root.path)
        let reloadedSQLBase = ProjectRegistryPersistentFileSystem(storageProfile: .sqlbase, storageRootPath: root.path)

        XCTAssertEqual(reloadedFileAI.listProjects().map(\.name), ["Alpha"])
        XCTAssertEqual(reloadedSQLBase.listProjects().map(\.name), ["Beta"])
    }
}

private extension ProjectRegistryPersistentFileSystemTests {
    func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
