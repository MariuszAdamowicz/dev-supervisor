# OP -> Action -> Tool Bindings

Cel:
deterministycznie mapowac przejscia OP na akcje i konkretne narzedzia.

## Kontrakt globalny runtime

Kazdy state-changing transition dziedziczy obowiazkowy precheck:
- action_plan musi zawierac `authorize_transition` i `validate_semantics`
- tool_plan musi zawierac:
  - policy-engine: authz precheck
  - policy-engine: guard/invariant/CRUD validation
  - storage-adapter: append precheck audit

Kazdy transition lub review package, ktory produkuje dowod walidacyjny, dziedziczy:
- action_plan: `attest_evidence`
- tool_plan:
  - policy-engine: classify evidence
  - storage-adapter: persist provenance metadata

## Kontrakt bindingu

Kazdy binding ma:
- transition_ref (OP from -> to)
- event_ref (source event z OP trigger rules)
- action_plan (lista action_id)
- tool_plan (lista tool invocations)
- required (true/false)
- guards
- failure_policy

## Baseline bindingi krytyczne

### A. Project

1. Project.created -> Project.configured
- event_ref: project.initialize-requested
- action_plan: initialize_project
- tool_plan:
  - operator-ui: podaj nazwe/opis projektu
  - storage-adapter: utworz runtime storage
- required: true

2. Project.configured -> Project.baseline-approved
- event_ref: project.baseline-ready
- action_plan: select_profiles, decide_gate
- tool_plan:
  - operator-ui: wizard wyboru profili + confirm gate
  - storage-adapter: persist profile set
- guards:
  - overview/constraints/glossary istnieja
  - adr/use-case/port-contract/component-map/ux istnieja
  - AccessGrant istnieje
- required: true

3. Project.baseline-approved -> Project.active
- event_ref: gate.approve
- action_plan: accept_ai_result
- tool_plan:
  - storage-adapter: update stanu OP
- required: true

4. Project.active -> Project.archived
- event_ref: project.archive-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (snapshot runtime + links)
  - operator-ui: archive approve/request_changes/defer/reject
  - storage-adapter: update stanu OP
- required: true

### A1. Requirement / Constraint

4a. Requirement.proposed -> Requirement.clarified
- event_ref: requirement.clarify-requested
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (requirement-clarify)
  - ai-runner: poll_job
  - operator-ui: confirm requirement clarification
  - storage-adapter: persist Requirement
- required: true

4b. Requirement.clarified -> Requirement.approved
- event_ref: requirement.approve-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (requirement scope + impact)
  - operator-ui: requirement approve/request_changes/defer/reject
  - storage-adapter: persist Requirement state
- required: true

4c. Requirement.approved -> Requirement.linked
- event_ref: requirement.link-requested
- action_plan: accept_ai_result
- tool_plan:
  - operator-ui: select target Feature links
  - storage-adapter: persist Requirement->Feature links
- required: true

4d. Requirement.linked -> Requirement.deprecated
- event_ref: requirement.deprecate-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (traceability impact)
  - operator-ui: requirement deprecate approve/request_changes/defer/reject
  - storage-adapter: persist Requirement state
- required: true

4e. Constraint.proposed -> Constraint.validated
- event_ref: constraint.validate-requested
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (constraint-validate)
  - ai-runner: poll_job
  - operator-ui: confirm constraint validation
  - storage-adapter: persist Constraint
- required: true

4f. Constraint.validated -> Constraint.enforced
- event_ref: constraint.enforce-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (constraint enforcement impact)
  - operator-ui: constraint enforce approve/request_changes/defer/reject
  - storage-adapter: persist Constraint state
- required: true

4g. Constraint.enforced -> Constraint.revised
- event_ref: constraint.revise-requested
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (constraint-revision-check)
  - ai-runner: poll_job
  - operator-ui: confirm constraint revision
  - storage-adapter: persist Constraint state
- required: true

