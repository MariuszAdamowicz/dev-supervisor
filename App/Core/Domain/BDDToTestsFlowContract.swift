import Foundation

protocol BDDToTestsFlowContract {
    var didSendPromptToAIProvider: Bool { get }

    func selectActiveProject(id: ProjectID?)
    func setContextAvailability(overview: Bool, constraints: Bool, glossary: Bool, stackRules: Bool)
    func generateTestsPrompt(
        for ideaID: IdeaID,
        ideaTitle: String,
        bddDocument: String
    ) -> TestsFromBDDPromptResult
    func lastTrace() -> TestsFromBDDPromptTrace?
}
