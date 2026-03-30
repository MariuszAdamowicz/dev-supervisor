import Foundation

protocol PRDToBDDFlowContract {
    var didSendPromptToAIProvider: Bool { get }

    func selectActiveProject(id: ProjectID?)
    func setContextAvailability(overview: Bool, constraints: Bool, glossary: Bool, stackRules: Bool)
    func generateBDDPrompt(
        for ideaID: IdeaID,
        ideaTitle: String,
        prdDocument: String
    ) -> BDDFromPRDPromptResult
    func lastTrace() -> BDDFromPRDPromptTrace?
}