4h. Constraint.revised -> Constraint.retired
- event_ref: constraint.retire-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (constraint retirement impact)
  - operator-ui: constraint retire approve/request_changes/defer/reject
  - storage-adapter: persist Constraint state
- required: true

### A2. Decision Controls

4i. DecisionRecord.drafted -> DecisionRecord.reviewed
- event_ref: decision.review-requested
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (decision-review-prep)
  - ai-runner: poll_job
  - operator-ui: confirm decision review package
  - storage-adapter: persist DecisionRecord
- required: true

4j. DecisionRecord.reviewed -> DecisionRecord.approved
- event_ref: decision.approve-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (options + consequences)
  - operator-ui: decision approve/request_changes/defer/reject
  - storage-adapter: persist DecisionRecord state
- required: true

4k. DecisionRecord.approved -> DecisionRecord.superseded
- event_ref: decision.supersede-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (supersede rationale + impact)
  - operator-ui: decision supersede approve/request_changes/defer/reject
  - storage-adapter: persist DecisionRecord state + link replacement
- required: true

### A3. Risk Controls

4l. RiskEntry.identified -> RiskEntry.assessed
- event_ref: risk.assessment-requested
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (risk-assessment-review)
  - ai-runner: poll_job
  - operator-ui: confirm risk assessment
  - storage-adapter: persist RiskEntry
- required: true

4m. RiskEntry.assessed -> RiskEntry.mitigated
- event_ref: risk.mitigate-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (mitigation plan + impact)
  - operator-ui: risk mitigate approve/request_changes/defer/reject
  - storage-adapter: persist RiskEntry status
- required: true

4n. RiskEntry.assessed -> RiskEntry.accepted
- event_ref: risk.accept-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (acceptance rationale + residual risk)
  - operator-ui: risk accept approve/request_changes/defer/reject
  - storage-adapter: persist RiskEntry status
- required: true

4o. RiskEntry.assessed -> RiskEntry.escalated
- event_ref: risk.escalate-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (escalation reasons + options)
  - operator-ui: risk escalate approve/request_changes/defer/reject
  - storage-adapter: persist RiskEntry status + emit delivery block
- required: true

4p. RiskEntry.mitigated -> RiskEntry.closed
- event_ref: risk.close-requested
- action_plan: accept_ai_result
- tool_plan:
  - storage-adapter: persist RiskEntry status
- required: true

4q. RiskEntry.accepted -> RiskEntry.closed
- event_ref: risk.close-requested
- action_plan: accept_ai_result
- tool_plan:
  - storage-adapter: persist RiskEntry status
- required: true

4r. RiskEntry.escalated -> RiskEntry.closed
- event_ref: risk.close-after-escalation-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (escalation resolution)
  - operator-ui: risk close approve/request_changes/defer/reject
  - storage-adapter: persist RiskEntry status + clear delivery block
- required: true

### A4. Authz Controls

4s. AccessGrant.defined -> AccessGrant.active
- event_ref: permission.activate-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (role scope + allowed_actions)
  - operator-ui: permission activate approve/request_changes/defer/reject
  - storage-adapter: persist AccessGrant status
- required: true

4t. AccessGrant.active -> AccessGrant.revised
- event_ref: permission.revise-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (permission diff + impact)
  - operator-ui: permission revise approve/request_changes/defer/reject
  - storage-adapter: persist AccessGrant status
- required: true

4u. AccessGrant.revised -> AccessGrant.revoked
- event_ref: permission.revoke-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (revoke impact)
  - operator-ui: permission revoke approve/request_changes/defer/reject
  - storage-adapter: persist AccessGrant status
- required: true

### A5. UseCase / PortContract / Component

4v. UseCase.drafted -> UseCase.reviewed
- event_ref: usecase.review-requested
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (use-case-review)
  - ai-runner: poll_job
  - operator-ui: confirm use-case review package
  - storage-adapter: persist UseCase
- required: true

4w. UseCase.reviewed -> UseCase.approved
- event_ref: usecase.approve-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (use-case traceability + business rules)
  - operator-ui: use-case approve/request_changes/defer/reject
  - storage-adapter: persist UseCase state
