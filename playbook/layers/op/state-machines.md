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
5. `authz.denied` blokuje transition i kieruje do `ExceptionCase.detected` (bez zmiany stanu OP).
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

## Guard conditions (przyklady przekrojowe)

1. Feature.implemented wymaga:
- co najmniej jeden UseCase.approved (gdy feature ma behavior biznesowy),
- brak PortContract niezatwierdzonych dla tych UseCase.

2. Feature.stabilized wymaga:
- GateDecisionRecord=approve,
- QualityEvidenceRecord=pass,
- powiazany Component nie jest w stanie refactor-required.

3. ReleaseBundle.approved wymaga:
- brak RiskEntry.escalated o krytycznosci high,
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
- wynik lanes wymaganych przez VerificationPolicy,
- diff scope i file ownership bez nieautoryzowanego wycieku poza zakres.

9. VerificationPolicy.approved wymaga:
- okreslenie wymaganych warstw unit/integration/acceptance/e2e lub jawne `not_applicable`,
- mapowanie lane -> stack/profile capability,
- jawna regula evidence provenance.

10. DataSchema.applied wymaga:
- brak konfliktu z aktywnym `EnvironmentTarget`,
- MigrationAction.approved lub jawny no-op migration note,
- jawny rollback/compatibility plan dla zmian niekompatybilnych.

11. EnvironmentTarget.ready wymaga:
- sprawdzone capabilities uruchomieniowe i sekrety/config,
- zgodnosc z ReleaseBundle albo VerificationPolicy dla danego lane.

## Hierarchia i zakazy

1. OP nizszego poziomu nie moze wyprzedzac OP nadrzednego.
2. GateDecisionRecord bez review package jest niewazna.
3. Feature nie przejdzie do done przy krytycznym ExceptionCase z `compensation_required=true` bez `CompensationAction.status=completed`.
4. Zmiana stanu bez ProcessEventRecord jest niewazna.
5. ChangeSet nie przejdzie do committed bez powiazania z Repository control i co najmniej jednym OP pracy.
6. MigrationAction nie przejdzie do applied bez DataSchema w stanie co najmniej approved.
7. DeploymentRun i ReleaseBundle nie moga polegac na `EnvironmentTarget` ponizej stanu `ready`.

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

## Decision control contracts

### DecisionRecord
- nie jest OP
- statusy: `drafted`, `reviewed`, `approved`, `superseded`
- `drafted` powstaje przy nowej decyzji baseline albo zmianie architektonicznej
- `reviewed` oznacza gotowy review package opcji i konsekwencji
- `approved` oznacza decyzje obowiazujaca dla downstream scope
- `superseded` oznacza decyzje zastapiona nowa albo jawnie odrzucona
- legalne przejscia:
  - `drafted --decision.review-requested--> reviewed`
  - `reviewed --decision.approve-requested (gate=approve)--> approved`
  - `reviewed --decision.approve-requested (gate=request_changes)--> drafted`
  - `reviewed --decision.approve-requested (gate=defer)--> reviewed`
  - `reviewed --decision.approve-requested (gate=reject)--> superseded`
  - `approved --decision.supersede-requested (gate=approve)--> superseded`
  - `approved --decision.supersede-requested (gate=request_changes|defer)--> approved`

## Data control contracts

### MigrationAction
- nie jest OP
- statusy: `drafted`, `reviewed`, `approved`, `ready`, `applied`, `rolled-back`, `superseded`
- `drafted` powstaje przy niekompatybilnej albo operacyjnie istotnej zmianie danych
- `reviewed` oznacza gotowy review package kompatybilnosci i apply window
- `approved` oznacza zatwierdzony plan migracji
- `ready` oznacza gotowosc lane i rollback readiness
- `applied` oznacza wykonana migracje
- `rolled-back` oznacza cofniecie migracji legalna sciezka recovery
- `superseded` oznacza plan zastapiony nowym albo jawnie wycofany
- legalne przejscia:
  - `drafted --migration.review-requested--> reviewed`
  - `reviewed --migration.approve-requested (gate=approve)--> approved`
  - `reviewed --migration.approve-requested (gate=request_changes)--> drafted`
  - `reviewed --migration.approve-requested (gate=defer)--> reviewed`
  - `reviewed --migration.approve-requested (gate=reject)--> superseded`
  - `approved --migration.ready-requested--> ready`
  - `ready --migration.apply-requested--> applied`
  - `applied --migration.rollback-requested (gate=approve)--> rolled-back`
  - `applied --migration.rollback-requested (gate=request_changes|defer)--> applied`
  - `applied --migration.supersede-requested (gate=approve)--> superseded`
  - `applied --migration.supersede-requested (gate=request_changes|defer)--> applied`
  - `rolled-back --migration.supersede-requested (gate=approve)--> superseded`
  - `rolled-back --migration.supersede-requested (gate=request_changes|defer)--> rolled-back`

