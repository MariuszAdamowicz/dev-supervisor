import Foundation

struct FeatureCandidate: Equatable {
    let key: String
    let name: String
    let description: String
}

struct FeatureSetPromptGenerationResult: Equatable {
    let result: RegistryOperationResult
    let promptText: String
    let promptFingerprint: String
    let includesMinimalContext: Bool
    let ideaID: IdeaID?
    let projectID: ProjectID?
    let proposedFeatures: [FeatureCandidate]
}

struct FeatureSetPromptGenerationTrace: Equatable {
    let operation: String
    let ideaID: IdeaID
    let projectID: ProjectID
}
