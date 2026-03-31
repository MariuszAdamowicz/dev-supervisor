@testable import DevSupervisor
import XCTest

final class TestsToImplementationFlowBDDTests: XCTestCase {
    func testScenario01_generateImplementationFromTests_returnsExplicitSuccess() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateImplementationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            testsDocument: makeTestsDocument()
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertFalse(result.promptText.isEmpty)
        XCTAssertGreaterThan(result.testsLength, 0)
    }

    func testScenario02_generateImplementationFromTestsWithoutActiveProject_returnsExplicitFailure() {
        let sut = makeSUT()

        let result = sut.generateImplementationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            testsDocument: makeTestsDocument()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario03_generateImplementationFromTestsWithEmptyIdeaTitle_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateImplementationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "",
            testsDocument: makeTestsDocument()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario04_generateImplementationFromTestsWithEmptyDocument_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateImplementationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            testsDocument: "\n \n"
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario05_generateImplementationFromTestsWithMissingContext_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))
        sut.setContextAvailability(overview: true, constraints: true, glossary: false, stackRules: true)

        let result = sut.generateImplementationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            testsDocument: makeTestsDocument()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario06_generatedPromptIncludesMinimalContext_withExplicitSuccess() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateImplementationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            testsDocument: makeTestsDocument()
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertTrue(result.includesMinimalContext)
    }

    func testScenario07_generateImplementationFromTestsDeterministically_returnsEquivalentPromptAndFingerprint() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let first = sut.generateImplementationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            testsDocument: makeTestsDocument()
        )

        let second = sut.generateImplementationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            testsDocument: makeTestsDocument()
        )

        XCTAssertEqual(first.promptText, second.promptText)
        XCTAssertEqual(first.promptFingerprint, second.promptFingerprint)
    }

    func testScenario08_generateImplementationFromTests_doesNotAutoExecuteAgainstAIProvider() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        _ = sut.generateImplementationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            testsDocument: makeTestsDocument()
        )

        XCTAssertFalse(sut.didSendPromptToAIProvider)
    }

    func testScenario09_generateImplementationFromTestsCreatesTraceBoundToIdeaAndProject() {
        let sut = makeSUT()
        let projectID = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")
        sut.selectActiveProject(id: projectID)

        _ = sut.generateImplementationPrompt(
            for: ideaID,
            ideaTitle: "Project Registry",
            testsDocument: makeTestsDocument()
        )

        let trace = sut.lastTrace()

        XCTAssertEqual(trace?.operation, "TESTS -> IMPLEMENTATION")
        XCTAssertEqual(trace?.ideaID, ideaID)
        XCTAssertEqual(trace?.projectID, projectID)
    }
}

private extension TestsToImplementationFlowBDDTests {
    func makeSUT() -> TestsToImplementationFlowInMemory {
        TestsToImplementationFlowInMemory()
    }

    func makeTestsDocument() -> String {
        """
        # Test Plan
        - Unit: validate deterministic prompt gates
        - Integration: chain gates in operator workflow
        - UI: verify explicit failure messaging and gate ordering
        """
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
