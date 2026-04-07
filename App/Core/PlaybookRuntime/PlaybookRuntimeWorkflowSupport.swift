import Foundation

struct NewProjectContext {
    let request: PlaybookNewProjectRequest
    let projectName: String
    let projectDescription: String
    let projectURL: URL
}

struct NewProjectSetup {
    let remoteURL: String?
    let playbookInstancePath: String
    let createdArtifacts: [String]
    let warnings: [String]
}

struct IdeaContext {
    let request: PlaybookAddIdeaRequest
    let projectPath: String
    let ideaTitle: String
    let ideaDescription: String
    let projectURL: URL
}

struct DerivedIdeaArtifacts {
    let createdArtifacts: [String]
    let derivedOps: [PlaybookDerivedOPSummary]
}

extension PlaybookRuntimeFileSystem {
    func validateNewProjectRequest(_ request: PlaybookNewProjectRequest) throws -> NewProjectContext {
        let projectName = try requireNonEmpty(request.projectName, message: "Project name is required.")
        let projectPath = try requireNonEmpty(request.projectRootPath, message: "Project path is required.")
        let projectDescription = try requireNonEmpty(request.projectDescription, message: "Project overview is required.")
        _ = try requireNonEmpty(request.baselineGate.reason, message: "Baseline gate reason is required.")

        return NewProjectContext(
            request: request,
            projectName: projectName,
            projectDescription: projectDescription,
            projectURL: URL(fileURLWithPath: projectPath)
        )
    }

    func validateAddIdeaRequest(_ request: PlaybookAddIdeaRequest) throws -> IdeaContext {
        let projectPath = try requireNonEmpty(request.projectRootPath, message: "Project path is required.")
        let ideaTitle = try requireNonEmpty(request.ideaTitle, message: "Idea title is required.")
        _ = try requireNonEmpty(request.convertGate.reason, message: "Idea convert gate reason is required.")

        return IdeaContext(
            request: request,
            projectPath: projectPath,
            ideaTitle: ideaTitle,
            ideaDescription: request.ideaDescription.trimmingCharacters(in: .whitespacesAndNewlines),
            projectURL: URL(fileURLWithPath: projectPath)
        )
    }

    func executeNewProject(_ context: NewProjectContext) throws -> PlaybookNewProjectResult {
        let setup = try prepareNewProjectSetup(context)
        let envelopePath = try configureNewProjectRuntime(context, setup: setup)
        let summary = summarizeRuntime(at: context.projectURL.path)

        return PlaybookNewProjectResult(
            result: .success,
            projectPath: context.projectURL.path,
            projectState: summary.projectState,
            remoteURL: summary.remoteURL,
            playbookInstancePath: setup.playbookInstancePath,
            decisionEnvelopePath: envelopePath,
            createdArtifacts: (setup.createdArtifacts + [envelopePath]).sorted(),
            warnings: setup.warnings
        )
    }

    func executeAddIdea(_ context: IdeaContext) throws -> PlaybookAddIdeaResult {
        try requireActiveProject(at: context.projectURL)
        let ideaID = nextSequentialOpID(prefix: "idea", projectRoot: context.projectURL)

        try createIdeaInstance(context, ideaID: ideaID)
        let derivedArtifacts = try createDerivedArtifacts(for: context, ideaID: ideaID)
        let envelopePath = try writeIdeaEnvelope(for: context, ideaID: ideaID, derivedArtifacts: derivedArtifacts)
        let ideaSnapshot = try applyIdeaDecision(context, ideaID: ideaID)

        return PlaybookAddIdeaResult(
            result: .success,
            projectPath: context.projectPath,
            ideaID: ideaID,
            ideaState: ideaSnapshot.state,
            decisionEnvelopePath: envelopePath,
            derivedOps: derivedArtifacts.derivedOps.sorted { $0.opID < $1.opID },
            createdArtifacts: (derivedArtifacts.createdArtifacts + [envelopePath]).sorted()
        )
    }
}

