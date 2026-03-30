import Foundation

struct PRDFromFeaturesPromptResult: Equatable {
    let result: RegistryOperationResult
    let promptText: String
    let promptFingerprint: String
    let includesMinimalContext: Bool
    let ideaID: IdeaID?
    let projectID: ProjectID?
    let featuresCount: Int
}

struct PRDFromFeaturesPromptTrace: Equatable {
    let operation: String
    let ideaID: IdeaID
    let projectID: ProjectID
}
