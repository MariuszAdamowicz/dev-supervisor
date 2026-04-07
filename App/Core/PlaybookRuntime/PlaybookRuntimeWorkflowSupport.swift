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
        try recordPolicyEvent(
            opID: "project.ds",
            opType: "Project",
            eventType: "policy.authorized",
            actor: context.request.convertGate.actor,
            detail: "Operator moze uruchomic add_idea dla aktywnego projektu.",
            idempotencyKey: "project.ds|policy-authorized|add-idea",
            projectRoot: context.projectURL
        )
        let ideaID = nextSequentialOpID(prefix: "idea", projectRoot: context.projectURL)

        try createIdeaInstance(context, ideaID: ideaID)
        try recordPolicyEvent(
            opID: ideaID,
            opType: "Idea",
            eventType: "policy.semantics_validated",
            actor: "policy-engine",
            detail: "Idea ma aktywny parent project.ds i moze przejsc do scoped.",
            idempotencyKey: "\(ideaID)|policy-semantics|add-idea",
            projectRoot: context.projectURL
        )
        let derivedArtifacts = try createDerivedArtifacts(for: context, ideaID: ideaID)
        let envelopePath = try writeIdeaEnvelope(for: context, ideaID: ideaID, derivedArtifacts: derivedArtifacts)
        let ideaSnapshot = try applyIdeaDecision(context, ideaID: ideaID)
        try recordRuntimeEvidence(
            opID: ideaID,
            sourceRef: envelopePath,
            actor: "system:dev-supervisor",
            replayableInputRef: "playbook/runtime/playbook-exec.yaml#add_idea",
            projectRoot: context.projectURL
        )

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
        try recordPolicyEvent(
            opID: "project.ds",
            opType: "Project",
            eventType: "policy.authorized",
            actor: context.request.baselineGate.actor,
            detail: "Operator moze uruchomic new_project dla wskazanego katalogu i profilu.",
            idempotencyKey: "project.ds|policy-authorized|new-project",
            projectRoot: context.projectURL
        )
        try moveProjectToConfigured(projectRoot: context.projectURL)
        try createBaselineBundle(context)
        try recordPolicyEvent(
            opID: "project.ds",
            opType: "Project",
            eventType: "policy.semantics_validated",
            actor: "policy-engine",
            detail: "Baseline bundle i artefakty wymagane przez playbook zostaly przygotowane.",
            idempotencyKey: "project.ds|policy-semantics|new-project",
            projectRoot: context.projectURL
        )

        let envelopePath = try writeBaselineEnvelope(for: context, remoteURL: setup.remoteURL)
        try applyBaselineDecision(context, projectRoot: context.projectURL)
        try activateProjectIfApproved(context, projectRoot: context.projectURL)
        try recordRuntimeEvidence(
            opID: "project.ds",
            sourceRef: envelopePath,
            actor: "system:dev-supervisor",
            replayableInputRef: "playbook/runtime/playbook-exec.yaml#new_project",
            projectRoot: context.projectURL
        )
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

    func createBaselineBundle(_ context: NewProjectContext) throws {
        let definitions = baselineDefinitions(for: context)

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
        }
    }

    func baselineDefinitions(for context: NewProjectContext) -> [RuntimeDerivedDefinition] {
        let parentLinks = [RuntimeLink(rel: "parent", target: "project.ds")]
        let operatorActor = context.request.baselineGate.actor

        return [
            baselineRequirementDefinition(parentLinks: parentLinks),
            baselineConstraintDefinition(parentLinks: parentLinks),
            baselineDecisionDefinition(parentLinks: parentLinks),
            baselineUseCaseDefinition(parentLinks: parentLinks),
            baselinePortContractDefinition(parentLinks: parentLinks),
            baselineComponentDefinition(parentLinks: parentLinks),
            baselinePermissionDefinition(
                parentLinks: parentLinks,
                operatorActor: operatorActor,
                projectPath: context.projectURL.path
            ),
        ]
    }

    func baselineRequirementDefinition(parentLinks: [RuntimeLink]) -> RuntimeDerivedDefinition {
        RuntimeDerivedDefinition(
            opID: "requirement.bootstrap",
            opType: "Requirement",
            initialState: "proposed",
            links: parentLinks,
            tags: ["baseline", "entrypoint:new_project"],
            payload: [
                "requirement_id": .string("REQ-BOOTSTRAP-001"),
                "source": .string("new_project"),
                "priority": .string("P1"),
                "acceptance_criteria": .array([
                    .string("Operator moze uruchomic projekt z UI."),
                    .string("Baseline artefakty sa tworzone bez silent transitions."),
                ]),
            ]
        )
    }

    func baselineConstraintDefinition(parentLinks: [RuntimeLink]) -> RuntimeDerivedDefinition {
        RuntimeDerivedDefinition(
            opID: "constraint.bootstrap",
            opType: "Constraint",
            initialState: "proposed",
            links: parentLinks,
            tags: ["baseline", "entrypoint:new_project"],
            payload: [
                "constraint_id": .string("CON-BOOTSTRAP-001"),
                "class": .string("process"),
                "rationale": .string("Playbook wymaga jawnego audytu i gate decisions."),
                "enforce_level": .string("required"),
            ]
        )
    }

    func baselineDecisionDefinition(parentLinks: [RuntimeLink]) -> RuntimeDerivedDefinition {
        RuntimeDerivedDefinition(
            opID: "decision.bootstrap",
            opType: "DecisionRecord",
            initialState: "drafted",
            links: parentLinks,
            tags: ["baseline", "entrypoint:new_project"],
            payload: [
                "decision_id": .string("ADR-0001"),
                "options_considered": .array([
                    .string("prompt-centric starter"),
                    .string("task-first operator starter"),
                ]),
                "selected_option": .string("task-first operator starter"),
                "consequence": .string("Operator UI oddziela prace od audytu."),
            ]
        )
    }

    func baselineUseCaseDefinition(parentLinks: [RuntimeLink]) -> RuntimeDerivedDefinition {
        RuntimeDerivedDefinition(
            opID: "usecase.bootstrap-start-project",
            opType: "UseCase",
            initialState: "drafted",
            links: parentLinks,
            tags: ["baseline", "entrypoint:new_project"],
            payload: [
                "use_case_id": .string("UC-001"),
                "actor": .string("operator"),
                "goal": .string("uruchomic projekt i baseline z UI"),
                "input_dto": .string("NewProjectFormInput"),
                "output_dto": .string("ProjectActivationSummary"),
            ]
        )
    }

    func baselinePortContractDefinition(parentLinks: [RuntimeLink]) -> RuntimeDerivedDefinition {
        RuntimeDerivedDefinition(
            opID: "portcontract.bootstrap-start-project",
            opType: "PortContract",
            initialState: "proposed",
            links: parentLinks + [RuntimeLink(rel: "owner_use_case", target: "usecase.bootstrap-start-project")],
            tags: ["baseline", "entrypoint:new_project"],
            payload: [
                "port_id": .string("PORT-NEW-PROJECT-001"),
                "direction": .string("inbound"),
                "contract_schema_ref": .string(".ai/architecture/port-contracts.md"),
                "dto_set": .array([
                    .string("NewProjectFormInput"),
                    .string("ProjectActivationSummary"),
                ]),
            ]
        )
    }

    func baselineComponentDefinition(parentLinks: [RuntimeLink]) -> RuntimeDerivedDefinition {
        RuntimeDerivedDefinition(
            opID: "component.bootstrap-workspace",
            opType: "Component",
            initialState: "identified",
            links: parentLinks,
            tags: ["baseline", "entrypoint:new_project"],
            payload: [
                "component_id": .string("COMP-STARTER-001"),
                "responsibility": .string("operator starter + runtime storage"),
                "stability_index": .string("high"),
                "abstraction_level": .string("application"),
            ]
        )
    }

    func baselinePermissionDefinition(
        parentLinks: [RuntimeLink],
        operatorActor: String,
        projectPath: String
    ) -> RuntimeDerivedDefinition {
        RuntimeDerivedDefinition(
            opID: "permission.operator-local",
            opType: "ActorRolePermission",
            initialState: "active",
            links: parentLinks + [RuntimeLink(rel: "actor", target: operatorActor)],
            tags: ["baseline", "entrypoint:new_project", "authz"],
            payload: [
                "actor_id": .string(operatorActor),
                "role": .string("operator"),
                "allowed_actions": .array([
                    .string("new_project"),
                    .string("add_idea"),
                ]),
                "scope": .string(projectPath),
            ]
        )
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
                RuntimeEnvelopeCondition(name: "adr_exists", passed: true, detail: ".ai/adr/0001-project-baseline.md"),
                RuntimeEnvelopeCondition(name: "use_cases_exists", passed: true, detail: ".ai/architecture/use-cases.md"),
                RuntimeEnvelopeCondition(name: "port_contracts_exists", passed: true, detail: ".ai/architecture/port-contracts.md"),
                RuntimeEnvelopeCondition(name: "component_map_exists", passed: true, detail: ".ai/architecture/component-map.md"),
                RuntimeEnvelopeCondition(name: "new_project_ux_exists", passed: true, detail: ".ai/ux/new-project.md"),
                RuntimeEnvelopeCondition(name: "op_index_exists", passed: true, detail: ".ai/runtime/v1/op-index.json"),
                RuntimeEnvelopeCondition(name: "operator_permission_active", passed: true, detail: "ActorRolePermission.active"),
                RuntimeEnvelopeCondition(name: "authz_precheck", passed: true, detail: "policy-engine authorized operator"),
            ],
            scope: "Task-first baseline projektu i przejscie Project.configured -> \(context.request.baselineGate.decision.targetProjectState).",
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
                "adr -> .ai/adr/0001-project-baseline.md",
                "use_cases -> .ai/architecture/use-cases.md",
                "port_contracts -> .ai/architecture/port-contracts.md",
                "component_map -> .ai/architecture/component-map.md",
                "ux -> .ai/ux/new-project.md",
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
        let uxArtifact = try writeIdeaUXArtifact(projectRoot: context.projectURL, ideaTitle: context.ideaTitle)

        return DerivedIdeaArtifacts(createdArtifacts: files + [uxArtifact], derivedOps: derivedOps)
    }

    func writeIdeaUXArtifact(projectRoot: URL, ideaTitle: String) throws -> String {
        let url = projectRoot.appendingPathComponent(".ai/ux/add-idea.md")
        try addIdeaUXMarkdown(ideaTitle: ideaTitle).write(to: url, atomically: true, encoding: .utf8)
        if isSQLBaseRuntime(projectRoot: projectRoot) {
            _ = try sqlProjectStore.storeArtifactFile(at: url, projectRoot: projectRoot)
        }
        return url.path
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
                RuntimeEnvelopeCondition(name: "authz_precheck", passed: true, detail: "policy-engine authorized operator"),
                RuntimeEnvelopeCondition(name: "idea_ux_exists", passed: true, detail: ".ai/ux/add-idea.md"),
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
                "Idea -> .ai/ux/add-idea.md",
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

    @discardableResult
    func recordPolicyEvent(
        opID: String,
        opType: String?,
        eventType: String,
        actor: String,
        detail: String,
        idempotencyKey: String,
        projectRoot: URL
    ) throws -> String {
        let event = RuntimeProcessEvent(
            eventID: nextProcessEventID(projectRoot: projectRoot),
            opID: opID,
            opType: opType,
            eventType: eventType,
            payloadHash: hash([
                "detail": .string(detail),
                "event_type": .string(eventType),
            ]),
            actor: actor,
            ts: timestamp(),
            idempotencyKey: idempotencyKey,
            fromState: nil,
            toState: nil,
            gateDecisionID: nil
        )
        try appendProcessEvent(event, projectRoot: projectRoot)
        return event.eventID
    }

    @discardableResult
    func recordRuntimeEvidence(
        opID: String,
        sourceRef: String,
        actor: String,
        replayableInputRef: String,
        projectRoot: URL
    ) throws -> String {
        let evidence = RuntimeEvidenceRecord(
            evidenceID: nextEvidenceID(projectRoot: projectRoot),
            evidenceClass: "runtime-capture",
            sourceRef: sourceRef,
            executorRef: "PlaybookRuntimeFileSystem",
            actorOrSystem: actor,
            subjectHash: hash([
                "op_id": .string(opID),
                "source_ref": .string(sourceRef),
                "replayable_input_ref": .string(replayableInputRef),
            ]),
            startedAt: timestamp(),
            finishedAt: timestamp(),
            environment: "local-macos-swiftui",
            replayableInputRef: replayableInputRef,
            attestationRef: nil,
            idempotencyKey: "\(opID)|evidence|\(sourceRef)"
        )
        try appendEvidence(evidence, projectRoot: projectRoot)
        try recordPolicyEvent(
            opID: opID,
            opType: nil,
            eventType: "evidence.classified",
            actor: "policy-engine",
            detail: "Dowod sklasyfikowano jako runtime-capture.",
            idempotencyKey: "\(opID)|evidence-classified|\(sourceRef)",
            projectRoot: projectRoot
        )
        return evidence.evidenceID
    }
}
