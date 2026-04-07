@testable import DevSupervisor
import XCTest

final class GatePromptPersistenceFileSystemTests: XCTestCase {
    func testPersistPrompt_forFileAI_writesUnderAIGatesDirectory() throws {
        let sut = GatePromptPersistenceFileSystem()
        let projectRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: projectRoot, withIntermediateDirectories: true)

        let request = GatePromptPersistenceRequest(
            projectPath: projectRoot.path,
            storageProfile: .fileAI,
            operation: "FEATURES -> PRD",
            ideaID: IdeaID(rawValue: "I-1"),
            projectID: ProjectID(rawValue: "P-1"),
            promptText: "Prompt"
        )

        let result = sut.persistPrompt(request)

        XCTAssertTrue(result.result.isSuccess)
        let path = try XCTUnwrap(result.persistedPath)
        XCTAssertTrue(path.contains("/.ai/gates/features-prd/"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))
    }

    func testPersistPrompt_forSQLBase_writesUnderStateGatesDirectory() throws {
        let sut = GatePromptPersistenceFileSystem()
        let projectRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: projectRoot, withIntermediateDirectories: true)

        let request = GatePromptPersistenceRequest(
            projectPath: projectRoot.path,
            storageProfile: .sqlbase,
            operation: "PRD -> BDD",
            ideaID: IdeaID(rawValue: "I-1"),
            projectID: ProjectID(rawValue: "P-1"),
            promptText: "Prompt"
        )

        let result = sut.persistPrompt(request)

        XCTAssertTrue(result.result.isSuccess)
        let path = try XCTUnwrap(result.persistedPath)
        XCTAssertTrue(path.contains("/State/supervisor.sqlite3#gates/prd-bdd/"))
        let store = SQLProjectStore()
        XCTAssertEqual(try store.gatePromptCount(projectRoot: projectRoot), 1)
        XCTAssertTrue(try (store.gatePromptPayload(logicalPath: path, projectRoot: projectRoot))?.contains("Prompt") == true)
    }

    func testPersistPrompt_withEmptyPrompt_returnsExplicitFailure() throws {
        let sut = GatePromptPersistenceFileSystem()
        let projectRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: projectRoot, withIntermediateDirectories: true)

        let request = GatePromptPersistenceRequest(
            projectPath: projectRoot.path,
            storageProfile: .fileAI,
            operation: "IDEA -> FEATURES",
            ideaID: IdeaID(rawValue: "I-1"),
            projectID: ProjectID(rawValue: "P-1"),
            promptText: " "
        )

        let result = sut.persistPrompt(request)

        guard case let .failure(reason) = result.result else {
            XCTFail("Expected failure")
            return
        }
        XCTAssertFalse(reason.message.isEmpty)
        XCTAssertNil(result.persistedPath)
    }

    func testPersistPrompt_forSQLBase_importsLegacyGateDirectoryBeforeWritingNewPrompt() throws {
        let sut = GatePromptPersistenceFileSystem()
        let projectRoot = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        let legacyDirectory = projectRoot.appendingPathComponent("State/gates/prd-bdd")
        try FileManager.default.createDirectory(at: legacyDirectory, withIntermediateDirectories: true)
        try """
        operation: PRD -> BDD
        project_id: P-1
        idea_id: I-1
        storage: sqlbase
        ---
        Legacy prompt
        """.write(
            to: legacyDirectory.appendingPathComponent("20260407-100000_P-1_I-1.md"),
            atomically: true,
            encoding: .utf8
        )

        let request = GatePromptPersistenceRequest(
            projectPath: projectRoot.path,
            storageProfile: .sqlbase,
            operation: "PRD -> BDD",
            ideaID: IdeaID(rawValue: "I-2"),
            projectID: ProjectID(rawValue: "P-1"),
            promptText: "Current prompt"
        )

        let result = sut.persistPrompt(request)

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertEqual(try SQLProjectStore().gatePromptCount(projectRoot: projectRoot), 2)
    }
}