## Version-control control contracts

### Repository
- nie jest OP
- statusy: `detected`, `initialized`, `remote-attached`, `policy-aligned`, `active`, `archived`
- `detected` powstaje przy bootstrapie projektu albo wykryciu repo root
- `initialized` oznacza gotowe lokalne repo
- `remote-attached` oznacza jawnie przypiety remote
- `policy-aligned` oznacza zgodnosc z polityka branch/commit
- `active` oznacza repo gotowe do pracy dla biezacego scope
- `archived` zamyka repo dla aktywnej pracy bez wymazywania historii
- legalne przejscia:
  - `detected --repo.initialize-requested--> initialized`
  - `initialized --repo.attach-remote-requested--> remote-attached`
  - `remote-attached --repo.align-policy-requested (gate=approve)--> policy-aligned`
  - `remote-attached --repo.align-policy-requested (gate=request_changes|defer)--> remote-attached`
  - `remote-attached --repo.align-policy-requested (gate=reject)--> archived`
  - `policy-aligned --repo.activate-requested--> active`
  - `active --repo.archive-requested (gate=approve)--> archived`
  - `active --repo.archive-requested (gate=request_changes|defer)--> active`

## Verification control contracts

### VerificationPolicy
- nie jest OP
- statusy: `drafted`, `reviewed`, `approved`, `active`, `revised`, `retired`
- `drafted` powstaje przy baseline albo nowym scope formalnej walidacji
- `approved` oznacza zaakceptowana polityke lane i evidence dla target scope
- `active` oznacza polityke obowiazujaca dla biezacego scope wykonania
- `revised` oznacza polityke po zmianie stacku, ryzyka albo delivery lane
- `retired` domyka polityke po zastapieniu albo zamknieciu scope
- legalne przejscia:
  - `drafted --verification.review-requested--> reviewed`
  - `reviewed --verification.approve-requested (gate=approve)--> approved`
  - `reviewed --verification.approve-requested (gate=request_changes)--> drafted`
  - `reviewed --verification.approve-requested (gate=defer)--> reviewed`
  - `reviewed --verification.approve-requested (gate=reject)--> retired`
  - `approved --verification.activate-requested--> active`
  - `active --verification.revise-requested--> revised`
  - `revised --verification.approve-requested (gate=approve)--> approved`
  - `revised --verification.approve-requested (gate=request_changes|defer)--> revised`
  - `revised --verification.retire-requested (gate=approve)--> retired`
  - `revised --verification.retire-requested (gate=request_changes|defer)--> revised`

## Authz control contracts

### AccessGrant
- nie jest OP
- statusy: `defined`, `active`, `revised`, `revoked`
- `defined` powstaje przy bootstrapie projektu albo nowym scope authz
- `active` odblokowuje legalne akcje dla `principal_ref + scope_ref + allowed_actions`
- `revised` oznacza grant po zmianie, wymagajacy reaktywacji albo revoke
- `revoked` blokuje dalsze akcje i pozostaje w audycie
- legalne przejscia:
  - `defined --permission.activate-requested (gate=approve)--> active`
  - `defined --permission.activate-requested (gate=request_changes|defer)--> defined`
  - `defined --permission.activate-requested (gate=reject)--> revoked`
  - `active --permission.revise-requested (gate=approve)--> revised`
  - `active --permission.revise-requested (gate=request_changes|defer)--> active`
  - `revised --permission.activate-requested (gate=approve)--> active`
  - `revised --permission.activate-requested (gate=request_changes|defer)--> revised`
  - `revised --permission.revoke-requested (gate=approve)--> revoked`
  - `revised --permission.revoke-requested (gate=request_changes|defer)--> revised`

## Glossary control contracts

