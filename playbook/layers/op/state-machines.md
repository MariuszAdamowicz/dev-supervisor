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
2. Kazdy transition wymaga ProcessEventRecord (audit contract).
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
drafted, reviewed, approved, test-linked, passing, obsolete

Transitions:
1. drafted --scenario.review-requested--> reviewed
2. reviewed --scenario.approve-requested (gate=approve)--> approved
3. reviewed --scenario.approve-requested (gate=request_changes)--> drafted
4. reviewed --scenario.approve-requested (gate=defer)--> reviewed
5. reviewed --scenario.approve-requested (gate=reject)--> obsolete
6. approved --scenario.link-tests-requested--> test-linked
7. test-linked --scenario.tests-pass--> passing
8. test-linked --scenario.tests-fail--> approved
9. passing --scenario.obsolete-requested (gate=approve)--> obsolete
10. passing --scenario.obsolete-requested (gate=request_changes|defer)--> passing

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

### Repository
States:
detected, initialized, remote-attached, policy-aligned, active, archived

Transitions:
1. detected --repo.initialize-requested--> initialized
2. initialized --repo.attach-remote-requested--> remote-attached
3. remote-attached --repo.align-policy-requested (gate=approve)--> policy-aligned
4. remote-attached --repo.align-policy-requested (gate=request_changes|defer)--> remote-attached
5. remote-attached --repo.align-policy-requested (gate=reject)--> archived
6. policy-aligned --repo.activate-requested--> active
7. active --repo.archive-requested (gate=approve)--> archived
8. active --repo.archive-requested (gate=request_changes|defer)--> active

### ChangeSet
States:
drafted, staged, validated, committed, superseded

Transitions:
1. drafted --changeset.stage-requested--> staged
2. staged --changeset.validate-requested (gate=approve)--> validated
3. staged --changeset.validate-requested (gate=request_changes|defer)--> staged
4. staged --changeset.validate-requested (gate=reject)--> superseded
5. validated --changeset.commit-requested--> committed
6. committed --changeset.supersede-requested (gate=approve)--> superseded
7. committed --changeset.supersede-requested (gate=request_changes|defer)--> committed

### VerificationPlan
States:
drafted, reviewed, approved, active, revised, retired

Transitions:
1. drafted --verification.review-requested--> reviewed
2. reviewed --verification.approve-requested (gate=approve)--> approved
3. reviewed --verification.approve-requested (gate=request_changes)--> drafted
4. reviewed --verification.approve-requested (gate=defer)--> reviewed
5. reviewed --verification.approve-requested (gate=reject)--> retired
6. approved --verification.activate-requested--> active
7. active --verification.revise-requested--> revised
8. revised --verification.approve-requested (gate=approve)--> approved
9. revised --verification.approve-requested (gate=request_changes|defer)--> revised
10. revised --verification.retire-requested (gate=approve)--> retired
11. revised --verification.retire-requested (gate=request_changes|defer)--> revised

### DataSchema
States:
drafted, reviewed, approved, applied, superseded, deprecated

Transitions:
1. drafted --schema.review-requested--> reviewed
2. reviewed --schema.approve-requested (gate=approve)--> approved
3. reviewed --schema.approve-requested (gate=request_changes)--> drafted
4. reviewed --schema.approve-requested (gate=defer)--> reviewed
5. reviewed --schema.approve-requested (gate=reject)--> deprecated
6. approved --schema.apply-requested--> applied
7. applied --schema.supersede-requested (gate=approve)--> superseded
8. applied --schema.supersede-requested (gate=request_changes|defer)--> applied
9. superseded --schema.deprecate-requested (gate=approve)--> deprecated
10. superseded --schema.deprecate-requested (gate=request_changes|defer)--> superseded

### Migration
States:
drafted, reviewed, approved, ready, applied, rolled-back, superseded

Transitions:
1. drafted --migration.review-requested--> reviewed
2. reviewed --migration.approve-requested (gate=approve)--> approved
3. reviewed --migration.approve-requested (gate=request_changes)--> drafted
4. reviewed --migration.approve-requested (gate=defer)--> reviewed
5. reviewed --migration.approve-requested (gate=reject)--> superseded
6. approved --migration.ready-requested--> ready
7. ready --migration.apply-requested--> applied
8. applied --migration.rollback-requested (gate=approve)--> rolled-back
9. applied --migration.rollback-requested (gate=request_changes|defer)--> applied
10. applied --migration.supersede-requested (gate=approve)--> superseded
11. applied --migration.supersede-requested (gate=request_changes|defer)--> applied
12. rolled-back --migration.supersede-requested (gate=approve)--> superseded
13. rolled-back --migration.supersede-requested (gate=request_changes|defer)--> rolled-back