- required: true

4x. UseCase.approved -> UseCase.implemented
- event_ref: usecase.implement-requested
- action_plan: accept_ai_result
- tool_plan:
  - storage-adapter: persist UseCase state
- required: true

4y. UseCase.implemented -> UseCase.verified
- event_ref: usecase.verify-requested
- action_plan: run_validation_suite, decide_gate
- tool_plan:
  - shell: run core/app test suite without infrastructure
  - operator-ui: use-case verify approve/request_changes/defer/reject
  - storage-adapter: persist UseCase state
- required: true

4z. PortContract.proposed -> PortContract.reviewed
- event_ref: port-contract.review-requested
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (port-contract-review)
  - ai-runner: poll_job
  - operator-ui: confirm port contract review
  - storage-adapter: persist PortContract
- required: true

4aa. PortContract.reviewed -> PortContract.approved
- event_ref: port-contract.approve-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (DTO schema + framework leakage check)
  - operator-ui: port contract approve/request_changes/defer/reject
  - storage-adapter: persist PortContract state
- required: true

4ab. PortContract.approved -> PortContract.adopted
- event_ref: port-contract.adopt-requested
- action_plan: accept_ai_result
- tool_plan:
  - storage-adapter: persist PortContract state
- required: true

4ac. Component.identified -> Component.mapped
- event_ref: component.map-requested
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (component-dependency-map)
  - ai-runner: poll_job
  - operator-ui: confirm component map
  - storage-adapter: persist Component graph
- required: true

4ad. Component.mapped -> Component.checked
- event_ref: component.check-requested
- action_plan: run_validation_suite
- tool_plan:
  - shell: run dependency direction + cycle checks
  - storage-adapter: persist check report
- required: true

4ae. Component.checked -> Component.compliant
- event_ref: component.compliance-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (ADP/SDP/SAP checks + violations)
  - operator-ui: component compliance approve/request_changes/defer/reject
  - storage-adapter: persist Component state
- required: true

4af. Component.checked -> Component.refactor-required
- event_ref: component.violation-detected
- action_plan: request_rework
- tool_plan:
  - storage-adapter: persist refactor-required status
  - operator-ui: confirm remediation scope
- required: true

### A6. Repository control / ChangeSet / VerificationPolicy / DataSchema / MigrationAction / Environment

4ag. Repository.detected -> Repository.initialized
- event_ref: repo.initialize-requested
- action_plan: synchronize_repository
- tool_plan:
  - git: init + status
  - operator-ui: confirm repository root and ignore baseline
  - storage-adapter: persist Repository state
- required: true

4ah. Repository.remote-attached -> Repository.policy-aligned
- event_ref: repo.align-policy-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - git: remote + fetch + status
  - operator-ui: approve branch/commit policy
  - storage-adapter: persist Repository policy and gate
- required: true

4ai. ChangeSet.drafted -> ChangeSet.staged
- event_ref: changeset.stage-requested
- action_plan: stage_changeset
- tool_plan:
  - git: add + diff + status
  - operator-ui: confirm file scope and linked OPs
  - storage-adapter: persist ChangeSet scope
- required: true

4aj. ChangeSet.staged -> ChangeSet.validated
- event_ref: changeset.validate-requested
- action_plan: plan_verification_scope, run_validation_suite, decide_gate
- tool_plan:
  - quality-runner: unit/integration/acceptance/e2e wg VerificationPolicy
  - operator-ui: approve request_changes/defer/reject dla ChangeSet
  - storage-adapter: persist validation refs + gate
- required: true

4ak. ChangeSet.validated -> ChangeSet.committed
- event_ref: changeset.commit-requested
- action_plan: commit_checkpoint
- tool_plan:
  - git: commit
  - storage-adapter: persist commit_refs
- required: true

