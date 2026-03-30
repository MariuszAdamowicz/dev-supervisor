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
        XCTAssertTrue(path.contains("/State/gates/prd-bdd/"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: path))
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
}
