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
        let beta = try XCTUnwrap(sqlbaseRegistry.registerProject(name: "Beta", localPath: "/tmp/beta").createdProjectID)
        sqlbaseRegistry.seedScopedData(
            for: beta,
            data: ProjectScopedData(
                ideas: ["Idea beta"],
                features: ["Feature beta"],
                progress: ["Started"],
                metadata: ["owner": "sqlbase"]
            )
        )
        sqlbaseRegistry.setPathAvailability(for: beta, isAvailable: false)

        let reloadedFileAI = ProjectRegistryPersistentFileSystem(storageProfile: .fileAI, storageRootPath: root.path)
        let reloadedSQLBase = ProjectRegistryPersistentFileSystem(storageProfile: .sqlbase, storageRootPath: root.path)

        XCTAssertEqual(reloadedFileAI.listProjects().map(\.name), ["Alpha"])
        XCTAssertEqual(reloadedSQLBase.listProjects().map(\.name), ["Beta"])
        XCTAssertEqual(reloadedSQLBase.scopedData(for: beta)?.metadata["owner"], "sqlbase")
        XCTAssertFalse(reloadedSQLBase.performPathRequiredOperation(for: beta).isSuccess)
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent("registry-sqlbase.sqlite3").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("project-registry-sqlbase.json").path))
    }

    func testRegistry_sqlbaseImportsLegacyJSONSnapshotIntoSQLite() throws {
        let root = try makeTemporaryDirectory()
        let legacyJSON = """
        {
          "activeProjectID" : "P-3",
          "nextProjectNumber" : 4,
          "projects" : [
            {
              "id" : "P-3",
              "localPath" : "/tmp/legacy",
              "name" : "Legacy",
              "pathAvailable" : false,
              "history" : [],
              "status" : "active"
            }
          ],
          "scopedData" : [
            {
              "features" : ["Migration"],
              "id" : "P-3",
              "ideas" : ["Legacy idea"],
              "metadata" : {"source":"json"},
              "progress" : ["Imported"]
            }
          ]
        }
        """
        try legacyJSON.write(
            to: root.appendingPathComponent("project-registry-sqlbase.json"),
            atomically: true,
            encoding: .utf8
        )

        let registry = ProjectRegistryPersistentFileSystem(storageProfile: .sqlbase, storageRootPath: root.path)

        XCTAssertEqual(registry.listProjects().map(\.name), ["Legacy"])
        XCTAssertEqual(registry.activeWorkingProjectID()?.rawValue, "P-3")
        XCTAssertFalse(registry.performPathRequiredOperation(for: ProjectID(rawValue: "P-3")).isSuccess)
        XCTAssertEqual(registry.scopedData(for: ProjectID(rawValue: "P-3"))?.metadata["source"], "json")
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent("registry-sqlbase.sqlite3").path))
    }
}

private extension ProjectRegistryPersistentFileSystemTests {
    func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
