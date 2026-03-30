import Foundation

protocol IdeaToFeaturesFlowContract {
    var didSendPromptToAIProvider: Bool { get }

    func selectActiveProject(id: ProjectID?)
    func seedIdea(id: IdeaID, projectID: ProjectID, title: String, status: IdeaStatus)
    func setContextAvailability(overview: Bool, constraints: Bool, glossary: Bool)
    func generateFeaturesPrompt(for ideaID: IdeaID) -> FeatureSetPromptGenerationResult
    func idea(by id: IdeaID) -> IdeaRecord?
    func lastTrace() -> FeatureSetPromptGenerationTrace?
}
