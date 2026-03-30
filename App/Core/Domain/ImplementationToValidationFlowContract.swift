import Foundation

protocol ImplementationToValidationFlowContract {
    var didSendPromptToAIProvider: Bool { get }

    func selectActiveProject(id: ProjectID?)
    func setContextAvailability(overview: Bool, constraints: Bool, glossary: Bool, stackRules: Bool)
    func generateValidationPrompt(
        for ideaID: IdeaID,
        ideaTitle: String,
        implementationDocument: String
    ) -> ValidationFromImplementationPromptResult
    func lastTrace() -> ValidationFromImplementationPromptTrace?
}
