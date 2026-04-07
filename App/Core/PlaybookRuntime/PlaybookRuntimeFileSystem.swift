import Foundation

protocol PlaybookGitClient {
    func initializeRepository(at path: String) throws
    func addRemoteOrigin(at path: String, remoteURL: String) throws
}

protocol PlaybookGitHubClient {
    func ensureRepository(named repositoryName: String, visibility: String, defaultBranch: String) throws -> String
}

struct PlaybookRuntimeFileSystem: PlaybookRuntimeContract {
    let fileManager: FileManager
    let gitClient: PlaybookGitClient
    let githubClient: PlaybookGitHubClient
    let now: () -> Date

    init(
        fileManager: FileManager = .default,
        gitClient: PlaybookGitClient = CLIGitClient(),
        githubClient: PlaybookGitHubClient = GitHubCLIClient(),
        now: @escaping () -> Date = Date.init
    ) {
        self.fileManager = fileManager
        self.gitClient = gitClient
        self.githubClient = githubClient
        self.now = now
    }

    func runNewProject(_ request: PlaybookNewProjectRequest) -> PlaybookNewProjectResult {
        do {
            let context = try validateNewProjectRequest(request)
            return try executeNewProject(context)
        } catch {
            let projectPath = request.projectRootPath.trimmingCharacters(in: .whitespacesAndNewlines)
            return failedNewProjectResult(message: error.localizedDescription, projectPath: projectPath)
        }
    }

    func addIdea(_ request: PlaybookAddIdeaRequest) -> PlaybookAddIdeaResult {
        do {
            let context = try validateAddIdeaRequest(request)
            return try executeAddIdea(context)
        } catch {
            let projectPath = request.projectRootPath.trimmingCharacters(in: .whitespacesAndNewlines)
            return failedAddIdeaResult(message: error.localizedDescription, projectPath: projectPath)
        }
    }

    func summarizeRuntime(at projectRootPath: String) -> PlaybookRuntimeSummary {
        let trimmedPath = projectRootPath.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPath.isEmpty else {
            return PlaybookRuntimeSummary(
                projectPath: projectRootPath,
                projectState: nil,
                remoteURL: nil,
                allOps: [],
                processEventCount: 0,
                gateDecisionCount: 0,
                lastEventID: nil
            )
        }

        let projectURL = URL(fileURLWithPath: trimmedPath)
        let summaries = runtimeSummaries(projectRoot: projectURL)
        return PlaybookRuntimeSummary(
            projectPath: trimmedPath,
            projectState: summaries.projectState,
            remoteURL: summaries.remoteURL,
            allOps: summaries.ops.sorted { $0.opID < $1.opID },
            processEventCount: countLines(at: projectURL.appendingPathComponent(".ai/runtime/v1/process-events.ndjson")),
            gateDecisionCount: countLines(at: projectURL.appendingPathComponent(".ai/runtime/v1/gate-decisions.ndjson")),
            lastEventID: summaries.lastEventID
        )
    }
}

private struct RuntimeSummarySnapshot {
    let ops: [PlaybookDerivedOPSummary]
    let projectState: String?
    let remoteURL: String?
    let lastEventID: String?
}

private extension PlaybookRuntimeFileSystem {
    func failedNewProjectResult(message: String, projectPath: String?) -> PlaybookNewProjectResult {
        PlaybookNewProjectResult(
            result: .failure(.init(message: message)),
            projectPath: projectPath?.isEmpty == true ? nil : projectPath,
            projectState: nil,
            remoteURL: nil,
            playbookInstancePath: nil,
            decisionEnvelopePath: nil,
            createdArtifacts: [],
            warnings: []
        )
    }

    func failedAddIdeaResult(message: String, projectPath: String) -> PlaybookAddIdeaResult {
        PlaybookAddIdeaResult(
            result: .failure(.init(message: message)),
            projectPath: projectPath,
            ideaID: nil,
            ideaState: nil,
            decisionEnvelopePath: nil,
            derivedOps: [],
            createdArtifacts: []
        )
    }

    func runtimeSummaries(projectRoot: URL) -> RuntimeSummarySnapshot {
        let opsRoot = projectRoot.appendingPathComponent(".ai/runtime/v1/ops")
        let opDirectories = (try? fileManager.contentsOfDirectory(
            at: opsRoot,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )) ?? []

        var summaries: [PlaybookDerivedOPSummary] = []
        var remoteURL: String?
        var projectState: String?
        var lastEventID: String?

        for opDirectory in opDirectories {
            guard let snapshot = try? latestSnapshot(for: opDirectory.lastPathComponent, projectRoot: projectRoot) else {
                continue
            }

            summaries.append(
                PlaybookDerivedOPSummary(
                    opID: snapshot.opID,
                    opType: snapshot.opType,
                    state: snapshot.state
                )
            )

            guard snapshot.opID == "project.ds" else {
                continue
            }

            projectState = snapshot.state
            lastEventID = snapshot.lastEventID
            if let repository = snapshot.payload?["repository"]?.objectValue,
               let url = repository["remote_url"]?.stringValue,
               !url.isEmpty
            {
                remoteURL = url
            }
        }

        return RuntimeSummarySnapshot(
            ops: summaries,
            projectState: projectState,
            remoteURL: remoteURL,
            lastEventID: lastEventID
        )
    }
}
