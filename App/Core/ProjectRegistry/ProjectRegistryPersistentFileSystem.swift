import Foundation

final class ProjectRegistryPersistentFileSystem: ProjectRegistryContract {
    private let storageProfile: StorageProfile
    private let storageRootURL: URL
    private let storageURL: URL
    private let memoryRegistry = ProjectRegistryInMemory()

    nonisolated deinit {}

    init(storageProfile: StorageProfile, storageRootPath: String? = nil) {
        self.storageProfile = storageProfile
        if let storageRootPath {
            storageRootURL = URL(fileURLWithPath: storageRootPath)
        } else {
            storageRootURL = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".dev-supervisor/registry", isDirectory: true)
        }
        storageURL = storageRootURL.appendingPathComponent(Self.fileName(for: storageProfile))

        loadState()
    }

    func registerProject(name: String, localPath: String) -> ProjectRegistrationResult {
        let result = memoryRegistry.registerProject(name: name, localPath: localPath)
        persistState()
        return result
    }

    func listProjects() -> [ProjectRecord] {
        memoryRegistry.listProjects()
    }

    func project(by id: ProjectID) -> ProjectRecord? {
        memoryRegistry.project(by: id)
    }

    func updateProjectMetadata(id: ProjectID, name: String?, localPath: String?) -> RegistryOperationResult {
        let result = memoryRegistry.updateProjectMetadata(id: id, name: name, localPath: localPath)
        persistState()
        return result
    }

    func archiveProject(id: ProjectID) -> RegistryOperationResult {
        let result = memoryRegistry.archiveProject(id: id)
        persistState()
        return result
    }

    func reactivateProject(id: ProjectID) -> RegistryOperationResult {
        let result = memoryRegistry.reactivateProject(id: id)
        persistState()
        return result
    }

    func selectActiveWorkingProject(id: ProjectID) -> RegistryOperationResult {
        let result = memoryRegistry.selectActiveWorkingProject(id: id)
        persistState()
        return result
    }

    func activeWorkingProjectID() -> ProjectID? {
        memoryRegistry.activeWorkingProjectID()
    }

    func performFeatureLevelOperation() -> RegistryOperationResult {
        memoryRegistry.performFeatureLevelOperation()
    }

    func performPathRequiredOperation(for id: ProjectID) -> RegistryOperationResult {
        memoryRegistry.performPathRequiredOperation(for: id)
    }

    func seedScopedData(for id: ProjectID, data: ProjectScopedData) {
        memoryRegistry.seedScopedData(for: id, data: data)
        persistState()
    }

    func scopedData(for id: ProjectID) -> ProjectScopedData? {
        memoryRegistry.scopedData(for: id)
    }

    func setPathAvailability(for id: ProjectID, isAvailable: Bool) {
        memoryRegistry.setPathAvailability(for: id, isAvailable: isAvailable)
        persistState()
    }

    private func loadState() {
        switch storageProfile {
        case .fileAI:
            guard let data = try? Data(contentsOf: storageURL),
                  let snapshot = try? JSONDecoder().decode(PersistentSnapshot.self, from: data)
            else {
                return
            }

            memoryRegistry.restoreState(snapshot.projectRegistrySnapshot)
        case .sqlbase:
            if let snapshot = try? sqlRegistryStore.loadProjectSnapshot(storageRoot: storageRootURL) {
                memoryRegistry.restoreState(snapshot)
            }
        }
    }

    private func persistState() {
        let snapshot = memoryRegistry.snapshotState()

        do {
            switch storageProfile {
            case .fileAI:
                try FileManager.default.createDirectory(
                    at: storageURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )

                let encoded = try JSONEncoder().encode(PersistentSnapshot(snapshot: snapshot))
                try encoded.write(to: storageURL, options: .atomic)
            case .sqlbase:
                try sqlRegistryStore.persistProjectSnapshot(snapshot, storageRoot: storageRootURL)
            }
        } catch {
            // Persistence failure should not break deterministic in-memory behavior.
        }
    }

    private static func fileName(for storageProfile: StorageProfile) -> String {
        switch storageProfile {
        case .fileAI:
            return "project-registry-file-ai.json"
        case .sqlbase:
            return "project-registry-sqlbase.json"
        }
    }

    var sqlRegistryStore: SQLRegistryStore {
        SQLRegistryStore()
    }
}

private struct PersistentSnapshot: Codable {
    let activeProjectID: String?
    let projects: [PersistentProjectRecord]
    let scopedData: [PersistentScopedData]
    let nextProjectNumber: Int

    init(snapshot: ProjectRegistryStateSnapshot) {
        activeProjectID = snapshot.selectedProjectID?.rawValue
        projects = snapshot.projects.map {
            PersistentProjectRecord(
                id: $0.id.rawValue,
                name: $0.name,
                localPath: $0.localPath,
                status: PersistentProjectStatus(from: $0.status),
                history: $0.history,
                pathAvailable: snapshot.pathAvailabilityByProjectID[$0.id] ?? true
            )
        }
        scopedData = snapshot.projects.compactMap { project in
            guard let scopedData = snapshot.scopedDataByProjectID[project.id] else {
                return nil
            }

            return PersistentScopedData(
                id: project.id.rawValue,
                ideas: scopedData.ideas,
                features: scopedData.features,
                progress: scopedData.progress,
                metadata: scopedData.metadata
            )
        }
        nextProjectNumber = snapshot.nextProjectNumber
    }

    var projectRegistrySnapshot: ProjectRegistryStateSnapshot {
        let scopedDataByProjectID = Dictionary(
            uniqueKeysWithValues: scopedData.map {
                (
                    ProjectID(rawValue: $0.id),
                    ProjectScopedData(
                        ideas: $0.ideas,
                        features: $0.features,
                        progress: $0.progress,
                        metadata: $0.metadata
                    )
                )
            }
        )
        let projects = self.projects.map {
            ProjectRecord(
                id: ProjectID(rawValue: $0.id),
                name: $0.name,
                localPath: $0.localPath,
                status: $0.status.projectStatus,
                history: $0.history
            )
        }
        let pathAvailability = Dictionary(
            uniqueKeysWithValues: self.projects.map {
                (ProjectID(rawValue: $0.id), $0.pathAvailable)
            }
        )

        return ProjectRegistryStateSnapshot(
            selectedProjectID: activeProjectID.map(ProjectID.init(rawValue:)),
            projects: projects,
            scopedDataByProjectID: scopedDataByProjectID,
            pathAvailabilityByProjectID: pathAvailability,
            nextProjectNumber: nextProjectNumber
        )
    }
}

private struct PersistentProjectRecord: Codable {
    let id: String
    let name: String
    let localPath: String
    let status: PersistentProjectStatus
    let history: [String]
    let pathAvailable: Bool
}

private struct PersistentScopedData: Codable {
    let id: String
    let ideas: [String]
    let features: [String]
    let progress: [String]
    let metadata: [String: String]
}

private enum PersistentProjectStatus: String, Codable {
    case active
    case archived

    init(from status: ProjectStatus) {
        switch status {
        case .active:
            self = .active
        case .archived:
            self = .archived
        }
    }

    var projectStatus: ProjectStatus {
        switch self {
        case .active:
            return .active
        case .archived:
            return .archived
        }
    }
}