4al. VerificationPolicy.drafted -> VerificationPolicy.reviewed
- event_ref: verification.review-requested
- action_plan: plan_verification_scope
- tool_plan:
  - quality-runner: compute required lanes
  - operator-ui: confirm lane selection and `not_applicable`
  - storage-adapter: persist VerificationPolicy
- required: true

4am. VerificationPolicy.reviewed -> VerificationPolicy.approved
- event_ref: verification.approve-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (lane matrix + provenance rules)
  - operator-ui: approve/request_changes/defer/reject verification policy
  - storage-adapter: persist VerificationPolicy state
- required: true

4an. DataSchema.drafted -> DataSchema.reviewed
- event_ref: schema.review-requested
- action_plan: evolve_data_schema
- tool_plan:
  - shell: schema diff / compatibility report
  - operator-ui: confirm owned structures and compatibility policy
  - storage-adapter: persist DataSchema draft
- required: true

4ao. MigrationAction.reviewed -> MigrationAction.approved
- event_ref: migration.approve-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: compatibility + rollback readiness review package
  - operator-ui: approve/request_changes/defer/reject migration plan
  - storage-adapter: persist MigrationAction state
- required: true

4ap. MigrationAction.ready -> MigrationAction.applied
- event_ref: migration.apply-requested
- action_plan: evolve_data_schema
- tool_plan:
  - shell: execute migration lane
  - operator-ui: confirm apply window and rollback readiness
  - storage-adapter: persist MigrationAction result
- required: true

4aq. EnvironmentTarget.defined -> EnvironmentTarget.validated
- event_ref: environment.validate-requested
- action_plan: validate_runtime_environment
- tool_plan:
  - deployment-adapter: verify_environment
  - operator-ui: confirm capabilities, secrets policy and constraints
  - storage-adapter: persist EnvironmentTarget check
- required: true

### B. Idea -> Feature

4. Idea.captured -> Idea.scoped
- event_ref: idea.scope-requested
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (IDEA -> FEATURES)
  - ai-runner: poll_job
  - operator-ui: confirm imported scope
  - storage-adapter: zapis scope
- required: true

5. Idea.scoped -> Idea.converted
- event_ref: idea.convert-approved
- action_plan: decide_gate
- tool_plan:
  - operator-ui: approve conversion do Feature
  - storage-adapter: zapis GateDecisionRecord + Feature create
- required: true

6. Idea.scoped -> Idea.dropped
- event_ref: idea.drop-approved
- action_plan: decide_gate
- tool_plan:
  - operator-ui: reject/defer z reason
  - storage-adapter: audit + closed reason
- required: true

### C. Feature spec/test/impl

7. Feature.drafted -> Feature.specified
- event_ref: Idea.scoped
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (IDEA -> PRD)
  - ai-runner: poll_job
  - operator-ui: confirm PRD import
  - storage-adapter: persist PRD
- required: true

8. Feature.specified -> Feature.ux-aligned
- event_ref: Feature.specified
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (ux-contract-check + term-extract)
  - ai-runner: poll_job
  - operator-ui: approve term/ui deltas
  - storage-adapter: update GlossaryEntry/UIComponent/UIScreen
- required: true

9. Feature.ux-aligned -> Feature.scenario-ready
- event_ref: Feature.ux-aligned
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (PRD -> BDD)
  - ai-runner: poll_job
  - operator-ui: approve scenario package
  - storage-adapter: persist BDD
- required: true

10. Feature.scenario-ready -> Feature.test-ready
- event_ref: Scenario.approved
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (BDD -> TESTY)
  - ai-runner: poll_job
  - operator-ui: confirm test mapping
  - storage-adapter: persist tests + traceability
- required: true

11. Feature.test-ready -> Feature.implemented
- event_ref: tests.implemented
- action_plan: run_validation_suite
- tool_plan (macos-swiftui):
  - shell: ./Scripts/build.sh
  - shell: ./Scripts/test.sh
  - shell: ./Scripts/lint.sh
- guards:
  - wszystkie krytyczne scenariusze maja testy
- required: true

