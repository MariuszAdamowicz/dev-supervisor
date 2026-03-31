import Foundation

enum ArtifactSyncDirection: Equatable {
    case exportAIToSQLBase
    case importSQLBaseToAI
}

struct ArtifactSyncRequest: Equatable {
    let projectPath: String
    let storageProfile: StorageProfile
    let direction: ArtifactSyncDirection
}

struct ArtifactSyncResult: Equatable {
    let result: RegistryOperationResult
    let synchronizedFiles: [String]
}
