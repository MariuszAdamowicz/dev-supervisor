import Foundation

final class ProjectRegistryPersistentFileSystem: ProjectRegistryContract {
    private let storageURL: URL
    private let memoryRegistry = ProjectRegistryInMemory()

    nonisolated deinit {}

    init(storageProfile: StorageProfile, storageRootPath: String? = nil) {
        if let storageRootPath {
            let root = URL(fileURLWithPath: storageRootPath)
            storageURL = root.appendingPathComponent(Self.fileName(for: storageProfile))
        } else {
            let root = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent(".dev-supervisor/registry", isDirectory: true)
            storageURL = root.appendingPathComponent(Self.fileName(for: storageProfile))
        }

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
        guard let data = try? Data(contentsOf: storageURL),
              let snapshot = try? JSONDecoder().decode(PersistentSnapshot.self, from: data)
        else {
            return
        }

        var idMapping: [String: ProjectID] = [:]

        for record in snapshot.projects {
            let registration = memoryRegistry.registerProject(name: record.name, localPath: record.localPath)
            guard let newID = registration.createdProjectID else {
                continue
            }

            idMapping[record.id] = newID

            if record.status == .archived {
                _ = memoryRegistry.archiveProject(id: newID)
            }
        }

        for scoped in snapshot.scopedData {
            guard let mappedID = idMapping[scoped.id] else {
                continue
            }

            memoryRegistry.seedScopedData(
                for: mappedID,
                data: ProjectScopedData(
                    ideas: scoped.ideas,
                    features: scoped.features,
                    progress: scoped.progress,
                    metadata: scoped.metadata
                )
            )
        }

        if let activeID = snapshot.activeProjectID,
           let mappedActiveID = idMapping[activeID]
        {
            _ = memoryRegistry.selectActiveWorkingProject(id: mappedActiveID)
        }
    }

    private func persistState() {
        let snapshot = PersistentSnapshot(
            activeProjectID: memoryRegistry.activeWorkingProjectID()?.rawValue,
            projects: memoryRegistry.listProjects().map {
                PersistentProjectRecord(
                    id: $0.id.rawValue,
                    name: $0.name,
                    localPath: $0.localPath,
                    status: PersistentProjectStatus(from: $0.status)
                )
            },
            scopedData: memoryRegistry.listProjects().compactMap { project in
                guard let scopedData = memoryRegistry.scopedData(for: project.id) else {
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
        )

        do {
            try FileManager.default.createDirectory(
                at: storageURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            let encoded = try JSONEncoder().encode(snapshot)
            try encoded.write(to: storageURL, options: .atomic)
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
}

private struct PersistentSnapshot: Codable {
    let activeProjectID: String?
    let projects: [PersistentProjectRecord]
    let scopedData: [PersistentScopedData]
}

private struct PersistentProjectRecord: Codable {
    let id: String
    let name: String
    let localPath: String
    let status: PersistentProjectStatus
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
}