### GlossaryEntry
- nie jest OP
- statusy: `proposed`, `approved`, `deprecated`
- `proposed` powstaje przy wykryciu nowego pojecia domenowego albo labelu UX
- `approved` oznacza termin kanoniczny dla copy/UX/scenario
- `deprecated` oznacza termin wycofywany z replacement albo cleanup path
- legalne przejscia:
  - `proposed --term.approve-requested (gate=approve)--> approved`
  - `proposed --term.approve-requested (gate=request_changes|defer)--> proposed`
  - `proposed --term.approve-requested (gate=reject)--> deprecated`
  - `approved --term.deprecate-requested (gate=approve)--> deprecated`
  - `approved --term.deprecate-requested (gate=request_changes|defer)--> approved`

## Risk control contracts

### RiskEntry
- nie jest OP
- statusy: `identified`, `assessed`, `mitigated`, `accepted`, `escalated`, `closed`
- `identified` powstaje przy wykryciu ryzyka dla feature, release, environment albo architektury
- `assessed` oznacza, ze likelihood/impact/criticality zostaly jawnie ocenione
- `mitigated` oznacza, ze ryzyko ma zaakceptowany plan redukcji
- `accepted` oznacza residual risk zaakceptowany jawna decyzja
- `escalated` blokuje delivery scope do czasu closure albo override
- `closed` domyka wpis rejestru ryzyka przy zachowaniu audytu
- legalne przejscia:
  - `identified --risk.assess-requested--> assessed`
  - `assessed --risk.mitigate-requested (gate=approve)--> mitigated`
  - `assessed --risk.mitigate-requested (gate=request_changes|defer)--> assessed`
  - `assessed --risk.accept-requested (gate=approve)--> accepted`
  - `assessed --risk.accept-requested (gate=request_changes|defer)--> assessed`
  - `assessed --risk.escalate-requested (gate=approve)--> escalated`
  - `assessed --risk.escalate-requested (gate=request_changes|defer)--> assessed`
  - `mitigated --risk.close-requested--> closed`
  - `accepted --risk.close-requested--> closed`
  - `escalated --risk.resolve-requested (gate=approve)--> closed`
  - `escalated --risk.resolve-requested (gate=request_changes|defer)--> escalated`

## Exception control contracts

### ExceptionCase
- nie jest OP
- statusy: `detected`, `classified`, `handled`, `escalated`
- `detected` powstaje przy authz deny, quality fail, timeout albo runtime error
- `classified` oznacza, ze severity, reason i recovery path zostaly jawnie ustalone
- `handled` oznacza, ze problem nie blokuje juz scope i ma zachowany audit trail
- `escalated` oznacza, ze problem wymaga decyzji operatora, retry albo recovery control
- legalne przejscia:
  - `detected --exception.classify-requested--> classified`
  - `classified --exception.handle-requested (gate=approve)--> handled`
  - `classified --exception.handle-requested (gate=request_changes)--> classified`
  - `classified --exception.handle-requested (gate=defer)--> escalated`
  - `classified --exception.handle-requested (gate=reject)--> escalated`
  - `escalated --exception.reassess-requested--> classified`

## Environment control contracts

### EnvironmentTarget
- nie jest OP
- statusy: `defined`, `validated`, `ready`, `active`, `degraded`, `retired`
- `defined` powstaje przy bootstrapie local/ci/stage/prod targetu
- `validated` oznacza, ze capability i config zostaly sprawdzone technicznie
- `ready` oznacza gotowosc do release, deploy albo lane validation
- `active` oznacza target aktualnie uzywany przez runtime albo rollout
- `degraded` oznacza utrate gotowosci i blocker dla delivery
- `retired` oznacza target wycofany z uzycia, zachowany w audycie
- legalne przejscia:
  - `defined --environment.validate-requested--> validated`
  - `validated --environment.readiness-requested (gate=approve)--> ready`
  - `validated --environment.readiness-requested (gate=request_changes|defer)--> validated`
  - `validated --environment.readiness-requested (gate=reject)--> retired`
  - `ready --environment.activate-requested--> active`
  - `active --environment.degraded-detected--> degraded`
  - `degraded --environment.recover-requested--> ready`
  - `ready --environment.retire-requested (gate=approve)--> retired`
  - `ready --environment.retire-requested (gate=request_changes|defer)--> ready`
  - `active --environment.retire-requested (gate=approve)--> retired`
  - `active --environment.retire-requested (gate=request_changes|defer)--> active`

