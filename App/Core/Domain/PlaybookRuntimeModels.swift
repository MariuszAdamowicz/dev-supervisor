import Foundation

struct PlaybookProfileSelection: Equatable {
    let stack: String
    let architecture: String
    let language: String
    let executionStyle: String
    let storage: StorageProfile

    init(
        stack: String = "macos-swiftui",
        architecture: String = "modular-monolith",
        language: String = "pl",
        executionStyle: String = "iterative-tdd",
        storage: StorageProfile = .fileAI
    ) {
        self.stack = stack
        self.architecture = architecture
        self.language = language
        self.executionStyle = executionStyle
        self.storage = storage
    }
}

enum PlaybookGateDecision: String, CaseIterable, Equatable, Identifiable {
    case approve
    case requestChanges = "request_changes"
    case `defer`
    case reject

    var id: String {
        rawValue
    }

    var targetProjectState: String {
        switch self {
        case .approve:
            return "baseline-approved"
        case .requestChanges, .defer:
            return "configured"
        case .reject:
            return "archived"
        }
    }

    var targetIdeaState: String {
        switch self {
        case .approve:
            return "converted"
        case .requestChanges, .defer:
            return "scoped"
        case .reject:
            return "dropped"
        }
    }

    var label: String {
        switch self {
        case .approve:
            return "approve"
        case .requestChanges:
            return "request_changes"
        case .defer:
            return "defer"
        case .reject:
            return "reject"
        }
    }
}

struct PlaybookGateInput: Equatable {
    let decision: PlaybookGateDecision
    let reason: String
    let actor: String

    init(
        decision: PlaybookGateDecision,
        reason: String,
        actor: String = "operator:local"
    ) {
        self.decision = decision
        self.reason = reason
        self.actor = actor
    }
}

struct PlaybookNewProjectRequest: Equatable {
    let projectName: String
    let projectRootPath: String
    let profileSelection: PlaybookProfileSelection
    let projectDescription: String
    let baselineGate: PlaybookGateInput
    let createRemoteRepository: Bool

    init(
        projectName: String,
        projectRootPath: String,
        profileSelection: PlaybookProfileSelection = PlaybookProfileSelection(),
        projectDescription: String,
        baselineGate: PlaybookGateInput,
        createRemoteRepository: Bool = true
    ) {
        self.projectName = projectName
        self.projectRootPath = projectRootPath
        self.profileSelection = profileSelection
        self.projectDescription = projectDescription
        self.baselineGate = baselineGate
        self.createRemoteRepository = createRemoteRepository
    }
}

struct PlaybookNewProjectResult: Equatable {
    let result: RegistryOperationResult
    let projectPath: String?
    let projectState: String?
    let remoteURL: String?
    let playbookInstancePath: String?
    let decisionEnvelopePath: String?
    let createdArtifacts: [String]
    let warnings: [String]
}

struct PlaybookAddIdeaRequest: Equatable {
    let projectRootPath: String
    let ideaTitle: String
    let ideaDescription: String
    let convertGate: PlaybookGateInput
}

struct PlaybookDerivedOPSummary: Equatable, Identifiable {
    let opID: String
    let opType: String
    let state: String

    var id: String {
        opID
    }
}

struct PlaybookArtifactStatus: Equatable, Identifiable {
    let path: String
    let label: String
    let exists: Bool

    var id: String {
        path
    }
}

struct PlaybookAddIdeaResult: Equatable {
    let result: RegistryOperationResult
    let projectPath: String
    let ideaID: String?
    let ideaState: String?
    let decisionEnvelopePath: String?
    let derivedOps: [PlaybookDerivedOPSummary]
    let createdArtifacts: [String]
}

struct PlaybookRuntimeSummary: Equatable {
    let projectPath: String
    let projectState: String?
    let remoteURL: String?
    let allOps: [PlaybookDerivedOPSummary]
    let baselineArtifacts: [PlaybookArtifactStatus]
    let processEventCount: Int
    let gateDecisionCount: Int
    let evidenceCount: Int
    let lastEvidenceClass: String?
    let lastEventID: String?
}
