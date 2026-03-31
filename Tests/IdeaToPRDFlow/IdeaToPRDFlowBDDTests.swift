@testable import DevSupervisor
import XCTest

final class IdeaToPRDFlowBDDTests: XCTestCase {
    func testScenario01_generatePRDPromptForIdeaInActiveProject_returnsPromptWithExplicitSuccess() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")
        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Offline mode", status: .selected)

        let result = sut.generatePRDPrompt(for: ideaID)

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertFalse(result.promptText.isEmpty)
    }

    func testScenario02_generatePRDPromptWithoutActiveProject_isBlockedWithExplicitFailure() {
        let sut = makeSUT()

        let result = sut.generatePRDPrompt(for: IdeaID(rawValue: "I-1"))

        assertExplicitFailureWithReason(result.result)
        XCTAssertTrue(result.promptText.isEmpty)
    }

    func testScenario03_generatePRDPromptForNonExistentIdea_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generatePRDPrompt(for: IdeaID(rawValue: "I-404"))

        assertExplicitFailureWithReason(result.result)
        XCTAssertTrue(result.promptText.isEmpty)
    }

    func testScenario04_generatePRDPromptForIdeaOutsideActiveProject_returnsExplicitFailure() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let beta = ProjectID(rawValue: "P-2")
        let ideaID = IdeaID(rawValue: "I-2")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: beta, title: "Telemetry export", status: .selected)

        let result = sut.generatePRDPrompt(for: ideaID)

        assertExplicitFailureWithReason(result.result)
        XCTAssertTrue(result.promptText.isEmpty)
    }

    func testScenario05_generatedPromptIncludesMinimalRelevantContext_withExplicitSuccess() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Offline mode", status: .selected)
        sut.setContextAvailability(overview: true, constraints: true, glossary: true, stackRules: true)

        let result = sut.generatePRDPrompt(for: ideaID)

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertTrue(result.includesMinimalContext)
    }

    func testScenario06_generatePRDPromptWithMissingContextSources_returnsExplicitFailure() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Offline mode", status: .selected)
        sut.setContextAvailability(overview: true, constraints: false, glossary: true, stackRules: true)

        let result = sut.generatePRDPrompt(for: ideaID)

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario07_generatePRDPromptDeterministicallyForSameInput_returnsEquivalentPrompt() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Offline mode", status: .selected)

        let first = sut.generatePRDPrompt(for: ideaID)
        let second = sut.generatePRDPrompt(for: ideaID)

        XCTAssertEqual(first.promptText, second.promptText)
        XCTAssertEqual(first.promptFingerprint, second.promptFingerprint)
    }

    func testScenario08_generatePRDPrompt_doesNotAutoExecuteAgainstAIProvider() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Offline mode", status: .selected)

        _ = sut.generatePRDPrompt(for: ideaID)

        XCTAssertFalse(sut.didSendPromptToAIProvider)
    }

    func testScenario09_generationResultIncludesExplicitIdeaAndProjectIdentity() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Offline mode", status: .selected)

        let result = sut.generatePRDPrompt(for: ideaID)

        XCTAssertEqual(result.ideaID, ideaID)
        XCTAssertEqual(result.projectID, alpha)
    }

    func testScenario10_generatingPRDPromptDoesNotMutateIdeaContentOrStatus() throws {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Offline mode", status: .selected)
        let before = try XCTUnwrap(sut.idea(by: ideaID))

        _ = sut.generatePRDPrompt(for: ideaID)
        let after = try XCTUnwrap(sut.idea(by: ideaID))

        XCTAssertEqual(before, after)
    }

    func testScenario11_generatingPRDPromptCreatesOperationalTraceBoundToIdeaAndProject() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Offline mode", status: .selected)

        _ = sut.generatePRDPrompt(for: ideaID)
        let trace = sut.lastTrace()

        XCTAssertEqual(trace?.operation, "IDEA -> PRD")
        XCTAssertEqual(trace?.ideaID, ideaID)
        XCTAssertEqual(trace?.projectID, alpha)
    }
}

private extension IdeaToPRDFlowBDDTests {
    func makeSUT() -> IdeaToPRDFlowInMemory {
        IdeaToPRDFlowInMemory()
    }

    func assertExplicitFailureWithReason(
        _ result: RegistryOperationResult,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case let .failure(reason) = result else {
            XCTFail("Expected explicit failure with reason, got success", file: file, line: line)
            return
        }

        XCTAssertFalse(reason.message.isEmpty, "Failure reason should be explicit and non-empty", file: file, line: line)
    }
}
