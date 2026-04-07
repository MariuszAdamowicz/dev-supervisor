@testable import DevSupervisor
import XCTest

final class IdeaRegistryPersistentFileSystemTests: XCTestCase {
    func testIdeaRegistry_persistsIdeasAndSelectionAcrossInstances() throws {
        let root = try makeTemporaryDirectory()

        let first = IdeaRegistryPersistentFileSystem(storageProfile: .fileAI, storageRootPath: root.path)
        let alpha = ProjectID(rawValue: "P-1")
        first.selectActiveProject(id: alpha)

        let creation = first.createIdea(title: "Offline mode", description: "Support offline workflow")
        let ideaID = try XCTUnwrap(creation.createdIdeaID)
        XCTAssertTrue(first.changeIdeaStatus(id: ideaID, status: .selected).isSuccess)

        let second = IdeaRegistryPersistentFileSystem(storageProfile: .fileAI, storageRootPath: root.path)
        second.selectActiveProject(id: alpha)

        let list = second.listIdeasForActiveProject()
        XCTAssertTrue(list.result.isSuccess)
        XCTAssertEqual(list.ideas.count, 1)
        XCTAssertEqual(list.ideas.first?.title, "Offline mode")
        XCTAssertEqual(list.ideas.first?.status, .selected)
    }

    func testIdeaRegistry_persistsIndependentlyForFileAIAndSQLBaseProfiles() throws {
        let root = try makeTemporaryDirectory()
        let alpha = ProjectID(rawValue: "P-1")

        let fileAIRegistry = IdeaRegistryPersistentFileSystem(storageProfile: .fileAI, storageRootPath: root.path)
        fileAIRegistry.selectActiveProject(id: alpha)
        _ = fileAIRegistry.createIdea(title: "Alpha idea", description: nil)

        let sqlbaseRegistry = IdeaRegistryPersistentFileSystem(storageProfile: .sqlbase, storageRootPath: root.path)
        sqlbaseRegistry.selectActiveProject(id: alpha)
        _ = sqlbaseRegistry.createIdea(title: "Beta idea", description: nil)

        let reloadedFileAI = IdeaRegistryPersistentFileSystem(storageProfile: .fileAI, storageRootPath: root.path)
        reloadedFileAI.selectActiveProject(id: alpha)

        let reloadedSQLBase = IdeaRegistryPersistentFileSystem(storageProfile: .sqlbase, storageRootPath: root.path)
        reloadedSQLBase.selectActiveProject(id: alpha)

        XCTAssertEqual(reloadedFileAI.listIdeasForActiveProject().ideas.map(\.title), ["Alpha idea"])
        XCTAssertEqual(reloadedSQLBase.listIdeasForActiveProject().ideas.map(\.title), ["Beta idea"])
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent("registry-sqlbase.sqlite3").path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: root.appendingPathComponent("idea-registry-sqlbase.json").path))
    }

    func testIdeaRegistry_sqlbaseImportsLegacyJSONSnapshotIntoSQLite() throws {
        let root = try makeTemporaryDirectory()
        let legacyJSON = """
        {
          "selectedProjectID" : "P-1",
          "nextIdeaNumber" : 3,
          "ideas" : [
            {
              "description" : "Imported from legacy json",
              "id" : "I-2",
              "projectID" : "P-1",
              "status" : "selected",
              "title" : "Legacy idea"
            }
          ]
        }
        """
        try legacyJSON.write(
            to: root.appendingPathComponent("idea-registry-sqlbase.json"),
            atomically: true,
            encoding: .utf8
        )

        let registry = IdeaRegistryPersistentFileSystem(storageProfile: .sqlbase, storageRootPath: root.path)
        registry.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let list = registry.listIdeasForActiveProject()
        XCTAssertTrue(list.result.isSuccess)
        XCTAssertEqual(list.ideas.map(\.title), ["Legacy idea"])
        XCTAssertEqual(list.ideas.first?.status, .selected)
        XCTAssertTrue(FileManager.default.fileExists(atPath: root.appendingPathComponent("registry-sqlbase.sqlite3").path))
    }
}

private extension IdeaRegistryPersistentFileSystemTests {
    func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
