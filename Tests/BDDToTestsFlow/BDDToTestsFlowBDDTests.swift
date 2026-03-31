@testable import DevSupervisor
import XCTest

final class BDDToTestsFlowBDDTests: XCTestCase {
    func testScenario01_generateTestsFromBDD_returnsExplicitSuccess() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateTestsPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            bddDocument: makeBDD()
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertFalse(result.promptText.isEmpty)
        XCTAssertGreaterThan(result.bddLength, 0)
    }

    func testScenario02_generateTestsFromBDDWithoutActiveProject_returnsExplicitFailure() {
        let sut = makeSUT()

        let result = sut.generateTestsPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            bddDocument: makeBDD()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario03_generateTestsFromBDDWithEmptyIdeaTitle_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateTestsPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "",
            bddDocument: makeBDD()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario04_generateTestsFromBDDWithEmptyDocument_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateTestsPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            bddDocument: " \n "
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario05_generateTestsFromBDDWithMissingContext_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))
        sut.setContextAvailability(overview: true, constraints: false, glossary: true, stackRules: true)

        let result = sut.generateTestsPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            bddDocument: makeBDD()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario06_generatedPromptIncludesMinimalContext_withExplicitSuccess() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generateTestsPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            bddDocument: makeBDD()
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertTrue(result.includesMinimalContext)
    }

    func testScenario07_generateTestsFromBDDDeterministically_returnsEquivalentPromptAndFingerprint() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let first = sut.generateTestsPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            bddDocument: makeBDD()
        )

        let second = sut.generateTestsPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            bddDocument: makeBDD()
        )

        XCTAssertEqual(first.promptText, second.promptText)
        XCTAssertEqual(first.promptFingerprint, second.promptFingerprint)
    }

    func testScenario08_generateTestsFromBDD_doesNotAutoExecuteAgainstAIProvider() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        _ = sut.generateTestsPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            bddDocument: makeBDD()
        )

        XCTAssertFalse(sut.didSendPromptToAIProvider)
    }

    func testScenario09_generateTestsFromBDDCreatesTraceBoundToIdeaAndProject() {
        let sut = makeSUT()
        let projectID = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")
        sut.selectActiveProject(id: projectID)

        _ = sut.generateTestsPrompt(
            for: ideaID,
            ideaTitle: "Project Registry",
            bddDocument: makeBDD()
        )

        let trace = sut.lastTrace()

        XCTAssertEqual(trace?.operation, "BDD -> TESTS")
        XCTAssertEqual(trace?.ideaID, ideaID)
        XCTAssertEqual(trace?.projectID, projectID)
    }
}

private extension BDDToTestsFlowBDDTests {
    func makeSUT() -> BDDToTestsFlowInMemory {
        BDDToTestsFlowInMemory()
    }

    func makeBDD() -> String {
        """
        # BDD
        Scenariusz 1: Given active project, when operator generates PRD, then prompt exists.
        Scenariusz 2: Given missing context, when operator runs gate, then explicit failure.
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
