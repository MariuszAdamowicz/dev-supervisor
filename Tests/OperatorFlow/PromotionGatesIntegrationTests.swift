@testable import DevSupervisor
import XCTest

final class PromotionGatesIntegrationTests: XCTestCase {
    func testScenario01_fullPromotionGateSequence_blocksAndThenAllowsEachStep() {
        let projectID = ProjectID(rawValue: "P-INT-1")
        let ideaID = IdeaID(rawValue: "I-INT-1")
        let ideaTitle = "Gate chain integration"
        let features = [
            FeatureCandidate(
                key: "F-1",
                name: "Project bootstrap",
                description: "Prepare deterministic project structure."
            ),
        ]

        let featuresToPRD = configuredFeaturesToPRD(projectID: projectID)
        let prdToBDD = configuredPRDToBDD(projectID: projectID)
        let bddToTests = configuredBDDToTests(projectID: projectID)
        let testsToImplementation = configuredTestsToImplementation(projectID: projectID)
        let implementationToValidation = configuredImplementationToValidation(projectID: projectID)

        var approvedFeaturesForPRD: [FeatureCandidate] = []
        var approvedPRDForBDD = ""
        var approvedBDDForTests = ""
        var approvedTestsForImplementation = ""
        var approvedImplementationForValidation = ""

        let blockedPRD = generatePRDWithPromotionGate(
            approvedFeaturesForPRD: approvedFeaturesForPRD,
            featuresToPRD: featuresToPRD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertFalse(blockedPRD.result.isSuccess)

        approvedFeaturesForPRD = features
        let prd = generatePRDWithPromotionGate(
            approvedFeaturesForPRD: approvedFeaturesForPRD,
            featuresToPRD: featuresToPRD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(prd.result.isSuccess)

        let blockedBDD = generateBDDWithPromotionGate(
            approvedPRDForBDD: approvedPRDForBDD,
            prdToBDD: prdToBDD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertFalse(blockedBDD.result.isSuccess)

        approvedPRDForBDD = prd.promptText
        let bdd = generateBDDWithPromotionGate(
            approvedPRDForBDD: approvedPRDForBDD,
            prdToBDD: prdToBDD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(bdd.result.isSuccess)

        let blockedTests = generateTestsWithPromotionGate(
            approvedBDDForTests: approvedBDDForTests,
            bddToTests: bddToTests,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertFalse(blockedTests.result.isSuccess)

        approvedBDDForTests = bdd.promptText
        let tests = generateTestsWithPromotionGate(
            approvedBDDForTests: approvedBDDForTests,
            bddToTests: bddToTests,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(tests.result.isSuccess)

        let blockedImplementation = generateImplementationWithPromotionGate(
            approvedTestsForImplementation: approvedTestsForImplementation,
            testsToImplementation: testsToImplementation,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertFalse(blockedImplementation.result.isSuccess)

        approvedTestsForImplementation = tests.promptText
        let implementation = generateImplementationWithPromotionGate(
            approvedTestsForImplementation: approvedTestsForImplementation,
            testsToImplementation: testsToImplementation,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(implementation.result.isSuccess)

        let blockedValidation = generateValidationWithPromotionGate(
            approvedImplementationForValidation: approvedImplementationForValidation,
            implementationToValidation: implementationToValidation,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertFalse(blockedValidation.result.isSuccess)

        approvedImplementationForValidation = implementation.promptText
        let validation = generateValidationWithPromotionGate(
            approvedImplementationForValidation: approvedImplementationForValidation,
            implementationToValidation: implementationToValidation,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(validation.result.isSuccess)
    }

    func testScenario02_regeneratedUpstreamArtifact_requiresFreshPromotionBeforeNextGate() {
        let projectID = ProjectID(rawValue: "P-INT-2")
        let ideaID = IdeaID(rawValue: "I-INT-2")
        let ideaTitle = "Gate reset integration"
        let featureA = FeatureCandidate(key: "F-A", name: "A", description: "A")
        let featureB = FeatureCandidate(key: "F-B", name: "B", description: "B")

        let featuresToPRD = configuredFeaturesToPRD(projectID: projectID)
        let prdToBDD = configuredPRDToBDD(projectID: projectID)

        let prdA = generatePRDWithPromotionGate(
            approvedFeaturesForPRD: [featureA],
            featuresToPRD: featuresToPRD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(prdA.result.isSuccess)

        let bddA = generateBDDWithPromotionGate(
            approvedPRDForBDD: prdA.promptText,
            prdToBDD: prdToBDD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(bddA.result.isSuccess)

        let prdB = generatePRDWithPromotionGate(
            approvedFeaturesForPRD: [featureB],
            featuresToPRD: featuresToPRD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(prdB.result.isSuccess)

        let blockedAfterReset = generateBDDWithPromotionGate(
            approvedPRDForBDD: "",
            prdToBDD: prdToBDD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertFalse(blockedAfterReset.result.isSuccess)

        let bddB = generateBDDWithPromotionGate(
            approvedPRDForBDD: prdB.promptText,
            prdToBDD: prdToBDD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(bddB.result.isSuccess)
        XCTAssertNotEqual(bddA.promptFingerprint, bddB.promptFingerprint)
    }

    func testScenario03_regeneratedBDD_requiresFreshPromotionBeforeTestsGate() {
        let projectID = ProjectID(rawValue: "P-INT-3")
        let ideaID = IdeaID(rawValue: "I-INT-3")
        let ideaTitle = "BDD reset integration"
        let featureA = FeatureCandidate(key: "F-A", name: "A", description: "A")
        let featureB = FeatureCandidate(key: "F-B", name: "B", description: "B")

        let featuresToPRD = configuredFeaturesToPRD(projectID: projectID)
        let prdToBDD = configuredPRDToBDD(projectID: projectID)
        let bddToTests = configuredBDDToTests(projectID: projectID)

        let prdA = generatePRDWithPromotionGate(
            approvedFeaturesForPRD: [featureA],
            featuresToPRD: featuresToPRD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(prdA.result.isSuccess)

        let bddA = generateBDDWithPromotionGate(
            approvedPRDForBDD: prdA.promptText,
            prdToBDD: prdToBDD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(bddA.result.isSuccess)

        let testsA = generateTestsWithPromotionGate(
            approvedBDDForTests: bddA.promptText,
            bddToTests: bddToTests,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(testsA.result.isSuccess)

        let prdB = generatePRDWithPromotionGate(
            approvedFeaturesForPRD: [featureB],
            featuresToPRD: featuresToPRD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(prdB.result.isSuccess)

        let bddB = generateBDDWithPromotionGate(
            approvedPRDForBDD: prdB.promptText,
            prdToBDD: prdToBDD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(bddB.result.isSuccess)

        let blockedAfterReset = generateTestsWithPromotionGate(
            approvedBDDForTests: "",
            bddToTests: bddToTests,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertFalse(blockedAfterReset.result.isSuccess)

        let testsB = generateTestsWithPromotionGate(
            approvedBDDForTests: bddB.promptText,
            bddToTests: bddToTests,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(testsB.result.isSuccess)
        XCTAssertNotEqual(testsA.promptFingerprint, testsB.promptFingerprint)
    }

    func testScenario04_regeneratedTests_requiresFreshPromotionBeforeImplementationGate() {
        let projectID = ProjectID(rawValue: "P-INT-4")
        let ideaID = IdeaID(rawValue: "I-INT-4")
        let ideaTitle = "Tests reset integration"
        let featureA = FeatureCandidate(key: "F-A", name: "A", description: "A")
        let featureB = FeatureCandidate(key: "F-B", name: "B", description: "B")

        let featuresToPRD = configuredFeaturesToPRD(projectID: projectID)
        let prdToBDD = configuredPRDToBDD(projectID: projectID)
        let bddToTests = configuredBDDToTests(projectID: projectID)
        let testsToImplementation = configuredTestsToImplementation(projectID: projectID)

        let prdA = generatePRDWithPromotionGate(
            approvedFeaturesForPRD: [featureA],
            featuresToPRD: featuresToPRD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(prdA.result.isSuccess)

        let bddA = generateBDDWithPromotionGate(
            approvedPRDForBDD: prdA.promptText,
            prdToBDD: prdToBDD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(bddA.result.isSuccess)

        let testsA = generateTestsWithPromotionGate(
            approvedBDDForTests: bddA.promptText,
            bddToTests: bddToTests,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(testsA.result.isSuccess)

        let implementationA = generateImplementationWithPromotionGate(
            approvedTestsForImplementation: testsA.promptText,
            testsToImplementation: testsToImplementation,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(implementationA.result.isSuccess)

        let prdB = generatePRDWithPromotionGate(
            approvedFeaturesForPRD: [featureB],
            featuresToPRD: featuresToPRD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(prdB.result.isSuccess)

        let bddB = generateBDDWithPromotionGate(
            approvedPRDForBDD: prdB.promptText,
            prdToBDD: prdToBDD,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(bddB.result.isSuccess)

        let testsB = generateTestsWithPromotionGate(
            approvedBDDForTests: bddB.promptText,
            bddToTests: bddToTests,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(testsB.result.isSuccess)

        let blockedAfterReset = generateImplementationWithPromotionGate(
            approvedTestsForImplementation: "",
            testsToImplementation: testsToImplementation,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertFalse(blockedAfterReset.result.isSuccess)

        let implementationB = generateImplementationWithPromotionGate(
            approvedTestsForImplementation: testsB.promptText,
            testsToImplementation: testsToImplementation,
            ideaID: ideaID,
            ideaTitle: ideaTitle
        )
        XCTAssertTrue(implementationB.result.isSuccess)
        XCTAssertNotEqual(implementationA.promptFingerprint, implementationB.promptFingerprint)
    }
}

private extension PromotionGatesIntegrationTests {
    func configuredFeaturesToPRD(projectID: ProjectID) -> FeaturesToPRDFlowInMemory {
        let flow = FeaturesToPRDFlowInMemory()
        flow.selectActiveProject(id: projectID)
        flow.setContextAvailability(overview: true, constraints: true, glossary: true, stackRules: true)
        return flow
    }

    func configuredPRDToBDD(projectID: ProjectID) -> PRDToBDDFlowInMemory {
        let flow = PRDToBDDFlowInMemory()
        flow.selectActiveProject(id: projectID)
        flow.setContextAvailability(overview: true, constraints: true, glossary: true, stackRules: true)
        return flow
    }

    func configuredBDDToTests(projectID: ProjectID) -> BDDToTestsFlowInMemory {
        let flow = BDDToTestsFlowInMemory()
        flow.selectActiveProject(id: projectID)
        flow.setContextAvailability(overview: true, constraints: true, glossary: true, stackRules: true)
        return flow
    }

    func configuredTestsToImplementation(projectID: ProjectID) -> TestsToImplementationFlowInMemory {
        let flow = TestsToImplementationFlowInMemory()
        flow.selectActiveProject(id: projectID)
        flow.setContextAvailability(overview: true, constraints: true, glossary: true, stackRules: true)
        return flow
    }

    func configuredImplementationToValidation(projectID: ProjectID) -> ImplementationToValidationFlowInMemory {
        let flow = ImplementationToValidationFlowInMemory()
        flow.selectActiveProject(id: projectID)
        flow.setContextAvailability(overview: true, constraints: true, glossary: true, stackRules: true)
        return flow
    }

    func generatePRDWithPromotionGate(
        approvedFeaturesForPRD: [FeatureCandidate],
        featuresToPRD: FeaturesToPRDFlowInMemory,
        ideaID: IdeaID,
        ideaTitle: String
    ) -> PRDFromFeaturesPromptResult {
        guard !approvedFeaturesForPRD.isEmpty else {
            return PRDFromFeaturesPromptResult(
                result: .failure(.init(message: "Promote features to PRD gate before this step.")),
                promptText: "",
                promptFingerprint: "",
                includesMinimalContext: false,
                ideaID: nil,
                projectID: nil,
                featuresCount: 0
            )
        }
        return featuresToPRD.generatePRDPrompt(
            for: ideaID,
            ideaTitle: ideaTitle,
            features: approvedFeaturesForPRD
        )
    }

    func generateBDDWithPromotionGate(
        approvedPRDForBDD: String,
        prdToBDD: PRDToBDDFlowInMemory,
        ideaID: IdeaID,
        ideaTitle: String
    ) -> BDDFromPRDPromptResult {
        guard !approvedPRDForBDD.isEmpty else {
            return BDDFromPRDPromptResult(
                result: .failure(.init(message: "Promote PRD to BDD gate before this step.")),
                promptText: "",
                promptFingerprint: "",
                includesMinimalContext: false,
                ideaID: nil,
                projectID: nil,
                prdLength: 0
            )
        }
        return prdToBDD.generateBDDPrompt(
            for: ideaID,
            ideaTitle: ideaTitle,
            prdDocument: approvedPRDForBDD
        )
    }

    func generateTestsWithPromotionGate(
        approvedBDDForTests: String,
        bddToTests: BDDToTestsFlowInMemory,
        ideaID: IdeaID,
        ideaTitle: String
    ) -> TestsFromBDDPromptResult {
        guard !approvedBDDForTests.isEmpty else {
            return TestsFromBDDPromptResult(
                result: .failure(.init(message: "Promote BDD to TESTS gate before this step.")),
                promptText: "",
                promptFingerprint: "",
                includesMinimalContext: false,
                ideaID: nil,
                projectID: nil,
                bddLength: 0
            )
        }
        return bddToTests.generateTestsPrompt(
            for: ideaID,
            ideaTitle: ideaTitle,
            bddDocument: approvedBDDForTests
        )
    }

    func generateImplementationWithPromotionGate(
        approvedTestsForImplementation: String,
        testsToImplementation: TestsToImplementationFlowInMemory,
        ideaID: IdeaID,
        ideaTitle: String
    ) -> ImplementationFromTestsPromptResult {
        guard !approvedTestsForImplementation.isEmpty else {
            return ImplementationFromTestsPromptResult(
                result: .failure(.init(message: "Promote TESTS to IMPLEMENTATION gate before this step.")),
                promptText: "",
                promptFingerprint: "",
                includesMinimalContext: false,
                ideaID: nil,
                projectID: nil,
                testsLength: 0
            )
        }
        return testsToImplementation.generateImplementationPrompt(
            for: ideaID,
            ideaTitle: ideaTitle,
            testsDocument: approvedTestsForImplementation
        )
    }

    func generateValidationWithPromotionGate(
        approvedImplementationForValidation: String,
        implementationToValidation: ImplementationToValidationFlowInMemory,
        ideaID: IdeaID,
        ideaTitle: String
    ) -> ValidationFromImplementationPromptResult {
        guard !approvedImplementationForValidation.isEmpty else {
            return ValidationFromImplementationPromptResult(
                result: .failure(.init(message: "Promote IMPLEMENTATION to VALIDATION gate before this step.")),
                promptText: "",
                promptFingerprint: "",
                includesMinimalContext: false,
                ideaID: nil,
                projectID: nil,
                implementationLength: 0
            )
        }
        return implementationToValidation.generateValidationPrompt(
            for: ideaID,
            ideaTitle: ideaTitle,
            implementationDocument: approvedImplementationForValidation
        )
    }
}