private extension PlaybookRuntimeFileSystem {
    func requireNonEmpty(_ value: String, message: String) throws -> String {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw RuntimeError(message: message)
        }
        return trimmed
    }

    func prepareNewProjectSetup(_ context: NewProjectContext) throws -> NewProjectSetup {
        try ensureProjectDirectoryReady(context.projectURL)

        var createdArtifacts = try createProjectScaffold(context.projectURL, request: context.request)
        try gitClient.initializeRepository(at: context.projectURL.path)
        createdArtifacts.append(context.projectURL.appendingPathComponent(".git").path)

        let remoteSetup = try prepareRemoteRepository(context)
        let playbookInstancePath = try writePlaybookInstance(
            at: context.projectURL,
            projectName: context.projectName,
            profile: context.request.profileSelection
        )
        createdArtifacts.append(playbookInstancePath)

        return NewProjectSetup(
            remoteURL: remoteSetup.remoteURL,
            playbookInstancePath: playbookInstancePath,
            createdArtifacts: createdArtifacts,
            warnings: remoteSetup.warnings
        )
    }

    func prepareRemoteRepository(_ context: NewProjectContext) throws -> (remoteURL: String?, warnings: [String]) {
        guard context.request.createRemoteRepository else {
            return (nil, ["Remote GitHub repository creation skipped."])
        }

        let repositoryName = slugify(context.projectName)
        let remoteURL = try githubClient.ensureRepository(
            named: repositoryName,
            visibility: "private",
            defaultBranch: "main"
        )
        try gitClient.addRemoteOrigin(at: context.projectURL.path, remoteURL: remoteURL)
        return (remoteURL, [])
    }

    func configureNewProjectRuntime(_ context: NewProjectContext, setup: NewProjectSetup) throws -> String {
        let projectLinks = [RuntimeLink(rel: "playbook_instance", target: setup.playbookInstancePath)] + remoteRepositoryLinks(setup.remoteURL)
        try createProjectOp(context, links: projectLinks, remoteURL: setup.remoteURL)
        try moveProjectToConfigured(projectRoot: context.projectURL)

        let envelopePath = try writeBaselineEnvelope(for: context, remoteURL: setup.remoteURL)
        try applyBaselineDecision(context, projectRoot: context.projectURL)
        try activateProjectIfApproved(context, projectRoot: context.projectURL)
        return envelopePath
    }

    func createProjectOp(_ context: NewProjectContext, links: [RuntimeLink], remoteURL: String?) throws {
        let payload = projectPayload(for: context, remoteURL: remoteURL)
        let request = RuntimeCreateOpRequest(
            opID: "project.ds",
            opType: "Project",
            state: "created",
            owner: "operator",
            links: links,
            tags: [
                "entrypoint:new_project",
                "stack:\(context.request.profileSelection.stack)",
                "storage:\(context.request.profileSelection.storage.rawValue)",
            ],
            payload: payload,
            actor: "system:dev-supervisor"
        )
        _ = try createOpInstance(request, projectRoot: context.projectURL)
    }

    func projectPayload(for context: NewProjectContext, remoteURL: String?) -> [String: JSONValue] {
        [
            "name": .string(context.projectName),
            "description": .string(context.projectDescription),
            "selected_profiles": .object([
                "stack": .string(context.request.profileSelection.stack),
                "architecture": .string(context.request.profileSelection.architecture),
                "language": .string(context.request.profileSelection.language),
                "execution_style": .string(context.request.profileSelection.executionStyle),
                "storage": .string(context.request.profileSelection.storage.rawValue),
            ]),
            "repository": .object([
                "local_path": .string(context.projectURL.path),
                "remote_url": remoteURL.map(JSONValue.string) ?? .null,
                "visibility": .string("private"),
                "default_branch": .string("main"),
            ]),
        ]
    }

    func moveProjectToConfigured(projectRoot: URL) throws {
        let request = RuntimeTransitionRequest(
            opID: "project.ds",
            expectedFromState: "created",
            event: "project.configure-requested",
            toState: "configured",
            actor: "system:dev-supervisor"
        )
        _ = try applyTransition(request, projectRoot: projectRoot)
    }

    func writeBaselineEnvelope(for context: NewProjectContext, remoteURL: String?) throws -> String {
        let envelope = RuntimeDecisionEnvelope(
            transitionRef: "Project.configured -> Project.\(context.request.baselineGate.decision.targetProjectState)",
            currentState: "configured",
            targetState: context.request.baselineGate.decision.targetProjectState,
            preconditions: [
                RuntimeEnvelopeCondition(name: "overview_exists", passed: true, detail: ".ai/prd/overview.md"),
                RuntimeEnvelopeCondition(name: "constraints_exists", passed: true, detail: ".ai/prd/constraints.md"),
                RuntimeEnvelopeCondition(name: "glossary_exists", passed: true, detail: ".ai/prd/glossary.md"),
                RuntimeEnvelopeCondition(name: "authz_precheck", passed: true, detail: "operator-ui actor accepted"),
            ],
            scope: "Baseline projektu i przejscie Project.configured -> \(context.request.baselineGate.decision.targetProjectState).",
            changeSet: baselineChangeSet(projectRoot: context.projectURL),
            validation: RuntimeEnvelopeValidation(
                buildStatus: "not_run",
                testStatus: "not_run",
                lintStatus: "not_run",
                qualitySignal: "pass",
                reportRef: "bootstrap:new_project"
            ),
            traceability: [
                "overview -> .ai/prd/overview.md",
                "constraints -> .ai/prd/constraints.md",
                "glossary -> .ai/prd/glossary.md",
            ],
            risks: remoteURL == nil ? ["remote_repository_not_connected"] : [],
            rollbackOrReworkPlan: [
                "approve -> aktywacja projektu",
                "request_changes -> pozostanie w configured i korekta baseline",
                "defer -> pozostanie w configured bez aktywacji",
                "reject -> archiwizacja projektu",
            ],
            decisionOptions: PlaybookGateDecision.allCases.map(\.rawValue),
            decisionEffects: [
                "approve": "Project przejdzie do baseline-approved, a nastepnie do active.",
                "request_changes": "Project pozostanie w configured.",
                "defer": "Project pozostanie w configured.",
                "reject": "Project przejdzie do archived.",
            ],
            requiredActor: context.request.baselineGate.actor,
            auditRefs: []
        )

        return try writeDecisionEnvelope(
            projectRoot: context.projectURL,
            opID: "project.ds",
            sequence: latestVersion(for: "project.ds", projectRoot: context.projectURL) + 1,
            envelope: envelope
        )
    }

    func applyBaselineDecision(_ context: NewProjectContext, projectRoot: URL) throws {
        let request = RuntimeTransitionRequest(
            opID: "project.ds",
            expectedFromState: "configured",
            event: "project.baseline-approve-requested",
            toState: context.request.baselineGate.decision.targetProjectState,
            actor: "system:dev-supervisor",
            gate: context.request.baselineGate
        )
        _ = try applyTransition(request, projectRoot: projectRoot)
    }

    func activateProjectIfApproved(_ context: NewProjectContext, projectRoot: URL) throws {
        guard context.request.baselineGate.decision == .approve else {
            return
        }

        let request = RuntimeTransitionRequest(
            opID: "project.ds",
            expectedFromState: "baseline-approved",
            event: "project.activate-requested",
            toState: "active",
            actor: "system:dev-supervisor"
        )
        _ = try applyTransition(request, projectRoot: projectRoot)
    }

    func requireActiveProject(at projectRoot: URL) throws {
        guard let projectSnapshot = try latestSnapshot(for: "project.ds", projectRoot: projectRoot) else {
            throw RuntimeError(message: "Project runtime does not contain project.ds.")
        }

        guard projectSnapshot.state == "active" else {
            throw RuntimeError(message: "Project must be active before adding an idea.")
        }
    }

    func createIdeaInstance(_ context: IdeaContext, ideaID: String) throws {
        let request = RuntimeCreateOpRequest(
            opID: ideaID,
            opType: "Idea",
            state: "captured",
            owner: "operator",
            links: [RuntimeLink(rel: "parent", target: "project.ds")],
            tags: ["entrypoint:add_idea"],
            payload: [
                "title": .string(context.ideaTitle),
                "description": .string(context.ideaDescription),
                "source_project": .string("project.ds"),
            ],
            actor: "operator:local"
        )
        _ = try createOpInstance(request, projectRoot: context.projectURL)

        let transition = RuntimeTransitionRequest(
            opID: ideaID,
            expectedFromState: "captured",
            event: "idea.scope-requested",
            toState: "scoped",
            actor: "system:dev-supervisor"
        )
        _ = try applyTransition(transition, projectRoot: context.projectURL)
    }

    func createDerivedArtifacts(for context: IdeaContext, ideaID: String) throws -> DerivedIdeaArtifacts {
        let definitions = buildDerivedDefinitions(for: context.ideaTitle, description: context.ideaDescription, ideaID: ideaID)
        var derivedOps: [PlaybookDerivedOPSummary] = []

        for definition in definitions {
            let request = RuntimeCreateOpRequest(
                opID: definition.opID,
                opType: definition.opType,
                state: definition.initialState,
                owner: "operator",
                links: definition.links,
                tags: definition.tags,
                payload: definition.payload,
                actor: "system:dev-supervisor"
            )
            _ = try createOpInstance(request, projectRoot: context.projectURL)
            derivedOps.append(
                PlaybookDerivedOPSummary(
                    opID: definition.opID,
                    opType: definition.opType,
                    state: definition.initialState
                )
            )
        }

        let files = try writeFeatureArtifacts(
            projectRoot: context.projectURL,
            ideaTitle: context.ideaTitle,
            ideaDescription: context.ideaDescription,
            derivedOps: derivedOps
        )

        return DerivedIdeaArtifacts(createdArtifacts: files, derivedOps: derivedOps)
    }

    func writeIdeaEnvelope(
        for context: IdeaContext,
        ideaID: String,
        derivedArtifacts: DerivedIdeaArtifacts
    ) throws -> String {
        let envelope = RuntimeDecisionEnvelope(
            transitionRef: "Idea.scoped -> Idea.\(context.request.convertGate.decision.targetIdeaState)",
            currentState: "scoped",
            targetState: context.request.convertGate.decision.targetIdeaState,
            preconditions: [
                RuntimeEnvelopeCondition(name: "project_active", passed: true, detail: "project.ds.state=active"),
                RuntimeEnvelopeCondition(name: "authz_precheck", passed: true, detail: "operator-ui actor accepted"),
            ],
            scope: "Konwersja pierwszej idei i wygenerowanie pochodnych OP.",
            changeSet: derivedArtifacts.derivedOps.map { "created_op:\($0.opType):\($0.opID)" }
                + derivedArtifacts.createdArtifacts.map { "created_file:\($0)" },
            validation: RuntimeEnvelopeValidation(
                buildStatus: "not_run",
                testStatus: "not_run",
                lintStatus: "not_run",
                qualitySignal: "pass",
                reportRef: "runtime:add_idea"
            ),
            traceability: [
                "Idea -> Feature",
                "Idea -> Requirement",
                "Idea -> Term",
                "Idea -> PromptTask",
            ],
            risks: [],
            rollbackOrReworkPlan: [
                "approve -> Idea przejdzie do converted.",
                "request_changes -> Idea pozostanie w scoped i zachowa pochodne OP.",
                "defer -> Idea pozostanie w scoped.",
                "reject -> Idea przejdzie do dropped, pochodne OP pozostana do rewizji.",
            ],
            decisionOptions: PlaybookGateDecision.allCases.map(\.rawValue),
            decisionEffects: [
                "approve": "Idea przejdzie do converted.",
                "request_changes": "Idea pozostanie w scoped.",
                "defer": "Idea pozostanie w scoped.",
                "reject": "Idea przejdzie do dropped.",
            ],
            requiredActor: context.request.convertGate.actor,
            auditRefs: []
        )

        return try writeDecisionEnvelope(
            projectRoot: context.projectURL,
            opID: ideaID,
            sequence: latestVersion(for: ideaID, projectRoot: context.projectURL) + 1,
            envelope: envelope
        )
    }

    func applyIdeaDecision(_ context: IdeaContext, ideaID: String) throws -> RuntimeOpSnapshot {
        let request = RuntimeTransitionRequest(
            opID: ideaID,
            expectedFromState: "scoped",
            event: "idea.convert-requested",
            toState: context.request.convertGate.decision.targetIdeaState,
            actor: "system:dev-supervisor",
            gate: context.request.convertGate
        )
        return try applyTransition(request, projectRoot: context.projectURL)
    }
}
