import Foundation

struct IdeaID: Hashable, Equatable {
    let rawValue: String
}

enum IdeaStatus: String, Equatable {
    case new
    case selected
    case deferred
    case done
}

struct IdeaRecord: Equatable {
    let id: IdeaID
    let projectID: ProjectID
    let title: String
    let description: String?
    let status: IdeaStatus
}

struct IdeaCreationResult: Equatable {
    let result: RegistryOperationResult
    let createdIdeaID: IdeaID?
}

struct IdeaListResult: Equatable {
    let result: RegistryOperationResult
    let ideas: [IdeaRecord]
}
