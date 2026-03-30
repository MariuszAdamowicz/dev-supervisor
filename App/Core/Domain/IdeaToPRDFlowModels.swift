import Foundation

struct PRDPromptGenerationResult: Equatable {
    let result: RegistryOperationResult
    let promptText: String
    let promptFingerprint: String
    let includesMinimalContext: Bool
    let ideaID: IdeaID?
    let projectID: ProjectID?
}

struct PRDPromptGenerationTrace: Equatable {
    let operation: String
    let ideaID: IdeaID
    let projectID: ProjectID
}
