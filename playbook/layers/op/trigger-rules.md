## Trigger Rules (event -> action -> gate)

Cel: deterministyczne uruchamianie zadan i decyzji bez recznego pilnowania zaleznosci.

## Kontrakt triggera

Kazda regula ma:
- event
- guards
- actions
- target_op
- gate_effect
- failure_policy
- idempotency_key

## Reguly bazowe

### 1. Scope i spec
- Event: Idea.scoped
- Action: utworz PromptTask(prd-draft)
- Gate effect: otwiera Feature.specified

- Event: Feature.specified
- Action: utworz PromptTask(ux-contract-check) + PromptTask(term-extract)
- Gate effect: blokuje przejscie dalej do czasu domkniecia UX/Term

- Event: Feature.ux-aligned
- Action: utworz PromptTask(prd-to-bdd)

- Event: Scenario.reviewed
- Action: utworz PromptTask(scenario-approval-review)
- Gate effect: odblokowuje Scenario.approved

- Event: Scenario.approved
- Action: utworz PromptTask(bdd-to-tests)

### 1a. Requirement, Constraint i DecisionRecord baseline
- Event: Requirement.proposed
- Action: utworz PromptTask(requirement-clarify)

- Event: Requirement.clarified
- Action: utworz PromptTask(requirement-approval-review)

- Event: Requirement.approved
- Action: utworz PromptTask(requirement-link-review)
- Gate effect: odblokowuje Requirement.linked

- Event: Constraint.proposed
- Action: utworz PromptTask(constraint-validate)

- Event: Constraint.validated
- Action: utworz PromptTask(constraint-enforce-review)
- Gate effect: odblokowuje Constraint.enforced

- Event: Constraint.enforced
- Action: utworz PromptTask(constraint-revision-check)

- Event: Constraint.revised
- Action: utworz PromptTask(constraint-retire-review)

- Event: DecisionRecord.drafted
- Action: utworz PromptTask(decision-review-prep)

- Event: DecisionRecord.reviewed
- Action: utworz PromptTask(decision-approval-review)
- Gate effect: odblokowuje DecisionRecord.approved

- Event: DecisionRecord.approved
- Action: utworz PromptTask(decision-supersede-review)

### 1b. Risk baseline
- Event: Risk.identified
- Action: utworz PromptTask(risk-assessment-review)

- Event: Risk.assessed
- Action: utworz PromptTask(risk-resolution-review)
- Gate effect: odblokowuje `mitigated|accepted|escalated`

- Event: Risk.escalated
- Action: utworz GateDecisionRecord(defer|request_changes) candidate dla delivery
- Gate effect: blokuje `Release.approved` do czasu decyzji

- Event: Risk.mitigated
- Action: utworz PromptTask(risk-close-review)

- Event: Risk.accepted
- Action: utworz PromptTask(risk-acceptance-audit)

### 1c. ActorRolePermission baseline
- Event: ActorRolePermission.defined
- Action: utworz PromptTask(permission-activation-review)

- Event: ActorRolePermission.active
- Action: utworz PromptTask(permission-revision-review)

- Event: ActorRolePermission.revised
- Action: utworz PromptTask(permission-revoke-review)

- Event: authz.denied
- Action: utworz Exception(authz) + blokuj transition

### 1d. UseCase / PortContract / Component baseline
- Event: Feature.specified
- Action: utworz PromptTask(use-case-draft)
- Gate effect: blokuje Feature.implemented do czasu UseCase.approved

- Event: UseCase.drafted
- Action: utworz PromptTask(use-case-review)

- Event: UseCase.reviewed
- Action: utworz PromptTask(use-case-approval-review)
- Gate effect: odblokowuje UseCase.approved

- Event: UseCase.approved
- Action: utworz PromptTask(port-contract-draft)

- Event: PortContract.proposed
- Action: utworz PromptTask(port-contract-review)

- Event: PortContract.reviewed
- Action: utworz PromptTask(port-contract-approval-review)
- Gate effect: odblokowuje PortContract.approved

- Event: PortContract.approved
- Action: utworz PromptTask(component-map)

- Event: Component.identified
- Action: utworz PromptTask(component-dependency-map)

- Event: Component.mapped
- Action: utworz PromptTask(component-dependency-check)
- Gate effect: blokuje Component.compliant przy wykryciu cykli lub zlej orientacji zaleznosci

