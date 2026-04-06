## State Machines (kanoniczne)

Cel: kazdy OP ma jednoznaczny lifecycle opisany jako formalny graf przejsc.
Nie ograniczamy sie do happy path: modele obejmuja gate outcomes, rework, retry i eskalacje.

## Semantyka przejsc

Kazde przejscie opisujemy kontraktem:
- from_state
- event
- guards
- actions
- to_state
- failure_policy (retry | rework | compensation | escalation | reject)

## Konwencje globalne

1. Transition jest legalny tylko gdy istnieje jawny wpis w tej specyfikacji.
2. Kazdy transition wymaga ProcessEvent (audit contract).
3. Gdy transition ma gate-required, wynik `approve|request_changes|defer|reject` musi byc jawny.
4. `request_changes` tworzy petle rework (cykl), `defer` zatrzymuje progres, `reject` zamyka sciezke.
5. `authz.denied` blokuje transition i kieruje do `Exception.detected` (bez zmiany stanu OP).
6. `timeout.fired` uruchamia retry albo eskalacje zgodnie z failure_policy.

## Maszyny stanow per OP

### Project
States:
created, configured, baseline-approved, active, archived

Transitions:
1. created --project.configure-requested--> configured
2. configured --project.baseline-approve-requested (gate=approve)--> baseline-approved
3. configured --project.baseline-approve-requested (gate=request_changes)--> configured
4. configured --project.baseline-approve-requested (gate=defer)--> configured
5. configured --project.baseline-approve-requested (gate=reject)--> archived
6. baseline-approved --project.activate-requested--> active
7. active --project.archive-requested (gate=approve)--> archived
8. active --project.archive-requested (gate=request_changes|defer)--> active

### Requirement
States:
proposed, clarified, approved, linked, deprecated

Transitions:
1. proposed --requirement.clarify-requested--> clarified
2. proposed --requirement.cancel-requested--> deprecated
3. clarified --requirement.approve-requested (gate=approve)--> approved
4. clarified --requirement.approve-requested (gate=request_changes)--> clarified
5. clarified --requirement.approve-requested (gate=defer)--> clarified
6. clarified --requirement.approve-requested (gate=reject)--> deprecated
7. approved --requirement.link-requested--> linked
8. linked --requirement.rework-requested--> clarified
9. linked --requirement.deprecate-requested (gate=approve)--> deprecated
10. linked --requirement.deprecate-requested (gate=request_changes|defer)--> linked

### Constraint
States:
proposed, validated, enforced, revised, retired

Transitions:
1. proposed --constraint.validate-requested--> validated
2. validated --constraint.enforce-requested (gate=approve)--> enforced
3. validated --constraint.enforce-requested (gate=request_changes|defer)--> validated
4. validated --constraint.enforce-requested (gate=reject)--> retired
5. enforced --constraint.revise-requested--> revised
6. revised --constraint.enforce-requested (gate=approve)--> enforced
7. revised --constraint.enforce-requested (gate=request_changes|defer)--> revised
8. revised --constraint.retire-requested (gate=approve)--> retired
9. revised --constraint.retire-requested (gate=request_changes|defer)--> revised

### DecisionRecord
States:
drafted, reviewed, approved, superseded

Transitions:
1. drafted --decision.review-requested--> reviewed
2. reviewed --decision.approve-requested (gate=approve)--> approved
3. reviewed --decision.approve-requested (gate=request_changes)--> drafted
4. reviewed --decision.approve-requested (gate=defer)--> reviewed
5. reviewed --decision.approve-requested (gate=reject)--> superseded
6. approved --decision.supersede-requested (gate=approve)--> superseded
7. approved --decision.supersede-requested (gate=request_changes|defer)--> approved

### Idea
States:
captured, scoped, converted, dropped

Transitions:
1. captured --idea.scope-requested--> scoped
2. scoped --idea.convert-requested (gate=approve)--> converted
3. scoped --idea.convert-requested (gate=request_changes)--> scoped
4. scoped --idea.convert-requested (gate=defer)--> scoped
5. scoped --idea.convert-requested (gate=reject)--> dropped

