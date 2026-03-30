import Foundation

struct TestsFromBDDPromptResult: Equatable {
    let result: RegistryOperationResult
    let promptText: String
    let promptFingerprint: String
    let includesMinimalContext: Bool
    let ideaID: IdeaID?
    let projectID: ProjectID?
    let bddLength: Int
}

struct TestsFromBDDPromptTrace: Equatable {
    let operation: String
    let ideaID: IdeaID
    let projectID: ProjectID
}
