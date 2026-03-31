import Foundation

enum StorageProfile: String, CaseIterable, Equatable {
    case fileAI = "file-ai"
    case sqlbase
}

struct ProjectBootstrapInput: Equatable {
    let projectName: String
    let projectsRootPath: String
    let storageProfile: StorageProfile
    let stackProfile: String
    let architectureProfile: String
    let languageProfile: String
    let executionStyleProfile: String
    let initializeGitRepository: Bool

    init(
        projectName: String,
        projectsRootPath: String,
        storageProfile: StorageProfile,
        stackProfile: String = "macos-swiftui",
        architectureProfile: String = "modular-monolith",
        languageProfile: String = "pl",
        executionStyleProfile: String = "iterative-tdd",
        initializeGitRepository: Bool = true
    ) {
        self.projectName = projectName
        self.projectsRootPath = projectsRootPath
        self.storageProfile = storageProfile
        self.stackProfile = stackProfile
        self.architectureProfile = architectureProfile
        self.languageProfile = languageProfile
        self.executionStyleProfile = executionStyleProfile
        self.initializeGitRepository = initializeGitRepository
    }
}

struct ProjectBootstrapResult: Equatable {
    let result: RegistryOperationResult
    let projectPath: String?
    let createdPaths: [String]
    let warnings: [String]
}

struct ProjectInspectionResult: Equatable {
    let result: RegistryOperationResult
    let projectPath: String
    let hasAI: Bool
    let hasScripts: Bool
    let hasGitRepository: Bool
    let hasOverview: Bool
    let hasConstraints: Bool
    let hasGlossary: Bool
    let productGatePassed: Bool
    let missingProductArtifacts: [String]
    let detectedStorageProfile: StorageProfile?
}
