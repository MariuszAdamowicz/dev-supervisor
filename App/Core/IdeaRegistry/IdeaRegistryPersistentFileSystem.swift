import Foundation

final class IdeaRegistryPersistentFileSystem: IdeaRegistryContract {
    private let storageProfile: StorageProfile
    private let storageRootURL: URL
    private let storageURL: URL
    private let memoryRegistry = IdeaRegistryInMemory()

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

    func selectActiveProject(id: ProjectID?) {
        memoryRegistry.selectActiveProject(id: id)
        persistState()
    }

    func createIdea(title: String, description: String?) -> IdeaCreationResult {
        let result = memoryRegistry.createIdea(title: title, description: description)
        persistState()
        return result
    }

    func updateIdeaContent(id: IdeaID, title: String, description: String?) -> RegistryOperationResult {
        let result = memoryRegistry.updateIdeaContent(id: id, title: title, description: description)
        persistState()
        return result
    }

    func changeIdeaStatus(id: IdeaID, rawStatus: String) -> RegistryOperationResult {
        let result = memoryRegistry.changeIdeaStatus(id: id, rawStatus: rawStatus)
        persistState()
        return result
    }

    func listIdeasForActiveProject() -> IdeaListResult {
        memoryRegistry.listIdeasForActiveProject()
    }

    func idea(by id: IdeaID) -> IdeaRecord? {
        memoryRegistry.idea(by: id)
    }

    private func loadState() {
        switch storageProfile {
        case .fileAI:
            guard let data = try? Data(contentsOf: storageURL),
                  let snapshot = try? JSONDecoder().decode(PersistentIdeaSnapshot.self, from: data)
            else {
                return
            }

            memoryRegistry.restoreState(snapshot.ideaRegistrySnapshot)
        case .sqlbase:
            if let snapshot = try? sqlRegistryStore.loadIdeaSnapshot(storageRoot: storageRootURL) {
                memoryRegistry.restoreState(snapshot)
            }
        }
    }

    private func persistState() {
        let state = memoryRegistry.snapshotState()

        do {
            switch storageProfile {
            case .fileAI:
                try FileManager.default.createDirectory(
                    at: storageURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )

                let encoded = try JSONEncoder().encode(PersistentIdeaSnapshot(snapshot: state))
                try encoded.write(to: storageURL, options: .atomic)
            case .sqlbase:
                try sqlRegistryStore.persistIdeaSnapshot(state, storageRoot: storageRootURL)
            }
        } catch {
            // Persistence failure should not break deterministic in-memory behavior.
        }
    }

    private static func fileName(for storageProfile: StorageProfile) -> String {
        switch storageProfile {
        case .fileAI:
            return "idea-registry-file-ai.json"
        case .sqlbase:
            return "idea-registry-sqlbase.json"
        }
    }

    var sqlRegistryStore: SQLRegistryStore {
        SQLRegistryStore()
    }
}

private struct PersistentIdeaSnapshot: Codable {
    let selectedProjectID: String?
    let ideas: [PersistentIdeaRecord]
    let nextIdeaNumber: Int

    init(snapshot: IdeaRegistryStateSnapshot) {
        selectedProjectID = snapshot.selectedProjectID?.rawValue
        ideas = snapshot.ideas.map {
            PersistentIdeaRecord(
                id: $0.id.rawValue,
                projectID: $0.projectID.rawValue,
                title: $0.title,
                description: $0.description,
                status: $0.status.rawValue
            )
        }
        nextIdeaNumber = snapshot.nextIdeaNumber
    }

    var ideaRegistrySnapshot: IdeaRegistryStateSnapshot {
        let restoredIdeas = ideas.compactMap { record -> IdeaRecord? in
            guard let status = IdeaStatus(rawValue: record.status) else {
                return nil
            }

            return IdeaRecord(
                id: IdeaID(rawValue: record.id),
                projectID: ProjectID(rawValue: record.projectID),
                title: record.title,
                description: record.description,
                status: status
            )
        }

        return IdeaRegistryStateSnapshot(
            selectedProjectID: selectedProjectID.map(ProjectID.init(rawValue:)),
            ideas: restoredIdeas,
            nextIdeaNumber: nextIdeaNumber
        )
    }
}

private struct PersistentIdeaRecord: Codable {
    let id: String
    let projectID: String
    let title: String
    let description: String?
    let status: String
}