12. Feature.implemented -> Feature.stabilized
- event_ref: PromptTask.executed
- action_plan: produce_review_package, decide_gate, commit_checkpoint
- tool_plan:
  - shell: review package generator
  - operator-ui: gate approve/request_changes/defer/reject
  - git: add + commit
- required: true

12a. Feature.implemented -> Feature.test-ready
- event_ref: feature.stabilize-requested
- action_plan: decide_gate, request_rework
- tool_plan:
  - operator-ui: gate=request_changes
  - storage-adapter: update Feature state to test-ready
  - storage-adapter: create PromptTask(rework)
- required: true

12b. Feature.implemented -> Feature.implemented
- event_ref: feature.stabilize-requested
- action_plan: decide_gate
- tool_plan:
  - operator-ui: gate=defer
  - storage-adapter: persist defer reason + schedule SchedulerTimer
- required: true

12c. Feature.implemented -> Feature.specified
- event_ref: feature.stabilize-requested
- action_plan: decide_gate, request_rework
- tool_plan:
  - operator-ui: gate=reject
  - storage-adapter: update Feature state to specified
  - storage-adapter: create PromptTask(respec)
- required: true

### D. GlossaryEntry / UIComponent / UIScreen

13. GlossaryEntry.proposed -> GlossaryEntry.approved
- event_ref: GlossaryEntry.proposed
- action_plan: create_ai_job, poll_ai_job, decide_gate
- tool_plan:
  - ai-runner: submit_job (term-impact-check)
  - ai-runner: poll_job
  - operator-ui: approve term scope
  - storage-adapter: persist GlossaryEntry + impacts
- required: true

13a. GlossaryEntry.approved -> GlossaryEntry.deprecated
- event_ref: term.deprecate-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (term usage impact)
  - operator-ui: term deprecate approve/request_changes/defer/reject
  - storage-adapter: persist GlossaryEntry status
- required: true

14. UIComponent.proposed -> UIComponent.mapped
- event_ref: UIComponent.proposed
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (ui-placement)
  - ai-runner: poll_job
  - operator-ui: confirm placement
  - storage-adapter: update UI map
- required: true

15. UIComponent.mapped -> UIComponent.implemented
- event_ref: UIComponent.mapped
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (ui-implementation)
  - ai-runner: poll_job
  - operator-ui: confirm implementation import
  - storage-adapter: update component state
- required: true

16. UIComponent.implemented -> UIComponent.verified
- event_ref: UIComponent.implemented
- action_plan: run_validation_suite, decide_gate
- tool_plan:
  - quality-runner: UI validation tests
  - operator-ui: approve UX validation
- required: true

16a. UIComponent.verified -> UIComponent.deprecated
- event_ref: ui.deprecate-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (component usage + replacement map)
  - operator-ui: component deprecate approve/request_changes/defer/reject
  - storage-adapter: persist UIComponent state
- required: true

17. UIScreen.proposed -> UIScreen.mapped
- event_ref: screen.mapping-requested
- action_plan: create_ai_job, poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: submit_job (screen-flow mapping)
  - ai-runner: poll_job
  - operator-ui: confirm screen map
  - storage-adapter: update UIScreen
- required: true

18. UIScreen.mapped -> UIScreen.verified
- event_ref: screen.validation-requested
- action_plan: run_validation_suite, decide_gate
- tool_plan:
  - quality-runner: navigation + visibility checks
  - operator-ui: approve UX gate
- required: true

18a. UIScreen.verified -> UIScreen.deprecated
- event_ref: screen.deprecate-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (navigation impact + replacement)
  - operator-ui: screen deprecate approve/request_changes/defer/reject
  - storage-adapter: persist UIScreen state
- required: true

18b. Scenario.passing -> Scenario.obsolete
- event_ref: scenario.obsolete-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (test traceability impact)
  - operator-ui: scenario obsolete approve/request_changes/defer/reject
  - storage-adapter: persist Scenario state
- required: true

### E. Job Controls / Quality / Exception Controls