### RuntimeEnvironment
States:
defined, validated, ready, active, degraded, retired

Transitions:
1. defined --environment.validate-requested--> validated
2. validated --environment.readiness-requested (gate=approve)--> ready
3. validated --environment.readiness-requested (gate=request_changes|defer)--> validated
4. validated --environment.readiness-requested (gate=reject)--> retired
5. ready --environment.activate-requested--> active
6. active --environment.degraded-detected--> degraded
7. degraded --environment.recover-requested--> ready
8. ready --environment.retire-requested (gate=approve)--> retired
9. ready --environment.retire-requested (gate=request_changes|defer)--> ready
10. active --environment.retire-requested (gate=approve)--> retired
11. active --environment.retire-requested (gate=request_changes|defer)--> active

## Guard conditions (przyklady przekrojowe)

1. Feature.implemented wymaga:
- co najmniej jeden UseCase.approved (gdy feature ma behavior biznesowy),
- brak PortContract niezatwierdzonych dla tych UseCase.

2. Feature.stabilized wymaga:
- GateDecisionRecord=approve,
- QualityEvidenceRecord=pass,
- powiazany Component nie jest w stanie refactor-required.

3. Release.approved wymaga:
- brak Risk.escalated o krytycznosci high,
- brak DependencyRelation.status=blocked dla scope release/delivery.

4. UseCase.verified wymaga:
- test logiki biznesowej bez UI/DB/sieci.

5. PortContract.approved wymaga:
- schema DTO bez frameworkowych typow,
- jawny owner_use_case.

6. Component.checked wymaga:
- check dependency-direction=pass,
- check no-cycle(ADP)=pass.

7. Repository.policy-aligned wymaga:
- lokalne repo istnieje,
- remote origin jest jawnie przypiety,
- polityka branch/commit jest zapisana dla projektu.

8. ChangeSet.validated wymaga:
- jawne traceability do co najmniej jednego OP pracy,
- wynik lanes wymaganych przez VerificationPlan,
- diff scope i file ownership bez nieautoryzowanego wycieku poza zakres.

9. VerificationPlan.approved wymaga:
- okreslenie wymaganych warstw unit/integration/acceptance/e2e lub jawne `not_applicable`,
- mapowanie lane -> stack/profile capability,
- jawna regula evidence provenance.

10. DataSchema.applied wymaga:
- brak konfliktu z aktywna kompatybilnoscia RuntimeEnvironment,
- Migration.approved lub jawny no-op migration note,
- jawny rollback/compatibility plan dla zmian niekompatybilnych.

11. RuntimeEnvironment.ready wymaga:
- sprawdzone capabilities uruchomieniowe i sekrety/config,
- zgodnosc z Release albo VerificationPlan dla danego lane.

## Hierarchia i zakazy

1. OP nizszego poziomu nie moze wyprzedzac OP nadrzednego.
2. GateDecisionRecord bez review package jest niewazna.
3. Feature nie przejdzie do done przy krytycznym Exception z `compensation_required=true` bez `CompensationAction.status=completed`.
4. Zmiana stanu bez ProcessEventRecord jest niewazna.
5. ChangeSet nie przejdzie do committed bez powiazania z Repository i co najmniej jednym OP pracy.
6. Migration nie przejdzie do applied bez DataSchema w stanie co najmniej approved.
7. Deployment i Release nie moga polegac na RuntimeEnvironment ponizej stanu ready.

## System record contracts

Te byty nie sa OP i nie maja niezaleznego FSM, ale sa kanonicznie wymagane:

### GateDecisionRecord
- append-only
- powstaje przy kazdym gate-required transition
- brak rekordu przy gate-required transition uniewaznia transition

### ProcessEventRecord
- append-only
- powstaje dla attempt, block, commit, propagation i recovery
- brak rekordu uniewaznia transition lub propagation effect

### QualityEvidenceRecord
- append-only
- zapisuje wynik konkretnej lane/check
- `pass/fail` jest ocena dowodowa dla subject_ref, a nie osobny OP lifecycle

## Recovery control contracts

### CompensationAction
- nie jest OP
- statusy: `planned`, `running`, `completed`, `failed`, `cancelled`
- `planned` powstaje po awarii, reject albo triggerze recovery z policy
- `running` oznacza wykonywanie undo/cleanup
- `completed` domyka wymagane recovery i moze odblokowac closure `Exception` lub `Rollback`
- `failed` wymaga eskalacji albo nowej decyzji gate/retry
- `cancelled` wymaga jawnego reason i jest legalne tylko gdy target scope zostal zamkniety inna legalna sciezka