### Feature
States:
drafted, specified, ux-aligned, scenario-ready, test-ready, implemented, stabilized, released, done

Transitions:
1. drafted --feature.specify-requested--> specified
2. specified --feature.ux-align-requested--> ux-aligned
3. ux-aligned --feature.scenario-ready-requested--> scenario-ready
4. scenario-ready --feature.test-ready-requested--> test-ready
5. test-ready --feature.implement-requested--> implemented
6. implemented --feature.stabilize-requested (gate=approve)--> stabilized
7. implemented --feature.stabilize-requested (gate=request_changes)--> test-ready
8. implemented --feature.stabilize-requested (gate=defer)--> implemented
9. implemented --feature.stabilize-requested (gate=reject)--> specified
10. stabilized --feature.release-requested--> released
11. released --feature.done-requested (gate=approve)--> done
12. released --feature.done-requested (gate=request_changes)--> stabilized
13. released --feature.done-requested (gate=defer)--> released
14. released --feature.done-requested (gate=reject)--> stabilized

### Scenario
States:
drafted, approved, test-linked, passing, obsolete

Transitions:
1. drafted --scenario.approve-requested (gate=approve)--> approved
2. drafted --scenario.approve-requested (gate=request_changes|defer)--> drafted
3. drafted --scenario.approve-requested (gate=reject)--> obsolete
4. approved --scenario.link-tests-requested--> test-linked
5. test-linked --scenario.tests-pass--> passing
6. test-linked --scenario.tests-fail--> approved
7. passing --scenario.obsolete-requested (gate=approve)--> obsolete
8. passing --scenario.obsolete-requested (gate=request_changes|defer)--> passing

### Term
States:
proposed, approved, deprecated

Transitions:
1. proposed --term.approve-requested (gate=approve)--> approved
2. proposed --term.approve-requested (gate=request_changes|defer)--> proposed
3. proposed --term.approve-requested (gate=reject)--> deprecated
4. approved --term.deprecate-requested (gate=approve)--> deprecated
5. approved --term.deprecate-requested (gate=request_changes|defer)--> approved

### UIComponent
States:
proposed, mapped, implemented, verified, deprecated

Transitions:
1. proposed --ui.map-requested--> mapped
2. mapped --ui.implement-requested--> implemented
3. implemented --ui.verify-requested (gate=approve)--> verified
4. implemented --ui.verify-requested (gate=request_changes)--> mapped
5. implemented --ui.verify-requested (gate=defer)--> implemented
6. implemented --ui.verify-requested (gate=reject)--> deprecated
7. verified --ui.deprecate-requested (gate=approve)--> deprecated
8. verified --ui.deprecate-requested (gate=request_changes|defer)--> verified

### UIScreen
States:
proposed, mapped, verified, deprecated

Transitions:
1. proposed --screen.map-requested--> mapped
2. mapped --screen.verify-requested (gate=approve)--> verified
3. mapped --screen.verify-requested (gate=request_changes)--> mapped
4. mapped --screen.verify-requested (gate=defer)--> mapped
5. mapped --screen.verify-requested (gate=reject)--> deprecated
6. verified --screen.deprecate-requested (gate=approve)--> deprecated
7. verified --screen.deprecate-requested (gate=request_changes|defer)--> verified

### PromptTask
States:
created, ready, executed, validated, closed, cancelled

Transitions:
1. created --prompt.context-ready--> ready
2. ready --prompt.sent--> executed
3. ready --prompt.cancel-requested--> cancelled
4. ready --timeout.fired (retry_budget>0)--> ready
5. ready --timeout.fired (retry_budget=0)--> cancelled
6. executed --prompt.validation-requested (gate=approve)--> validated
7. executed --prompt.validation-requested (gate=request_changes)--> ready
8. executed --prompt.validation-requested (gate=defer)--> executed
9. executed --prompt.validation-requested (gate=reject)--> cancelled
10. validated --prompt.close-requested--> closed

### GateDecision
States:
recorded

Transitions:
1. * --gate.recorded(approve|request_changes|defer|reject)--> recorded

### ActorRolePermission
States:
defined, active, revised, revoked