19. PromptTask.created -> PromptTask.ready
- event_ref: prompt.context-ready
- action_plan: create_ai_job
- tool_plan:
  - ai-runner: submit_job
  - storage-adapter: persist PromptTask
- required: true

20. PromptTask.ready -> PromptTask.executed
- event_ref: prompt.sent
- action_plan: poll_ai_job, accept_ai_result
- tool_plan:
  - ai-runner: poll_job
  - operator-ui: confirm response acceptance
- required: true

21. PromptTask.ready -> PromptTask.cancelled
- event_ref: prompt.cancel-requested
- action_plan: cancel_ai_job
- tool_plan:
  - ai-runner: cancel_job
  - storage-adapter: persist cancel reason
- required: true

22. PromptTask.ready -> PromptTask.ready (retry)
- event_ref: timeout.fired
- action_plan: retry_ai_job
- tool_plan:
  - ai-runner: retry_job
  - storage-adapter: increment retry_count
- failure_policy:
  - po limicie retry: reset_ai_context albo GateDecisionRecord.defer
- required: true

22a. PromptTask.executed -> PromptTask.validated
- event_ref: prompt.validation-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (prompt output + traceability)
  - operator-ui: validate prompt approve/request_changes/defer/reject
  - storage-adapter: persist PromptTask state
- required: true

22aa. PromptTask.executed -> PromptTask.ready
- event_ref: prompt.validation-requested
- action_plan: decide_gate, request_rework
- tool_plan:
  - operator-ui: gate=request_changes
  - storage-adapter: update PromptTask state to ready
  - storage-adapter: create PromptTask(rework)
- required: true

22ab. PromptTask.executed -> PromptTask.executed
- event_ref: prompt.validation-requested
- action_plan: decide_gate
- tool_plan:
  - operator-ui: gate=defer
  - storage-adapter: persist defer reason + schedule SchedulerTimer
- required: true

22ac. PromptTask.executed -> PromptTask.cancelled
- event_ref: prompt.validation-requested
- action_plan: decide_gate, cancel_ai_job
- tool_plan:
  - operator-ui: gate=reject
  - ai-runner: cancel_job
  - storage-adapter: persist cancel reason (rejected-output)
- required: true

22b. PromptTask.validated -> PromptTask.closed
- event_ref: prompt.close-requested
- action_plan: accept_ai_result
- tool_plan:
  - storage-adapter: persist PromptTask state
- required: true

24. ExceptionCase.detected -> ExceptionCase.handled
- event_ref: exception.fix-applied
- action_plan: run_validation_suite, decide_gate
- tool_plan:
  - quality-runner: rerun failing suite
  - operator-ui: close/escalate exception
- required: true

### F. Delivery / Recovery

25. Feature.stabilized -> ReleaseBundle.candidate
- event_ref: Feature.stabilized
- action_plan: start_release
- tool_plan:
  - storage-adapter: utworz release candidate
  - operator-ui: confirm release scope
- guards:
  - brak critical ExceptionCase
  - brak DependencyRelation.status=blocked dla scope delivery
  - brak otwartych RiskEntry.escalated o criticality=high
- required: true

26. ReleaseBundle.candidate -> ReleaseBundle.approved
- event_ref: release.gate-requested
- action_plan: decide_gate
- tool_plan:
  - operator-ui: release approve/request_changes/defer/reject
  - storage-adapter: persist gate
- guards:
  - brak otwartych RiskEntry.escalated o criticality=high
- required: true

26a. ReleaseBundle.candidate -> ReleaseBundle.planned
- event_ref: release.gate-requested
- action_plan: decide_gate, request_rework
- tool_plan:
  - operator-ui: gate=request_changes
  - storage-adapter: update ReleaseBundle state to planned
  - storage-adapter: create PromptTask(release-rework)
- required: true

26b. ReleaseBundle.candidate -> ReleaseBundle.candidate
- event_ref: release.gate-requested
- action_plan: decide_gate
- tool_plan:
  - operator-ui: gate=defer
  - storage-adapter: persist defer reason + schedule SchedulerTimer
