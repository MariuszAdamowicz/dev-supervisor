import Foundation

protocol FeaturesToPRDFlowContract {
    var didSendPromptToAIProvider: Bool { get }

    func selectActiveProject(id: ProjectID?)
    func setContextAvailability(overview: Bool, constraints: Bool, glossary: Bool, stackRules: Bool)
    func generatePRDPrompt(
        for ideaID: IdeaID,
        ideaTitle: String,
        features: [FeatureCandidate]
    ) -> PRDFromFeaturesPromptResult
    func lastTrace() -> PRDFromFeaturesPromptTrace?
}
