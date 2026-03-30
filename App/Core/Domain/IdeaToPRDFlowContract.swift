protocol IdeaToPRDFlowContract {
    func selectActiveProject(id: ProjectID?)
    func seedIdea(id: IdeaID, projectID: ProjectID, title: String, status: IdeaStatus)
    func setContextAvailability(overview: Bool, constraints: Bool, glossary: Bool, stackRules: Bool)

    func generatePRDPrompt(for ideaID: IdeaID) -> PRDPromptGenerationResult
    func idea(by id: IdeaID) -> IdeaRecord?

    var didSendPromptToAIProvider: Bool { get }
    func lastTrace() -> PRDPromptGenerationTrace?
}
