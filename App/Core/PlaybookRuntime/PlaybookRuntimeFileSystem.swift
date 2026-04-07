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
                baselineArtifacts: [],
                processEventCount: 0,
                gateDecisionCount: 0,
                evidenceCount: 0,
                lastEvidenceClass: nil,
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
            baselineArtifacts: baselineArtifactStatuses(projectRoot: projectURL),
            processEventCount: summaries.processEventCount,
            gateDecisionCount: summaries.gateDecisionCount,
            evidenceCount: summaries.evidenceCount,
            lastEvidenceClass: summaries.lastEvidenceClass,
            lastEventID: summaries.lastEventID
        )
    }
}

private struct RuntimeSummarySnapshot {
    let ops: [PlaybookDerivedOPSummary]
    let projectState: String?
    let remoteURL: String?
    let processEventCount: Int
    let gateDecisionCount: Int
    let evidenceCount: Int
    let lastEvidenceClass: String?
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
        if isSQLBaseRuntime(projectRoot: projectRoot) {
            do {
                let projectSnapshot = try sqlRuntimeStore.latestSnapshot(for: "project.ds", projectRoot: projectRoot)
                let remoteURL = projectSnapshot?
                    .payload?["repository"]?
                    .objectValue?["remote_url"]?
                    .stringValue

                return try RuntimeSummarySnapshot(
                    ops: sqlRuntimeStore.allOpSummaries(projectRoot: projectRoot),
                    projectState: projectSnapshot?.state,
                    remoteURL: remoteURL?.isEmpty == true ? nil : remoteURL,
                    processEventCount: sqlRuntimeStore.processEventCount(projectRoot: projectRoot),
                    gateDecisionCount: sqlRuntimeStore.gateDecisionCount(projectRoot: projectRoot),
                    evidenceCount: sqlRuntimeStore.evidenceCount(projectRoot: projectRoot),
                    lastEvidenceClass: sqlRuntimeStore.lastEvidenceClass(projectRoot: projectRoot),
                    lastEventID: projectSnapshot?.lastEventID
                )
            } catch {
                return RuntimeSummarySnapshot(
                    ops: [],
                    projectState: nil,
                    remoteURL: nil,
                    processEventCount: 0,
                    gateDecisionCount: 0,
                    evidenceCount: 0,
                    lastEvidenceClass: nil,
                    lastEventID: nil
                )
            }
        }

        let opsRoot = projectRoot.appendingPathComponent(".ai/runtime/v1/ops")
        let opDirectories = (try? fileManager.contentsOfDirectory(
            at: opsRoot,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )) ?? []

        var summaries: [PlaybookDerivedOPSummary] = []
        var remoteURL: String?
        var projectState: String?
        var evidenceCount = 0
        var lastEvidenceClass: String?
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

        let evidenceURL = projectRoot.appendingPathComponent(".ai/runtime/v1/evidence.ndjson")
        if let evidenceText = try? String(contentsOf: evidenceURL, encoding: .utf8) {
            let lines = evidenceText
                .split(whereSeparator: \.isNewline)
                .map(String.init)
                .filter { !$0.isEmpty }
            evidenceCount = lines.count

            if let lastLine = lines.last,
               let data = lastLine.data(using: .utf8),
               let evidence = try? JSONDecoder().decode(RuntimeEvidenceRecord.self, from: data)
            {
                lastEvidenceClass = evidence.evidenceClass
            }
        }

        return RuntimeSummarySnapshot(
            ops: summaries,
            projectState: projectState,
            remoteURL: remoteURL,
            processEventCount: countLines(at: projectRoot.appendingPathComponent(".ai/runtime/v1/process-events.ndjson")),
            gateDecisionCount: countLines(at: projectRoot.appendingPathComponent(".ai/runtime/v1/gate-decisions.ndjson")),
            evidenceCount: evidenceCount,
            lastEvidenceClass: lastEvidenceClass,
            lastEventID: lastEventID
        )
    }

    func baselineArtifactStatuses(projectRoot: URL) -> [PlaybookArtifactStatus] {
        let artifacts: [(String, String)] = [
            (".ai/prd/overview.md", "Overview"),
            (".ai/prd/constraints.md", "Constraints"),
            (".ai/prd/glossary.md", "Glossary"),
            (".ai/adr/0001-project-baseline.md", "ADR"),
            (".ai/architecture/use-cases.md", "Use cases"),
            (".ai/architecture/port-contracts.md", "Port contracts"),
            (".ai/architecture/component-map.md", "Component map"),
            (".ai/ux/new-project.md", "New project UX"),
            (".ai/runtime/v1/op-index.json", "OP index"),
        ]

        return artifacts.map { relativePath, label in
            let url = projectRoot.appendingPathComponent(relativePath)
            return PlaybookArtifactStatus(
                path: url.path,
                label: label,
                exists: fileManager.fileExists(atPath: url.path)
            )
        }
    }
}