Transitions:
1. defined --permission.activate-requested (gate=approve)--> active
2. defined --permission.activate-requested (gate=request_changes|defer)--> defined
3. defined --permission.activate-requested (gate=reject)--> revoked
4. active --permission.revise-requested (gate=approve)--> revised
5. active --permission.revise-requested (gate=request_changes|defer)--> active
6. revised --permission.activate-requested (gate=approve)--> active
7. revised --permission.activate-requested (gate=request_changes|defer)--> revised
8. revised --permission.revoke-requested (gate=approve)--> revoked
9. revised --permission.revoke-requested (gate=request_changes|defer)--> revised

### Dependency
States:
identified, validated, satisfied, blocked, waived

Transitions:
1. identified --dependency.validate-requested--> validated
2. validated --dependency.satisfy-requested--> satisfied
3. validated --dependency.blocked-detected--> blocked
4. validated --dependency.waive-requested (gate=approve)--> waived
5. validated --dependency.waive-requested (gate=request_changes|defer)--> validated
6. blocked --dependency.unblock-requested--> validated

### UseCase
States:
drafted, reviewed, approved, implemented, verified, deprecated

Transitions:
1. drafted --usecase.review-requested--> reviewed
2. reviewed --usecase.approve-requested (gate=approve)--> approved
3. reviewed --usecase.approve-requested (gate=request_changes)--> drafted
4. reviewed --usecase.approve-requested (gate=defer)--> reviewed
5. reviewed --usecase.approve-requested (gate=reject)--> deprecated
6. approved --usecase.implement-requested--> implemented
7. implemented --usecase.verify-requested (gate=approve)--> verified
8. implemented --usecase.verify-requested (gate=request_changes)--> approved
9. implemented --usecase.verify-requested (gate=defer)--> implemented
10. implemented --usecase.verify-requested (gate=reject)--> deprecated

### PortContract
States:
proposed, reviewed, approved, adopted, deprecated

Transitions:
1. proposed --port-contract.review-requested--> reviewed
2. reviewed --port-contract.approve-requested (gate=approve)--> approved
3. reviewed --port-contract.approve-requested (gate=request_changes)--> proposed
4. reviewed --port-contract.approve-requested (gate=defer)--> reviewed
5. reviewed --port-contract.approve-requested (gate=reject)--> deprecated
6. approved --port-contract.adopt-requested--> adopted
7. adopted --port-contract.revise-requested--> proposed
8. adopted --port-contract.deprecate-requested (gate=approve)--> deprecated
9. adopted --port-contract.deprecate-requested (gate=request_changes|defer)--> adopted

### Component
States:
identified, mapped, checked, compliant, refactor-required, deprecated

Transitions:
1. identified --component.map-requested--> mapped
2. mapped --component.check-requested (check=pass)--> checked
3. mapped --component.check-requested (check=fail)--> refactor-required
4. refactor-required --component.remediate-requested--> mapped
5. checked --component.compliance-requested (gate=approve)--> compliant
6. checked --component.compliance-requested (gate=request_changes)--> refactor-required
7. checked --component.compliance-requested (gate=defer)--> checked
8. checked --component.compliance-requested (gate=reject)--> refactor-required
9. compliant --component.deprecate-requested (gate=approve)--> deprecated
10. compliant --component.deprecate-requested (gate=request_changes|defer)--> compliant

### Risk
States:
identified, assessed, mitigated, accepted, escalated, closed

Transitions:
1. identified --risk.assess-requested--> assessed
2. assessed --risk.mitigate-requested (gate=approve)--> mitigated
3. assessed --risk.mitigate-requested (gate=request_changes|defer)--> assessed
4. assessed --risk.accept-requested (gate=approve)--> accepted
5. assessed --risk.accept-requested (gate=request_changes|defer)--> assessed
6. assessed --risk.escalate-requested (gate=approve)--> escalated
7. assessed --risk.escalate-requested (gate=request_changes|defer)--> assessed
8. mitigated --risk.close-requested--> closed
9. accepted --risk.close-requested--> closed
10. escalated --risk.resolve-requested (gate=approve)--> closed
11. escalated --risk.resolve-requested (gate=request_changes|defer)--> escalated

