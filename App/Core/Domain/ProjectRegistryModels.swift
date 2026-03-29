import Foundation

struct ProjectID: Hashable, Equatable {
    let rawValue: String
}

enum ProjectStatus: Equatable {
    case active
    case archived
}

struct ProjectRecord: Equatable {
    let id: ProjectID
    let name: String
    let localPath: String
    let status: ProjectStatus
    let history: [String]
}

struct ProjectScopedData: Equatable {
    let ideas: [String]
    let features: [String]
    let progress: [String]
    let metadata: [String: String]
}

struct ProjectRegistrationResult: Equatable {
    let result: RegistryOperationResult
    let createdProjectID: ProjectID?
}

enum RegistryOperationResult: Equatable {
    case success
    case failure(RegistryFailureReason)

    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
}

struct RegistryFailureReason: Equatable {
    let message: String
}
