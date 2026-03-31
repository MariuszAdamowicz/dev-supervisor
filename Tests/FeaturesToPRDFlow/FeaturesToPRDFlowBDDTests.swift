@testable import DevSupervisor
import XCTest

final class FeaturesToPRDFlowBDDTests: XCTestCase {
    func testScenario01_generatePRDFromFeatures_returnsExplicitSuccess() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generatePRDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            features: makeFeatures()
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertEqual(result.featuresCount, 2)
        XCTAssertFalse(result.promptText.isEmpty)
    }

    func testScenario02_generatePRDFromFeaturesWithoutActiveProject_returnsExplicitFailure() {
        let sut = makeSUT()

        let result = sut.generatePRDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            features: makeFeatures()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario03_generatePRDFromFeaturesWithEmptyIdeaTitle_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generatePRDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "",
            features: makeFeatures()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario04_generatePRDFromFeaturesWithoutFeatureCandidates_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generatePRDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            features: []
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario05_generatePRDFromFeaturesWithMissingContext_returnsExplicitFailure() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))
        sut.setContextAvailability(overview: true, constraints: false, glossary: true, stackRules: true)

        let result = sut.generatePRDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            features: makeFeatures()
        )

        assertExplicitFailureWithReason(result.result)
    }

    func testScenario06_generatedPromptIncludesMinimalContext_withExplicitSuccess() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let result = sut.generatePRDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            features: makeFeatures()
        )

        XCTAssertTrue(result.result.isSuccess)
        XCTAssertTrue(result.includesMinimalContext)
    }

    func testScenario07_generatePRDFromFeaturesDeterministically_returnsEquivalentPromptAndFingerprint() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        let first = sut.generatePRDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            features: makeFeatures()
        )

        let second = sut.generatePRDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            features: makeFeatures()
        )

        XCTAssertEqual(first.promptText, second.promptText)
        XCTAssertEqual(first.promptFingerprint, second.promptFingerprint)
    }

    func testScenario08_generatePRDFromFeatures_doesNotAutoExecuteAgainstAIProvider() {
        let sut = makeSUT()
        sut.selectActiveProject(id: ProjectID(rawValue: "P-1"))

        _ = sut.generatePRDPrompt(
            for: IdeaID(rawValue: "I-1"),
            ideaTitle: "Project Registry",
            features: makeFeatures()
        )

        XCTAssertFalse(sut.didSendPromptToAIProvider)
    }

    func testScenario09_generatePRDFromFeaturesCreatesTraceBoundToIdeaAndProject() {
        let sut = makeSUT()
        let projectID = ProjectID(rawValue: "P-1")
        let ideaID = IdeaID(rawValue: "I-1")
        sut.selectActiveProject(id: projectID)

        _ = sut.generatePRDPrompt(
            for: ideaID,
            ideaTitle: "Project Registry",
            features: makeFeatures()
        )

        let trace = sut.lastTrace()

        XCTAssertEqual(trace?.operation, "FEATURES -> PRD")
        XCTAssertEqual(trace?.ideaID, ideaID)
        XCTAssertEqual(trace?.projectID, projectID)
    }
}

private extension FeaturesToPRDFlowBDDTests {
    func makeSUT() -> FeaturesToPRDFlowInMemory {
        FeaturesToPRDFlowInMemory()
    }

    func makeFeatures() -> [FeatureCandidate] {
        [
            FeatureCandidate(key: "F-1", name: "Zakres", description: "Opis zakresu"),
            FeatureCandidate(key: "F-2", name: "Walidacja", description: "Opis walidacji"),
        ]
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
