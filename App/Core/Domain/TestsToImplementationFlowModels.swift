import Foundation

struct ImplementationFromTestsPromptResult: Equatable {
    let result: RegistryOperationResult
    let promptText: String
    let promptFingerprint: String
    let includesMinimalContext: Bool
    let ideaID: IdeaID?
    let projectID: ProjectID?
    let testsLength: Int
}

struct ImplementationFromTestsPromptTrace: Equatable {
    let operation: String
    let ideaID: IdeaID
    let projectID: ProjectID
}
