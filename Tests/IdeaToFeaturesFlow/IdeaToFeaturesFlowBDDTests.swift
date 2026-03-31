@testable import DevSupervisor
import XCTest

final class IdeaToFeaturesFlowBDDTests: XCTestCase {
    func testScenario01_generateFeaturesPromptForSelectedIdeaInActiveProject_returnsExplicitSuccess() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Project Registry", status: .selected)

        let result = sut.generateFeaturesPrompt(for: ideaID)

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertFalse(result.promptText.isEmpty)
        XCTAssertEqual(result.proposedFeatures.count, 3)
    }

    func testScenario02_generateFeaturesPromptWithoutActiveProject_returnsExplicitFailure() {
        let sut = makeSUT()

        let result = sut.generateFeaturesPrompt(for: IdeaID(rawValue: "I-1"))

        assertExplicitFailureWithReason(result.result)
        XCTAssertTrue(result.promptText.isEmpty)
    }

    func testScenario03_generateFeaturesPromptForNonExistentIdea_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateFeaturesPrompt(for: IdeaID(rawValue: "I-404"))

        assertExplicitFailureWithReason(result.result)
        XCTAssertTrue(result.promptText.isEmpty)
    }

    func testScenario04_generateFeaturesPromptForIdeaOutsideActiveProject_returnsExplicitFailure() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let beta = ProjectID(rawValue: "P-2")
        let ideaID = IdeaID(rawValue: "I-2")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: beta, title: "Telemetry Export", status: .selected)

        let result = sut.generateFeaturesPrompt(for: ideaID)

        assertExplicitFailureWithReason(result.result)
        XCTAssertTrue(result.promptText.isEmpty)
    }

    func testScenario05_generateFeaturesPromptForIdeaNotSelected_returnsExplicitFailure() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Project Registry", status: .new)

        let result = sut.generateFeaturesPrompt(for: ideaID)

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario06_generatedPromptIncludesMinimalContext_withExplicitSuccess() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Project Registry", status: .selected)
        sut.setContextAvailability(overview: true, constraints: true, glossary: true)

        let result = sut.generateFeaturesPrompt(for: ideaID)

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertTrue(result.includesMinimalContext)
    }

    func testScenario07_generateFeaturesPromptWithMissingContext_returnsExplicitFailure() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Project Registry", status: .selected)
        sut.setContextAvailability(overview: true, constraints: false, glossary: true)

        let result = sut.generateFeaturesPrompt(for: ideaID)

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario08_generateFeaturesPromptDeterministicallyForSameInput_returnsEquivalentPrompt() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Project Registry", status: .selected)

        let first = sut.generateFeaturesPrompt(for: ideaID)
        let second = sut.generateFeaturesPrompt(for: ideaID)

        XCTAssertEqual(first.promptText, second.promptText)
        XCTAssertEqual(first.promptFingerprint, second.promptFingerprint)
        XCTAssertEqual(first.proposedFeatures, second.proposedFeatures)
    }

    func testScenario09_generateFeaturesPrompt_doesNotAutoExecuteAgainstAIProvider() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Project Registry", status: .selected)

        _ = sut.generateFeaturesPrompt(for: ideaID)

        XCTAssertFalse(sut.didSendPromptToAIProvider)
    }

    func testScenario10_generationResultIncludesExplicitIdeaAndProjectIdentity() {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Project Registry", status: .selected)

        let result = sut.generateFeaturesPrompt(for: ideaID)

        XCTAssertEqual(result.ideaID, ideaID)
        XCTAssertEqual(result.projectID, alpha)
    }

    func testScenario11_generatingFeaturesPromptDoesNotMutateIdeaAndCreatesTrace() throws {
        let sut = makeSUT()
        let alpha = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")

        sut.selectActiveProject(id: alpha)
        sut.seedIdea(id: ideaID, projectID: alpha, title: "Project Registry", status: .selected)
        let before = try XCTUnwrap(sut.idea(by: ideaID))

        _ = sut.generateFeaturesPrompt(for: ideaID)

        let after = try XCTUnwrap(sut.idea(by: ideaID))
        let trace = sut.lastTrace()

        XCTAssertEqual(before, after)
        XCTAssertEqual(trace?.operation, "IDEA -> FEATURES")
        XCTAssertEqual(trace?.ideaID, ideaID)
        XCTAssertEqual(trace?.projectID, alpha)
    }
}

private extension IdeaToFeaturesFlowBDDTests {
    func makeSUT() -> IdeaToFeaturesFlowInMemory {
        IdeaToFeaturesFlowInMemory()
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
