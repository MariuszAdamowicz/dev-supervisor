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
- Action: utworz GateDecision(defer|request_changes) candidate dla delivery
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

### 3. Jakosc i gate
- Event: PromptTask.executed
- Action: zbuduj review package (diff + mapowanie do BDD + build/test/lint)

- Event: PromptTask.executed
- Action: utworz PromptTask(validation-review)
- Gate effect: odblokowuje PromptTask.validated po review package

- Event: PromptTask.validated
- Action: zamknij PromptTask (state=closed)

- Event: QualitySignal.pass
- Action: odblokuj kolejne legalne transition OP

- Event: QualitySignal.fail
- Action: utworz Exception + PromptTask(debug-fix)
- Gate effect: wymusza GateDecision=request_changes lub defer

- Event: GateDecision.approve
- Action: odblokuj kolejny stan OP

- Event: GateDecision.request_changes
- Action: utworz PromptTask(rework)

### 4. Delivery
- Event: Feature.stabilized
- Guard: brak krytycznych Exception, Dependency!=blocked
- Action: utworz Release.candidate

- Event: Release.approved
- Action: utworz Deployment.prepared

- Event: Deployment.succeeded
- Action: oznacz Release.published + odblokuj Feature.released
- Gate effect: otwiera zamkniecie Release i Feature

- Event: Release.published
- Action: utworz PromptTask(release-close-review) + PromptTask(feature-close-review)

- Event: Deployment.failed
- Action: utworz Rollback.prepared + Compensation.planned

### 5. Timeout i eskalacje
- Event: Timeout.fired
- Action: utworz Exception(timeout) + GateDecision(defer) candidate
- Failure policy: escalation do operatora

### 6. Lifecycle housekeeping
- Event: project.archive-requested
- Action: utworz review package archiwizacji + GateDecision candidate

## Retry / idempotency / compensation

- Retry stosuj tylko dla operacji oznaczonych retryable.
- Kazdy trigger ma idempotency_key, aby uniknac duplikatow PromptTask.
- Po przekroczeniu limitu retry wymagane jest Compensation lub decyzja reject/defer.

## Reguly bezpieczenstwa i uprawnien

- Action mozliwa tylko gdy ActorRolePermission pozwala na dana operacje.
- Brak uprawnien generuje Exception(authz) i blokuje transition.

## Audit

- Kazdy trigger execution zapisuje ProcessEvent.
- Brak ProcessEvent = przejscie uznane za niewazne.
