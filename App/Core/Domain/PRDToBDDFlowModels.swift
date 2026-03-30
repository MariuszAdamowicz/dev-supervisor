import Foundation

struct BDDFromPRDPromptResult: Equatable {
    let result: RegistryOperationResult
    let promptText: String
    let promptFingerprint: String
    let includesMinimalContext: Bool
    let ideaID: IdeaID?
    let projectID: ProjectID?
    let prdLength: Int
}

struct BDDFromPRDPromptTrace: Equatable {
    let operation: String
    let ideaID: IdeaID
    let projectID: ProjectID
}
