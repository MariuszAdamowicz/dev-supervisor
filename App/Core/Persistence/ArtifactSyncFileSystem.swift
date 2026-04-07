import Foundation

struct ArtifactSyncFileSystem: ArtifactSyncContract {
    private let fileManager: FileManager
    private let sqlProjectStore: SQLProjectStore

    init(fileManager: FileManager = .default, sqlProjectStore: SQLProjectStore = SQLProjectStore()) {
        self.fileManager = fileManager
        self.sqlProjectStore = sqlProjectStore
    }

    func synchronize(_ request: ArtifactSyncRequest) -> ArtifactSyncResult {
        let rootPath = request.projectPath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !rootPath.isEmpty else {
            return ArtifactSyncResult(
                result: .failure(.init(message: "Project path is required for artifact sync.")),
                synchronizedFiles: []
            )
        }

        guard request.storageProfile == .sqlbase else {
            return ArtifactSyncResult(
                result: .failure(.init(message: "Artifact sync is supported only for sqlbase profile.")),
                synchronizedFiles: []
            )
        }

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: rootPath, isDirectory: &isDirectory), isDirectory.boolValue else {
            return ArtifactSyncResult(
                result: .failure(.init(message: "Project path does not exist or is not a directory.")),
                synchronizedFiles: []
            )
        }

        let projectRoot = URL(fileURLWithPath: rootPath)
        switch request.direction {
        case .exportAIToSQLBase:
            return exportAIArtifacts(projectRoot: projectRoot)
        case .importSQLBaseToAI:
            return importSQLArtifacts(projectRoot: projectRoot)
        }
    }

    private func exportAIArtifacts(projectRoot: URL) -> ArtifactSyncResult {
        let aiRoot = projectRoot.appendingPathComponent(".ai")
        guard fileManager.fileExists(atPath: aiRoot.path) else {
            return ArtifactSyncResult(
                result: .failure(.init(message: "Artifact sync failed: .ai directory does not exist.")),
                synchronizedFiles: []
            )
        }

        let enumerator = fileManager.enumerator(
            at: aiRoot,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )

        var synchronized: [String] = []
        do {
            try sqlProjectStore.ensureDatabase(projectRoot: projectRoot)

            while let fileURL = enumerator?.nextObject() as? URL {
                let values = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                guard values.isRegularFile == true else {
                    continue
                }

                try synchronized.append(sqlProjectStore.storeArtifactFile(at: fileURL, projectRoot: projectRoot))
            }
        } catch {
            return ArtifactSyncResult(
                result: .failure(.init(message: "Artifact sync failed: \(error.localizedDescription)")),
                synchronizedFiles: synchronized
            )
        }

        guard !synchronized.isEmpty else {
            return ArtifactSyncResult(
                result: .failure(.init(message: "Artifact sync failed: no .ai artifacts found to export.")),
                synchronizedFiles: []
            )
        }

        return ArtifactSyncResult(result: .success, synchronizedFiles: synchronized)
    }

    private func importSQLArtifacts(projectRoot: URL) -> ArtifactSyncResult {
        do {
            let keys = try sqlProjectStore.artifactKeys(projectRoot: projectRoot)
            guard !keys.isEmpty else {
                return ArtifactSyncResult(
                    result: .failure(.init(message: "Artifact sync failed: sqlbase does not contain stored artifacts.")),
                    synchronizedFiles: []
                )
            }

            let synchronized = try keys.map {
                try sqlProjectStore.materializeArtifact(relativePath: $0, projectRoot: projectRoot)
            }
            return ArtifactSyncResult(result: .success, synchronizedFiles: synchronized)
        } catch {
            return ArtifactSyncResult(
                result: .failure(.init(message: "Artifact sync failed: \(error.localizedDescription)")),
                synchronizedFiles: []
            )
        }
    }
}