- Event: Component.checked
- Action: utworz GateDecisionRecord(approve|request_changes) candidate dla zgodnosci architektury

### 1e. Repository / ChangeSet / Verification / Data / Environment
- Event: Project.configured
- Action: utworz Repository.detected + VerificationPlan.drafted

- Event: Repository.detected
- Action: utworz PromptTask(repo-bootstrap-review)

- Event: Repository.initialized
- Action: utworz PromptTask(repo-remote-attach)

- Event: Repository.remote-attached
- Action: utworz PromptTask(repo-policy-review)
- Gate effect: odblokowuje Repository.policy-aligned

- Event: ChangeSet.drafted
- Action: utworz PromptTask(changeset-scope-review)

- Event: ChangeSet.staged
- Action: utworz PromptTask(changeset-validation-review)
- Gate effect: odblokowuje ChangeSet.validated

- Event: VerificationPlan.drafted
- Action: utworz PromptTask(verification-review)

- Event: VerificationPlan.reviewed
- Action: utworz PromptTask(verification-approval-review)
- Gate effect: odblokowuje VerificationPlan.approved

- Event: Feature.scenario-ready
- Action: utworz PromptTask(verification-plan-sync)

- Event: DataSchema.drafted
- Action: utworz PromptTask(schema-review)

- Event: DataSchema.reviewed
- Action: utworz PromptTask(schema-approval-review)
- Gate effect: odblokowuje DataSchema.approved

- Event: Migration.drafted
- Action: utworz PromptTask(migration-review)

- Event: Migration.approved
- Action: utworz PromptTask(migration-readiness-check)

- Event: RuntimeEnvironment.defined
- Action: utworz PromptTask(environment-validation)

- Event: RuntimeEnvironment.validated
- Action: utworz PromptTask(environment-readiness-review)
- Gate effect: odblokowuje RuntimeEnvironment.ready

### 2. Terminologia i UI
- Event: Term.proposed
- Action: utworz PromptTask(term-impact-check)
  - czy potrzebny nowy UIComponent
  - czy potrzebna zmiana copy
  - czy potrzebna zmiana scenariuszy

- Event: UIComponent.proposed
- Action: utworz PromptTask(ui-placement)

- Event: UIComponent.mapped
- Action: utworz PromptTask(ui-implementation)

- Event: UIComponent.implemented
- Action: utworz PromptTask(ux-validation)

- Event: Term.approved
- Action: utworz PromptTask(term-deprecation-review)

- Event: UIComponent.verified
- Action: utworz PromptTask(ui-deprecation-review)

- Event: UIScreen.verified
- Action: utworz PromptTask(screen-deprecation-review)

- Event: Scenario.passing
- Action: utworz PromptTask(scenario-obsolete-review)

### 3. Jakosc i gate
- Event: PromptTask.executed
- Action: zbuduj review package (diff + mapowanie do BDD + build/test/lint)

- Event: PromptTask.executed
- Action: utworz PromptTask(validation-review)
- Gate effect: odblokowuje PromptTask.validated po review package

- Event: PromptTask.validated
- Action: zamknij PromptTask (state=closed)

- Event: prompt.validation-requested (gate=request_changes)
- Action: cofnij PromptTask do ready + utworz PromptTask(rework)

- Event: prompt.validation-requested (gate=defer)
- Action: pozostaw PromptTask w executed + utworz Timeout.scheduled

- Event: prompt.validation-requested (gate=reject)
- Action: anuluj PromptTask (state=cancelled) + utworz Exception(rejected-output)

- Event: quality.evidence.pass
- Action: odblokuj kolejne legalne transition OP

- Event: quality.evidence.fail
- Action: utworz Exception + PromptTask(debug-fix)
- Gate effect: wymusza GateDecisionRecord=request_changes lub defer

- Event: gate.recorded(approve)
- Action: odblokuj kolejny stan OP

- Event: gate.recorded(request_changes)
- Action: utworz PromptTask(rework)

### 4. Delivery
- Event: Feature.stabilized
- Guard: brak krytycznych Exception i brak DependencyRelation.status=blocked dla scope delivery
- Action: utworz Release.candidate

- Event: Feature.implemented
- Guard: co najmniej jeden UseCase.approved i brak PortContract!=approved dla tych UseCase
- Action: utworz PromptTask(architecture-conformance-check)

- Event: feature.stabilize-requested (gate=request_changes)
- Action: cofniecie Feature do test-ready + utworz PromptTask(rework)