- required: true

26c. ReleaseBundle.candidate -> ReleaseBundle.closed
- event_ref: release.gate-requested
- action_plan: decide_gate
- tool_plan:
  - operator-ui: gate=reject
  - storage-adapter: update ReleaseBundle state to closed
  - storage-adapter: create DecisionRecord(release-rejection)
- required: true

27. ReleaseBundle.approved -> DeploymentRun.planned
- event_ref: ReleaseBundle.approved
- action_plan: deploy_release
- tool_plan:
  - deployment-adapter: deploy prepare
  - operator-ui: confirm deploy start
- required: true

28. DeploymentRun.planned -> DeploymentRun.running
- event_ref: deployment.started
- action_plan: deploy_release
- tool_plan:
  - deployment-adapter: start deploy
  - storage-adapter: persist DeploymentRun status
- required: true

29. DeploymentRun.running -> DeploymentRun.succeeded
- event_ref: deployment.completed
- action_plan: deploy_release, accept_ai_result
- tool_plan:
  - deployment-adapter: capture deploy result
  - storage-adapter: persist DeploymentRun status
  - storage-adapter: mark ReleaseBundle.published + Feature.released
- required: true

30. DeploymentRun.running -> DeploymentRun.failed
- event_ref: deployment.failed
- action_plan: run_rollback
- tool_plan:
  - deployment-adapter: detect fail + emit signal
  - storage-adapter: create RollbackAction (+ CompensationAction gdy policy wymaga cleanup)
- required: true

31. DeploymentRun.failed -> RollbackAction.planned -> RollbackAction.running -> RollbackAction.completed
- event_ref: deployment.failed
- action_plan: run_rollback, decide_gate
- tool_plan:
  - deployment-adapter: rollback
  - operator-ui: confirm rollback/close
  - storage-adapter: persist rollback outcome
- required: true

31a. DeploymentRun.failed -> DeploymentRun.planned
- event_ref: deployment.retry-requested
- action_plan: decide_gate, deploy_release
- tool_plan:
  - operator-ui: retry deploy approve/request_changes/defer/reject
  - deployment-adapter: prepare deploy retry
  - storage-adapter: update DeploymentRun status to planned
- required: true

31b. DeploymentRun.failed -> DeploymentRun.failed
- event_ref: deployment.retry-requested
- action_plan: decide_gate
- tool_plan:
  - operator-ui: gate=request_changes|defer|reject
  - storage-adapter: persist retry denied/deferred reason + escalation
- required: true

31c. RollbackAction.planned -> RollbackAction.running
- event_ref: rollback.started
- action_plan: run_rollback
- tool_plan:
  - deployment-adapter: start rollback
  - storage-adapter: update RollbackAction status to running
- required: true

31d. RollbackAction.running -> RollbackAction.completed
- event_ref: rollback.completed
- action_plan: run_rollback, accept_ai_result
- tool_plan:
  - deployment-adapter: collect rollback result
  - storage-adapter: update RollbackAction status to completed
  - storage-adapter: update CompensationAction status to completed gdy cleanup byl wymagany
- required: true

31e. RollbackAction.running -> RollbackAction.failed
- event_ref: rollback.failed
- action_plan: run_rollback
- tool_plan:
  - deployment-adapter: collect rollback error
  - storage-adapter: update RollbackAction status to failed
  - operator-ui: escalate rollback failure
- required: true

32. Feature.stabilized -> Feature.released
- event_ref: deployment.succeeded
- action_plan: accept_ai_result
- tool_plan:
  - storage-adapter: update Feature state to released
- guards:
  - DeploymentRun.status = succeeded
  - ReleaseBundle.status = published
- required: true

33. Feature.released -> Feature.done
- event_ref: feature.close-requested
- action_plan: produce_review_package, decide_gate, commit_checkpoint
- tool_plan:
  - shell: review package generator (release evidence + runtime audit)
  - operator-ui: feature close approve/request_changes/defer/reject
  - git: add + commit
  - storage-adapter: update Feature state to done
