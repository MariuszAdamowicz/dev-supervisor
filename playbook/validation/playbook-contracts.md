# Playbook Contracts

Cel:
formalnie walidowac kompletnosc i spojnosc Playbook Layer wzgledem OP Layer.

## 1. Contracts of Completeness

1. Coverage contract
- kazdy krytyczny legal transition z OP ma binding w tooling/bindings.md.
- brak bindingu = playbook invalid.

2. Capability contract
- kazda capability wymagana przez action istnieje w co najmniej jednym narzedziu z tooling/tool-registry.md.
- capability orphan = playbook invalid.

3. Gate contract
- transition oznaczony gate-required musi zawierac decide_gate i operator-ui.
- brak jawnej decyzji gate = transition invalid.
- gate-required MUST byc wyliczany deterministycznie klasyfikatorem z `workflow/decision-envelope.md` (brak recznej klasyfikacji ad-hoc).

3a. Decision Envelope contract
- kazdy gate-required transition musi miec kompletny Decision Envelope zgodny z `workflow/decision-envelope.md`.
- brak envelope albo brak pol krytycznych (change_set, validation, decision_effects) = transition invalid.

4. Audit contract
- kazda akcja krytyczna generuje ProcessEventRecord.
- brak audytu = transition invalid.

5. Source-of-truth contract
- Playbook Layer nie redefiniuje state machine ani trigger semantics.
- konflikt z layers/op/* = playbook invalid.

5a. Execution spec contract
- deterministyczna orkiestracja runtime MUST byc opisana w jednym pliku `runtime/playbook-exec.yaml`.
- brak mapowania `entrypoint -> steps -> tool input/output -> side effects` = playbook invalid.
- brak mapowania `workflow entrypoint -> runtime entrypoint/template` = playbook invalid.
- krok wykonawczy moze wywolywac dokladnie jedno narzedzie (one tool invocation per step).
- logika runtime poza exec spec (ukryte reguly w UI/kodzie) = playbook invalid.
- bootstrap `new_project` MUST zawierac kroki git lokalny + utworzenie/podpiecie repozytorium zdalnego (GitHub adapter lub rownowazny).

5b. Baseline completeness contract
- `workflow/setup.md` i `runtime/playbook-exec.yaml` musza definiowac ten sam minimalny baseline.
- baseline MUST obejmowac: overview, constraints, glossary, Repository, Requirement, Constraint, DecisionRecord, UseCase, PortContract, Component, AccessGrant, VerificationPolicy i artefakt UX entrypointu.
- `EnvironmentTarget` jest wymagany w baseline tylko gdy profil aktywuje `deployable-runtime`.
- brak zgodnosci workflow/exec dla baseline = playbook invalid.

5c. Runtime lifecycle coverage contract
- kazdy entrypoint wymieniony w `workflow/daily-workflow.md` musi miec runtime definition albo template coverage w `runtime/playbook-exec.yaml`.
- brak runtime coverage dla Feature, UX alignment, ReleaseBundle albo ExceptionCase/recovery/timer escalation = playbook invalid.

5d. Runtime scheduling contract
- kanoniczny wybor `primary active step` MUST byc opisany w `runtime/scheduling-contract.md` i referencjonowany z `runtime/playbook-exec.yaml`.
- create wymagany przez trigger rule MUST byc zmaterializowany w tym samym atomowym commicie stanu, ale nie moze auto-progressowac bez jawnego kroku exec spec albo wyboru schedulera.
- dla jednego scope operatora moze istniec dokladnie jeden `primary active step`.
- rownolegle state-changing transitions na tym samym `scope_lock` = playbook invalid.

6. Architecture alignment contract
- kazda kluczowa zmiana Feature z zachowaniem biznesowym ma powiazany UseCase (co najmniej drafted, docelowo approved przed Feature.implemented).
- kazda granica rdzen <-> swiat zewnetrzny ma PortContract.
- kazdy PortContract wymaga DTO bez framework-specific typow.

7. FSM completeness contract
- kazdy OP ma jawna liste states oraz jawna liste transitions `from_state + event -> to_state`.
- transition nieopisany w `layers/op/state-machines.md` jest nielegalny.
- brak formalnego przejscia dla legalnego eventu = playbook invalid.
- transition uznajemy za pokryty, gdy ma:
  - binding jawny w `tooling/bindings.md`, albo
  - deterministyczne pokrycie przez `FSM coverage templates (G1/G2/G3)`.
- brak mozliwosci deterministycznej ekspansji bindingu = playbook invalid.

## 2. Contracts of Consistency

1. Naming contract
- identyfikatory OP, action i capability sa jednolite i case-stable.

2. Profile override contract
- profile moga nadpisac tool_plan, ale nie moga zmieniac intent action ani semantyki triggerow.

3. Storage neutrality contract
- te same action/binding dzialaja dla file-ai i sqlbase przez storage-adapter.

3a. OP applicability contract
- OP oznaczony jako warunkowy (`interactive-ui`, `version-controlled`, `formal-validation`, `persistent-data`, `deployable-runtime`) nie moze byc wymagany bez aktywacji odpowiedniego capability/profile.
- jesli capability/profile jest aktywny, wymagane OP musza istniec operacyjnie, nie tylko opisowo.

4. UX projection contract
- UI pokazuje tylko akcje legalne dla current_state i guardow.
- akcja ukryta/przedwczesna = projection invalid.
- primary copy musi opisywac task operatora, a nie transition labels.
- audit/debug details nie moga byc primary UI.
- kazdy krytyczny entrypoint musi miec artefakt `.ai/ux/<entrypoint>.md`.
- brak empty/loading/success/error/blocked state contract = projection invalid.

5. CRUD integrity contract
- create/read/update/remove dla OP musi byc opisane i audytowalne zgodnie z `workflow/op-crud-contract.md`.
- hard delete OP po pojawieniu sie ProcessEventRecord = invalid.
- brak parent linkage lub dangling link = playbook invalid.

6. System record contract
- `GateDecisionRecord`, `ProcessEventRecord` i `QualityEvidenceRecord` nie sa OP, ale sa kanonicznymi recordami systemowymi.
- recordy systemowe sa append-only; korekta oznacza nowy record, nie nadpisanie starego.
- brak wymaganego recordu systemowego uniewaznia transition lub evidence package.

## 3. Contracts of Safety

1. No silent transitions
- zadna zmiana stanu OP nie zachodzi bez bindingu i audytu.

2. Fail-safe gate
- QualityEvidenceRecord.fail wymusza request_changes lub defer, nigdy auto-approve.

3. Recovery contract
- dla DeploymentRun.failed musi istniec binding rollback action + recovery control.

4. Permission contract
- mutowalne authz controls musza byc opisane w `layers/op/authz-contracts.md`.
- action moze byc wykonana tylko przy aktywnym `AccessGrant`.
- kazdy binding transition musi zawierac operacyjny authz precheck.
- brak authz precheck albo brak sciezki `ExceptionCase(authz)` = transition invalid.
- authz jest deny-by-default; brak jawnego allow = invalid.

5. Gate classifier contract
- ten sam transition zawsze daje ten sam wynik `gate_required=true|false` dla tych samych bindingow.
- rozbieznosc klasyfikacji miedzy UI/CLI/service = playbook invalid.

6. Dependency rule contract
- dependency relations musza byc reprezentowane w grafie relacji, a nie jako ukryte pola albo niesledzone TODO.
- zaleznosci kodowe i komponentowe sa skierowane do warstw bardziej wewnetrznych (business policies).
- naruszenie kierunku zaleznosci = playbook invalid.

6a. Graph relation contract
- mutowalne relacje grafu musza byc opisane w `layers/op/relation-contracts.md`.
- zmiana statusu `DependencyRelation` musi byc audytowana i propagowana downstream.
- relacja blokujaca bez reverse lookup albo bez projection blocker = playbook invalid.

6b. Scheduler contract
- mutowalne timery runtime musza byc opisane w `layers/op/scheduler-contracts.md`.
- `timeout.fired` bez odpowiadajacego `SchedulerTimer` = invalid.
- defer/retry bez zaplanowania albo anulowania/consumingu timera = invalid.

6c. Delivery control contract
- mutowalne delivery controls musza byc opisane w `layers/op/delivery-contracts.md`.
- `ReleaseBundle.approved` bez odpowiadajacego `DeploymentRun` = invalid.
- `deployment.started|completed|failed` bez odpowiadajacego `DeploymentRun` = invalid.
- `DeploymentRun.failed` bez eskalacji albo recovery path = invalid.

6d. Job control contract
- mutowalne job controls musza byc opisane w `layers/op/job-contracts.md`.
- `prompt.sent` albo `prompt.validation-requested` bez odpowiadajacego `PromptTask` = invalid.
- `PromptTask.cancelled` albo `PromptTask.closed` bez `ProcessEventRecord` = invalid.

6e. Recovery control contract
- mutowalne recovery controls musza byc opisane w `layers/op/recovery-contracts.md`.
- `DeploymentRun.failed` bez odpowiadajacego `RollbackAction` = invalid.
- `ExceptionCase.compensation_required=true` bez odpowiadajacego `CompensationAction` = invalid.
- `RollbackAction.failed` bez eskalacji albo nowej decyzji gate = invalid.
- `CompensationAction.failed` bez eskalacji albo nowej decyzji gate = invalid.

6f. Exception control contract
- mutowalne exception controls musza byc opisane w `layers/op/exception-contracts.md`.
- authz deny, quality fail albo timeout escalation bez odpowiadajacego `ExceptionCase` = invalid.
- `ExceptionCase.escalated` bez projection blocker albo bez sciezki reassessment = invalid.

7. No-cycle contract
- graf zaleznosci miedzy Component nie moze zawierac cykli (ADP).
- wykryty cykl = playbook invalid do czasu przejscia Component.refactor-required -> Component.compliant.

8. Composition root contract
- implementacje adapterow i wiring zaleznosci sa spinane w jednym jawnym punkcie kompozycji.
- brak jawnego composition root lub rozsiany wiring = playbook invalid.

9. Testability contract
- UseCase/Domain musza miec testy niezalezne od UI/DB/sieci.
- jesli test logiki biznesowej wymaga infrastruktury, oznacz jako architectural coupling i blokuj gate approve.

9a. Version-control contract
- projekt z aktywnym profilem git/VCS musi miec Repository jako stan projektu i ChangeSet jako sledzony pakiet zmian.
- commit bez traceability do ChangeSet albo ChangeSet bez powiazania z OP pracy = invalid.

9b. Verification planning contract
- projekt z `formal-validation` musi miec VerificationPolicy dla baseline oraz dla scope, ktory zmienia ryzyko, delivery albo zakres testow.
- brak mapowania lane -> Feature/ChangeSet/ReleaseBundle = playbook invalid.

9c. Data evolution contract
- projekt z `persistent-data` musi utrzymywac DataSchema, a zmiana niekompatybilna lub operacyjnie istotna musi miec Migration.
- zmiana danych bez rollback/compatibility policy = playbook invalid.

9d. Environment readiness contract
- projekt z `deployable-runtime` musi miec `EnvironmentTarget` dla lokalnej walidacji oraz dla kazdego srodowiska delivery.
- ReleaseBundle.approved i DeploymentRun.planned bez `EnvironmentTarget` w stanie co najmniej `ready` = invalid.

9e. Environment control contract
- mutowalne environment controls musza byc opisane w `layers/op/environment-contracts.md`.
- delivery albo schema apply bez odpowiadajacego `EnvironmentTarget` = invalid.
- `EnvironmentTarget.degraded` bez projection blocker i recovery path = invalid.

10. Non-happy path contract
- dla kazdego OP musi istniec co najmniej jedna sciezka alternatywna do happy path:
  - gate outcome `request_changes|defer|reject`, albo
  - retry/rework cycle, albo
  - escalation/reject terminal path.
- brak sciezki non-happy path = playbook invalid.

11. Semantic guard contract
- guardy i invarianty z OP musza byc walidowane operacyjnie przed `write_state`, nie tylko opisane.
- brak `policy-engine` lub rownowaznego prechecku = playbook invalid.

12. Evidence provenance contract
- kazdy dowod walidacyjny ma jawna klase: simulation, fixture, runtime-capture albo binary-quality-lane.
- synthetic evidence nie moze samo dawac globalnego PASS.
- brak provenance metadata = playbook invalid dla evidence package.

## 4. AI Orchestration Contract

1. Control-plane contract
- DS jest jedynym orchestratem cyklu zycia ai-runner (submit/poll/retry/cancel/reset_context).

2. Scheduler contract
- decyzje czasowe (zapytaj za 5 min, timeout, backoff) sa wykonywane przez DS scheduler, nie przez domyslna petle agenta.
- DS scheduler deterministycznie wybiera tez `primary active step` i egzekwuje `scope_lock` dla konfliktowych transition.

3. Session contract
- reset kontekstu oznacza nowa sesje ai-runner i nowy context_revision.

4. MCP contract
- MCP moze byc adapterem transportowym, ale nie zastapi kontraktu control-plane.

## 5. Validation Procedure

Minimalna procedura walidacji przy zmianie playbooka:
0. Sprawdz execution spec contract (`runtime/playbook-exec.yaml`).
0a. Sprawdz FSM transition coverage przez execution templates (gate/non-gate/retry-escalation).
1. Sprawdz coverage transition -> binding.
2. Sprawdz action -> capability -> tool.
3. Sprawdz gate-required transitions.
4. Sprawdz Decision Envelope dla gate-required transitions.
5. Sprawdz audit requirements.
6. Sprawdz konflikt z layers/op/*.
7. Sprawdz UX projection na reprezentatywnych stanach.
8. Sprawdz AI orchestration contract (control-plane + scheduler + session).
9. Sprawdz architecture alignment (UseCase, PortContract, Component).
10. Sprawdz dependency direction + no-cycle + composition root.
11. Sprawdz testability contract dla UseCase/Domain.
12. Sprawdz version-control contract i traceability ChangeSet.
13. Sprawdz verification planning contract.
14. Sprawdz data evolution contract.
15. Sprawdz environment readiness contract.
16. Sprawdz FSM completeness contract.
17. Sprawdz non-happy path contract.
18. Sprawdz baseline completeness i workflow<->exec alignment.
19. Sprawdz runtime lifecycle coverage contract.
20. Sprawdz CRUD integrity contract.
21. Sprawdz semantic guard contract.
22. Sprawdz evidence provenance contract.

## 6. Evidence Package

Kazdy pass walidacji generuje pakiet dowodowy:
- data i wersja playbooka,
- lista sprawdzonych kontraktow,
- lista naruszen,
- klasy evidence i provenance metadata,
- decyzja: pass/fail,
- podpis operatora (GateDecisionRecord dla zmiany playbooka).