## Delivery control contracts

### ReleaseBundle
- nie jest OP
- statusy: `planned`, `candidate`, `approved`, `published`, `closed`
- `planned` powstaje przy gotowosci delivery scope
- `candidate` oznacza bundle gotowy do gate review
- `approved` oznacza bundle gotowy do rollout
- `published` oznacza bundle opublikowany po sukcesie deploymentu
- `closed` domyka delivery scope i pozostaje w audycie
- legalne przejscia:
  - `planned --release.candidate-requested--> candidate`
  - `candidate --release.approve-requested (gate=approve)--> approved`
  - `candidate --release.approve-requested (gate=request_changes)--> planned`
  - `candidate --release.approve-requested (gate=defer)--> candidate`
  - `candidate --release.approve-requested (gate=reject)--> closed`
  - `approved --deployment.succeeded--> published`
  - `approved --deployment.failed--> candidate`
  - `published --release.close-requested (gate=approve)--> closed`
  - `published --release.close-requested (gate=request_changes|defer)--> published`

### DeploymentRun
- nie jest OP
- statusy: `planned`, `running`, `succeeded`, `failed`, `cancelled`
- `planned` powstaje po `ReleaseBundle.approved`
- `running` oznacza aktywny rollout albo deploy attempt
- `succeeded` odblokowuje `ReleaseBundle.published`
- `failed` cofa `ReleaseBundle` do `candidate` albo uruchamia recovery path
- `cancelled` wymaga jawnego reason i jest legalne tylko gdy rollout zostal przerwany przez inna legalna decyzje
- legalne przejscia:
  - `planned --deployment.started--> running`
  - `running --deployment.completed--> succeeded`
  - `running --deployment.failed--> failed`
  - `failed --deployment.retry-requested (gate=approve)--> planned`
  - `failed --deployment.retry-requested (gate=request_changes|defer)--> failed`

## Job control contracts

### PromptTask
- nie jest OP
- statusy: `created`, `ready`, `executed`, `validated`, `closed`, `cancelled`
- `created` powstaje przy triggerze procesu lub review requirement
- `ready` oznacza, ze kontekst i assignee/job worker sa gotowe
- `executed` oznacza, ze job zwrocil wynik albo operator dostarczyl material do review
- `validated` oznacza accepted output po gate/review
- `closed` domyka task bez dalszego retry
- `cancelled` konczy task z jawna przyczyna, np. reject albo timeout bez retry budget
- legalne przejscia:
  - `created --prompt.context-ready--> ready`
  - `ready --prompt.sent--> executed`
  - `ready --prompt.cancel-requested--> cancelled`
  - `ready --timeout.fired (retry_budget>0)--> ready`
  - `ready --timeout.fired (retry_budget=0)--> cancelled`
  - `executed --prompt.validation-requested (gate=approve)--> validated`
  - `executed --prompt.validation-requested (gate=request_changes)--> ready`
  - `executed --prompt.validation-requested (gate=defer)--> executed`
  - `executed --prompt.validation-requested (gate=reject)--> cancelled`
  - `validated --prompt.close-requested--> closed`

## Recovery control contracts

### RollbackAction
- nie jest OP
- statusy: `planned`, `running`, `completed`, `failed`, `cancelled`
- `planned` powstaje po `DeploymentRun.failed` albo `MigrationAction.rollback-requested`
- `running` oznacza wykonywanie revert do poprzedniej stabilnej rewizji
- `completed` domyka recovery dla `DeploymentRun` albo `MigrationAction`
- `failed` wymaga eskalacji albo nowej decyzji gate/retry
- `cancelled` wymaga jawnego reason i jest legalne tylko gdy target scope zostal zamkniety inna legalna sciezka

### CompensationAction
- nie jest OP
- statusy: `planned`, `running`, `completed`, `failed`, `cancelled`
- `planned` powstaje po awarii, reject albo triggerze recovery z policy
- `running` oznacza wykonywanie undo/cleanup
- `completed` domyka wymagane recovery i moze odblokowac closure `ExceptionCase` lub `RollbackAction`
- `failed` wymaga eskalacji albo nowej decyzji gate/retry
- `cancelled` wymaga jawnego reason i jest legalne tylko gdy target scope zostal zamkniety inna legalna sciezka
