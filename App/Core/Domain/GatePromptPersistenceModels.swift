import Foundation

struct GatePromptPersistenceRequest: Equatable {
    let projectPath: String
    let storageProfile: StorageProfile
    let operation: String
    let ideaID: IdeaID?
    let projectID: ProjectID?
    let promptText: String
}

struct GatePromptPersistenceResult: Equatable {
    let result: RegistryOperationResult
    let persistedPath: String?
}
