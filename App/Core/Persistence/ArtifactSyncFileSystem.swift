import Foundation

struct ArtifactSyncFileSystem: ArtifactSyncContract {
    private typealias Mapping = (aiRelative: String, sqlRelative: String)

    private let mappings: [Mapping] = [
        (".ai/prd/overview.md", "State/sqlbase/prd/overview.md"),
        (".ai/prd/constraints.md", "State/sqlbase/prd/constraints.md"),
        (".ai/prd/glossary.md", "State/sqlbase/prd/glossary.md"),
        (".ai/ideas.md", "State/sqlbase/ideas.md"),
        (".ai/project-profile.json", "State/sqlbase/project-profile.json"),
    ]

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
        guard FileManager.default.fileExists(atPath: rootPath, isDirectory: &isDirectory), isDirectory.boolValue else {
            return ArtifactSyncResult(
                result: .failure(.init(message: "Project path does not exist or is not a directory.")),
                synchronizedFiles: []
            )
        }

        switch request.direction {
        case .exportAIToSQLBase:
            return copyArtifacts(projectRoot: rootPath, direction: .exportAIToSQLBase)
        case .importSQLBaseToAI:
            return copyArtifacts(projectRoot: rootPath, direction: .importSQLBaseToAI)
        }
    }

    private func copyArtifacts(projectRoot: String, direction: ArtifactSyncDirection) -> ArtifactSyncResult {
        var missing: [String] = []
        var synchronized: [String] = []

        for mapping in mappings {
            let sourceRelative: String
            let destinationRelative: String

            switch direction {
            case .exportAIToSQLBase:
                sourceRelative = mapping.aiRelative
                destinationRelative = mapping.sqlRelative
            case .importSQLBaseToAI:
                sourceRelative = mapping.sqlRelative
                destinationRelative = mapping.aiRelative
            }

            let sourceURL = URL(fileURLWithPath: projectRoot).appendingPathComponent(sourceRelative)
            let destinationURL = URL(fileURLWithPath: projectRoot).appendingPathComponent(destinationRelative)

            guard FileManager.default.fileExists(atPath: sourceURL.path) else {
                missing.append(sourceRelative)
                continue
            }

            do {
                try FileManager.default.createDirectory(
                    at: destinationURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )

                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }

                try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
                synchronized.append(destinationRelative)
            } catch {
                return ArtifactSyncResult(
                    result: .failure(.init(message: "Artifact sync failed: \(error.localizedDescription)")),
                    synchronizedFiles: synchronized
                )
            }
        }

        guard missing.isEmpty else {
            return ArtifactSyncResult(
                result: .failure(.init(message: "Artifact sync failed: missing source files: \(missing.joined(separator: ", ")).")),
                synchronizedFiles: synchronized
            )
        }

        return ArtifactSyncResult(result: .success, synchronizedFiles: synchronized)
    }
}