- Event: feature.stabilize-requested (gate=defer)
- Action: pozostaw Feature w implemented + utworz Timeout.scheduled

- Event: feature.stabilize-requested (gate=reject)
- Action: cofniecie Feature do specified + utworz PromptTask(respec)

- Event: Release.approved
- Action: utworz Deployment.prepared

- Event: release.approve-requested (gate=request_changes)
- Action: cofniecie Release do planned + utworz PromptTask(release-rework)

- Event: release.approve-requested (gate=defer)
- Action: pozostaw Release w candidate + utworz Timeout.scheduled

- Event: release.approve-requested (gate=reject)
- Action: zamknij Release (state=closed) + utworz DecisionRecord(release-rejection)

- Event: Deployment.succeeded
- Action: oznacz Release.published + odblokuj Feature.released
- Gate effect: otwiera zamkniecie Release i Feature

- Event: Release.published
- Action: utworz PromptTask(release-close-review) + PromptTask(feature-close-review)

- Event: Deployment.failed
- Action: utworz Rollback.prepared + Compensation.planned

- Event: deployment.retry-requested (gate=approve)
- Action: przejdz Deployment.failed -> Deployment.prepared

- Event: deployment.retry-requested (gate=request_changes|defer)
- Action: pozostaw Deployment w failed + eskaluj do operatora

- Event: rollback.start-requested
- Action: przejdz Rollback.prepared -> Rollback.running

- Event: rollback.completed
- Action: przejdz Rollback.running -> Rollback.succeeded + oznacz Compensation.completed

- Event: rollback.failed
- Action: przejdz Rollback.running -> Rollback.failed + eskaluj

### 5. Timeout i eskalacje
- Event: Timeout.fired
- Action: utworz Exception(timeout) + GateDecisionRecord(defer) candidate
- Failure policy: escalation do operatora

### 6. Lifecycle housekeeping
- Event: project.archive-requested
- Action: utworz review package archiwizacji + GateDecisionRecord candidate

## Retry / idempotency / compensation

- Retry stosuj tylko dla operacji oznaczonych retryable.
- Kazdy trigger ma idempotency_key, aby uniknac duplikatow PromptTask.
- Po przekroczeniu limitu retry wymagane jest Compensation lub decyzja reject/defer.

## Reguly bezpieczenstwa i uprawnien

- Action mozliwa tylko gdy ActorRolePermission pozwala na dana operacje.
- Brak uprawnien generuje Exception(authz) i blokuje transition.

## Audit

- Kazdy trigger execution zapisuje ProcessEventRecord.
- Brak ProcessEventRecord = przejscie uznane za niewazne.

## 7. FSM expansion rules (dla wszystkich OP)

Cel:
domknac pelne pokrycie triggerow dla calego grafu z `layers/op/state-machines.md`
bez duplikowania identycznych opisow dla kazdego OP.

Reguly:
1. Kazdy transition z FSM, ktory nie ma jawnej reguly wyzej, dziedziczy trigger bazowy:
- Event: `<op>.<event z FSM>`
- Action: `accept_ai_result` (dla prostych transition) albo `decide_gate` (dla gate-required)
- Gate effect: zgodny 1:1 z `to_state` z FSM.

2. Dla kazdego transition gate-required:
- `GateDecisionRecord=approve` przeprowadza transition do `to_state` z happy path.
- `GateDecisionRecord=request_changes` uruchamia rework loop wskazany w FSM.
- `GateDecisionRecord=defer` utrzymuje current_state i tworzy `Timeout.scheduled`.
- `GateDecisionRecord=reject` przechodzi do stanu odrzucenia/terminalnego wskazanego w FSM.

3. Dla transition retryable:
- `timeout.fired` i `retry_budget>0` uruchamia retry loop.
- `retry_budget=0` uruchamia escalation albo terminal cancel zgodnie z FSM.

4. Dla transition z check result:
- `check=pass` prowadzi do stanu pozytywnego.
- `check=fail` prowadzi do stanu remediacji (`refactor-required`/analogiczny).

5. Dla zdarzen authz:
- `authz.denied` zawsze generuje `Exception(authz)` i blokuje zmiane stanu docelowego OP.

6. Rozstrzyganie konfliktow:
- jesli istnieje regula jawna i regula rozszerzajaca, pierwszenstwo ma regula jawna.
