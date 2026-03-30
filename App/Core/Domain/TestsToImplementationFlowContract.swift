import Foundation

protocol TestsToImplementationFlowContract {
    var didSendPromptToAIProvider: Bool { get }

    func selectActiveProject(id: ProjectID?)
    func setContextAvailability(overview: Bool, constraints: Bool, glossary: Bool, stackRules: Bool)
    func generateImplementationPrompt(
        for ideaID: IdeaID,
        ideaTitle: String,
        testsDocument: String
    ) -> ImplementationFromTestsPromptResult
    func lastTrace() -> ImplementationFromTestsPromptTrace?
}
