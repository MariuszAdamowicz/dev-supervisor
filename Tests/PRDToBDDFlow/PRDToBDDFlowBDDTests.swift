@testable import DevSupervisor
import XCTest

final class PRDToBDDFlowBDDTests: XCTestCase {
    func testScenario01_generateBDDFromPRD_returnsExplicitSuccess() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateBDDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            prdDocument: makePRD()
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertFalse(result.promptText.isEmpty)
        XCTAssertGreaterThan(result.prdLength, 0)
    }

    func testScenario02_generateBDDFromPRDWithoutActiveProject_returnsExplicitFailure() {
        let sut = makeSUT()

        let result = sut.generateBDDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            prdDocument: makePRD()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario03_generateBDDFromPRDWithEmptyIdeaTitle_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateBDDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "",
            prdDocument: makePRD()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario04_generateBDDFromPRDWithEmptyDocument_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateBDDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            prdDocument: "   "
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario05_generateBDDFromPRDWithMissingContext_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))
        sut.setContextAvailability(overview: true, constraints: true, glossary: false, stackRules: true)

        let result = sut.generateBDDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            prdDocument: makePRD()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario06_generatedPromptIncludesMinimalContext_withExplicitSuccess() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateBDDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            prdDocument: makePRD()
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertTrue(result.includesMinimalContext)
    }

    func testScenario07_generateBDDFromPRDDeterministically_returnsEquivalentPromptAndFingerprint() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let first = sut.generateBDDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            prdDocument: makePRD()
        )

        let second = sut.generateBDDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            prdDocument: makePRD()
        )

        XCTAssertEqual(first.promptText, second.promptText)
        XCTAssertEqual(first.promptFingerprint, second.promptFingerprint)
    }

    func testScenario08_generateBDDFromPRD_doesNotAutoExecuteAgainstAIProvider() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        _ = sut.generateBDDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            prdDocument: makePRD()
        )

        XCTAssertFalse(sut.didSendPromptToAIProvider)
    }

    func testScenario09_generateBDDFromPRDCreatesTraceBoundToIdeaAndProject() {
        let sut = makeSUT()
        let projectID = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")
        sut.selectActiveProject(id: projectID)

        _ = sut.generateBDDPrompt(
            for: ideaID,
            ideaTitle: "Project Registry",
            prdDocument: makePRD()
        )

        let trace = sut.lastTrace()

        XCTAssertEqual(trace?.operation, "PRD -> BDD")
        XCTAssertEqual(trace?.ideaID, ideaID)
        XCTAssertEqual(trace?.projectID, projectID)
    }
}

private extension PRDToBDDFlowBDDTests {
    func makeSUT() -> PRDToBDDFlowInMemory {
        PRDToBDDFlowInMemory()
    }

    func makePRD() -> String {
        """
        # PRD: Project Registry
        ## Feature Set
        - F-1: create project
        - F-2: list active projects
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
