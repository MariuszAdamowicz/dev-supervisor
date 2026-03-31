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

- Event: Deployment.failed
- Action: utworz Rollback.prepared + Compensation.planned

### 5. Timeout i eskalacje
- Event: Timeout.fired
- Action: utworz Exception(timeout) + GateDecision(defer) candidate
- Failure policy: escalation do operatora

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