### Release
States:
planned, candidate, approved, published, closed

Transitions:
1. planned --release.candidate-requested--> candidate
2. candidate --release.approve-requested (gate=approve)--> approved
3. candidate --release.approve-requested (gate=request_changes)--> planned
4. candidate --release.approve-requested (gate=defer)--> candidate
5. candidate --release.approve-requested (gate=reject)--> closed
6. approved --deployment.succeeded--> published
7. approved --deployment.failed--> candidate
8. published --release.close-requested (gate=approve)--> closed
9. published --release.close-requested (gate=request_changes|defer)--> published

### Deployment
States:
prepared, running, succeeded, failed

Transitions:
1. prepared --deployment.start-requested--> running
2. running --deployment.completed--> succeeded
3. running --deployment.failed--> failed
4. failed --deployment.retry-requested (gate=approve)--> prepared
5. failed --deployment.retry-requested (gate=request_changes|defer)--> failed
6. failed --rollback.started--> failed

### Rollback
States:
prepared, running, succeeded, failed

Transitions:
1. prepared --rollback.start-requested--> running
2. running --rollback.completed--> succeeded
3. running --rollback.failed--> failed
4. failed --rollback.retry-requested (gate=approve)--> prepared
5. failed --rollback.retry-requested (gate=request_changes|defer)--> failed

### QualitySignal
States:
collected, evaluated, pass, fail

Transitions:
1. collected --quality.evaluate-requested--> evaluated
2. evaluated --quality.passed--> pass
3. evaluated --quality.failed--> fail
4. fail --quality.recheck-requested--> evaluated

### Exception
States:
detected, classified, handled, escalated

Transitions:
1. detected --exception.classify-requested--> classified
2. classified --exception.handle-requested (gate=approve)--> handled
3. classified --exception.handle-requested (gate=request_changes)--> classified
4. classified --exception.handle-requested (gate=defer)--> escalated
5. classified --exception.handle-requested (gate=reject)--> escalated
6. escalated --exception.reassess-requested--> classified

### Timeout
States:
scheduled, fired, handled, escalated

Transitions:
1. scheduled --timeout.fired--> fired
2. fired --timeout.handle-requested (gate=approve)--> handled
3. fired --timeout.handle-requested (gate=request_changes)--> scheduled
4. fired --timeout.handle-requested (gate=defer|reject)--> escalated
5. escalated --timeout.recover-requested--> scheduled

### Compensation
States:
planned, running, completed, failed

Transitions:
1. planned --compensation.start-requested--> running
2. running --compensation.completed--> completed
3. running --compensation.failed--> failed
4. failed --compensation.retry-requested (gate=approve)--> planned
5. failed --compensation.retry-requested (gate=request_changes|defer|reject)--> failed

### ProcessEvent
States:
recorded

Transitions:
1. * --event.appended--> recorded

## Guard conditions (przyklady przekrojowe)

1. Feature.implemented wymaga:
- co najmniej jeden UseCase.approved (gdy feature ma behavior biznesowy),
- brak PortContract niezatwierdzonych dla tych UseCase.

2. Feature.stabilized wymaga:
- GateDecision=approve,
- QualitySignal=pass,
- powiazany Component nie jest w stanie refactor-required.

3. Release.approved wymaga:
- brak Risk.escalated o krytycznosci high,
- brak Dependency.blocked.

4. UseCase.verified wymaga:
- test logiki biznesowej bez UI/DB/sieci.

5. PortContract.approved wymaga:
- schema DTO bez frameworkowych typow,
- jawny owner_use_case.

6. Component.checked wymaga:
- check dependency-direction=pass,
- check no-cycle(ADP)=pass.

## Hierarchia i zakazy

1. OP nizszego poziomu nie moze wyprzedzac OP nadrzednego.
2. GateDecision bez review package jest niewazna.
3. Feature nie przejdzie do done przy krytycznym Exception bez Compensation.completed.
4. Zmiana stanu bez ProcessEvent jest niewazna.
