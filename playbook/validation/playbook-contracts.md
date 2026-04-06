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
- kazda akcja krytyczna generuje ProcessEvent.
- brak audytu = transition invalid.

5. Source-of-truth contract
- Playbook Layer nie redefiniuje state machine ani trigger semantics.
- konflikt z layers/op/* = playbook invalid.

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

4. UX projection contract
- UI pokazuje tylko akcje legalne dla current_state i guardow.
- akcja ukryta/przedwczesna = projection invalid.

## 3. Contracts of Safety

1. No silent transitions
- zadna zmiana stanu OP nie zachodzi bez bindingu i audytu.

2. Fail-safe gate
- QualitySignal.fail wymusza request_changes lub defer, nigdy auto-approve.

3. Recovery contract
- dla Deployment.failed musi istniec binding rollback + compensation.

4. Permission contract
- action moze byc wykonana tylko przy aktywnym ActorRolePermission.
- kazdy binding transition musi zawierac operacyjny authz precheck.
- brak authz precheck albo brak sciezki `Exception(authz)` = transition invalid.

5. Gate classifier contract
- ten sam transition zawsze daje ten sam wynik `gate_required=true|false` dla tych samych bindingow.
- rozbieznosc klasyfikacji miedzy UI/CLI/service = playbook invalid.

6. Dependency rule contract
- zaleznosci kodowe i komponentowe sa skierowane do warstw bardziej wewnetrznych (business policies).
- naruszenie kierunku zaleznosci = playbook invalid.

7. No-cycle contract
- graf zaleznosci miedzy Component nie moze zawierac cykli (ADP).
- wykryty cykl = playbook invalid do czasu przejscia Component.refactor-required -> Component.compliant.

8. Composition root contract
- implementacje adapterow i wiring zaleznosci sa spinane w jednym jawnym punkcie kompozycji.
- brak jawnego composition root lub rozsiany wiring = playbook invalid.

9. Testability contract
- UseCase/Domain musza miec testy niezalezne od UI/DB/sieci.
- jesli test logiki biznesowej wymaga infrastruktury, oznacz jako architectural coupling i blokuj gate approve.

10. Non-happy path contract
- dla kazdego OP musi istniec co najmniej jedna sciezka alternatywna do happy path:
  - gate outcome `request_changes|defer|reject`, albo
  - retry/rework cycle, albo
  - escalation/reject terminal path.
- brak sciezki non-happy path = playbook invalid.

## 4. AI Orchestration Contract

1. Control-plane contract
- DS jest jedynym orchestratem cyklu zycia ai-runner (submit/poll/retry/cancel/reset_context).

2. Scheduler contract
- decyzje czasowe (zapytaj za 5 min, timeout, backoff) sa wykonywane przez DS scheduler, nie przez domyslna petle agenta.

3. Session contract
- reset kontekstu oznacza nowa sesje ai-runner i nowy context_revision.

4. MCP contract
- MCP moze byc adapterem transportowym, ale nie zastapi kontraktu control-plane.

## 5. Validation Procedure

Minimalna procedura walidacji przy zmianie playbooka:
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
12. Sprawdz FSM completeness contract.
13. Sprawdz non-happy path contract.

## 6. Evidence Package

Kazdy pass walidacji generuje pakiet dowodowy:
- data i wersja playbooka,
- lista sprawdzonych kontraktow,
- lista naruszen,
- decyzja: pass/fail,
- podpis operatora (GateDecision dla zmiany playbooka).