- guards:
  - wszystkie wymagania krytyczne sa Requirement.linked
  - wszystkie ograniczenia krytyczne sa Constraint.enforced lub Constraint.revised
  - wszystkie wymagane decyzje architektoniczne sa DecisionRecord.approved
- required: true

34. ReleaseBundle.approved -> ReleaseBundle.published
- event_ref: deployment.succeeded
- action_plan: accept_ai_result
- tool_plan:
  - storage-adapter: update ReleaseBundle status to published
- guards:
  - DeploymentRun.status = succeeded
- required: true

35. ReleaseBundle.published -> ReleaseBundle.closed
- event_ref: release.close-requested
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (deploy summary + rollback readiness)
  - operator-ui: release close approve/request_changes/defer/reject
  - storage-adapter: update ReleaseBundle status to closed
- required: true

### G. FSM coverage templates (dla wszystkich OP)

Cel:
zapewnic 100% pokrycia transition z `layers/op/state-machines.md`
dla OP, ktore nie maja jeszcze jawnych wpisow per kazdy wariant.

Zakres OP objetych tym mechanizmem:
- Project, Requirement, Constraint, Idea, Feature, Scenario
- UIComponent, UIScreen
- UseCase, PortContract, Component
- ChangeSet, DataSchema

Zasada:
- jesli legalny transition z FSM nie ma jawnego bindingu wyzej, stosujemy binding szablonowy G1/G2/G3.
- pierwszenstwo maja bindingi jawne (A-F).

G1. Gate-required transition template
- transition_ref: `<OP.from_state -> OP.to_state>` z gate-required
- event_ref: `<op>.<event>` zgodnie z FSM
- action_plan: produce_review_package, decide_gate
- tool_plan:
  - shell: review package generator (scope wg OP)
  - operator-ui: gate approve/request_changes/defer/reject
  - storage-adapter: persist gate + update OP state
- required: true
- failure_policy:
  - request_changes -> rework loop wg FSM
  - defer -> pozostanie w current_state + schedule SchedulerTimer
  - reject -> przejscie do stanu odrzucenia/terminalnego wg FSM

G2. Non-gate transition template
- transition_ref: `<OP.from_state -> OP.to_state>` bez gate
- event_ref: `<op>.<event>` zgodnie z FSM
- action_plan: accept_ai_result
- tool_plan:
  - storage-adapter: update OP state + append ProcessEventRecord
- required: true

G3. Retry/escalation template
- transition_ref: `<OP.retry/recovery transition>` zgodnie z FSM
- event_ref: `timeout.fired` albo `<op>.retry-requested` albo `<op>.recover-requested`
- action_plan: retry_ai_job lub request_rework lub decide_gate (wg OP)
- tool_plan:
  - ai-runner/deployment-adapter/quality-runner (zaleznie od OP)
  - operator-ui: confirm retry/defer/escalation
  - storage-adapter: persist retry_count/state/escalation
- required: true

## Reguly

- Aplikacja nie wylicza samodzielnie komend; korzysta z bindingow.
- Profile moga nadpisac tool_plan, ale nie intent action.
- Brak bindingu dla legal transition oznacza konfiguracje niekompletna.
- Jesli action wymaga decyzji czlowieka, tool_plan musi zawierac operator-ui.
- Zmiana stanu OP przez UI bez odpowiadajacego bindingu jest niedozwolona.
- Kazdy binding krytyczny musi miec audit trace: ProcessEventRecord + GateDecisionRecord (jesli gate wystepuje).
- MCP moze byc uzyte tylko jako adapter transportowy; kontrola job lifecycle nalezy do DS.
- Kazdy binding transition MUST wykonac authz precheck:
  - storage-adapter: read AccessGrant(active, scope, allowed_actions)
  - brak uprawnienia -> utworz ExceptionCase(authz), blokuj transition, zapisz ProcessEventRecord.
