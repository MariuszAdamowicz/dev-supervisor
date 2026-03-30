import Foundation

struct ValidationFromImplementationPromptResult: Equatable {
    let result: RegistryOperationResult
    let promptText: String
    let promptFingerprint: String
    let includesMinimalContext: Bool
    let ideaID: IdeaID?
    let projectID: ProjectID?
    let implementationLength: Int
}

struct ValidationFromImplementationPromptTrace: Equatable {
    let operation: String
    let ideaID: IdeaID
    let projectID: ProjectID
}
