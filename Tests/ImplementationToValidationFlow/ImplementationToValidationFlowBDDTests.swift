@testable import DevSupervisor
import XCTest

final class ImplementationToValidationFlowBDDTests: XCTestCase {
    func testScenario01_generateValidationFromImplementation_returnsExplicitSuccess() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateValidationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            implementationDocument: makeImplementationDocument()
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertFalse(result.promptText.isEmpty)
        XCTAssertGreaterThan(result.implementationLength, 0)
    }

    func testScenario02_generateValidationFromImplementationWithoutActiveProject_returnsExplicitFailure() {
        let sut = makeSUT()

        let result = sut.generateValidationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            implementationDocument: makeImplementationDocument()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario03_generateValidationFromImplementationWithEmptyIdeaTitle_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateValidationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "",
            implementationDocument: makeImplementationDocument()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario04_generateValidationFromImplementationWithEmptyDocument_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateValidationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            implementationDocument: " \n "
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario05_generateValidationFromImplementationWithMissingContext_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))
        sut.setContextAvailability(overview: true, constraints: false, glossary: true, stackRules: true)

        let result = sut.generateValidationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            implementationDocument: makeImplementationDocument()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario06_generatedPromptIncludesMinimalContext_withExplicitSuccess() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateValidationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            implementationDocument: makeImplementationDocument()
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertTrue(result.includesMinimalContext)
    }

    func testScenario07_generateValidationFromImplementationDeterministically_returnsEquivalentPromptAndFingerprint() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let first = sut.generateValidationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            implementationDocument: makeImplementationDocument()
        )

        let second = sut.generateValidationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            implementationDocument: makeImplementationDocument()
        )

        XCTAssertEqual(first.promptText, second.promptText)
        XCTAssertEqual(first.promptFingerprint, second.promptFingerprint)
    }

    func testScenario08_generateValidationFromImplementation_doesNotAutoExecuteAgainstAIProvider() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        _ = sut.generateValidationPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            implementationDocument: makeImplementationDocument()
        )

        XCTAssertFalse(sut.didSendPromptToAIProvider)
    }

    func testScenario09_generateValidationFromImplementationCreatesTraceBoundToIdeaAndProject() {
        let sut = makeSUT()
        let projectID = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")
        sut.selectActiveProject(id: projectID)

        _ = sut.generateValidationPrompt(
            for: ideaID,
            ideaTitle: "Project Registry",
            implementationDocument: makeImplementationDocument()
        )

        let trace = sut.lastTrace()

        XCTAssertEqual(trace?.operation, "IMPLEMENTATION -> VALIDATION")
        XCTAssertEqual(trace?.ideaID, ideaID)
        XCTAssertEqual(trace?.projectID, projectID)
    }
}

private extension ImplementationToValidationFlowBDDTests {
    func makeSUT() -> any ImplementationToValidationFlowContract {
        ImplementationToValidationFlowInMemory()
    }

    func makeImplementationDocument() -> String {
        """
        # Implementation Batch
        - Added deterministic gates and explicit error handling
        - Preserved operator-controlled transitions
        - Added traceability fields for each operation
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
