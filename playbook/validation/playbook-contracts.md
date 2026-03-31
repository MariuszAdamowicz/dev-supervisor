# Playbook Contracts

Cel:
formalnie walidowac kompletnosc i spojnosc Playbook Layer wzgledem OP Layer.

## 1. Contracts of Completeness

1. Coverage contract
- kazdy krytyczny legal transition z OP ma binding w `tooling/bindings.md`.
- brak bindingu = playbook invalid.

2. Capability contract
- kazda capability wymagana przez action istnieje w co najmniej jednym narzedziu z `tooling/tool-registry.md`.
- capability orphan = playbook invalid.

3. Gate contract
- transition oznaczony gate-required musi zawierac `decide_gate` i `operator-ui`.
- brak jawnej decyzji gate = transition invalid.

4. Audit contract
- kazda akcja krytyczna generuje ProcessEvent.
- brak audytu = transition invalid.

5. Source-of-truth contract
- Playbook Layer nie redefiniuje state machine ani trigger semantics.
- konflikt z `layers/op/*` = playbook invalid.

## 2. Contracts of Consistency

1. Naming contract
- identyfikatory OP, action i capability sa jednolite i case-stable.

2. Profile override contract
- profile moga nadpisac `tool_plan`, ale nie moga zmieniac `intent` action ani semantyki triggerow.

3. Storage neutrality contract
- te same action/binding dzialaja dla `file-ai` i `sqlbase` przez `storage-adapter`.

4. UX projection contract
- UI pokazuje tylko akcje legalne dla current_state i guardow.
- akcja ukryta/przedwczesna = projection invalid.

## 3. Contracts of Safety

1. No silent transitions
- zadna zmiana stanu OP nie zachodzi bez bindingu i audytu.

2. Fail-safe gate
- `QualitySignal.fail` wymusza `request_changes` lub `defer`, nigdy auto-approve.

3. Recovery contract
- dla `Deployment.failed` musi istniec binding rollback + compensation.

4. Permission contract
- action moze byc wykonana tylko przy aktywnym ActorRolePermission.

## 4. Validation Procedure

Minimalna procedura walidacji przy zmianie playbooka:
1. Sprawdz coverage transition -> binding.
2. Sprawdz action -> capability -> tool.
3. Sprawdz gate-required transitions.
4. Sprawdz audit requirements.
5. Sprawdz konflikt z `layers/op/*`.
6. Sprawdz UX projection na reprezentatywnych stanach.

## 5. Evidence Package

Kazdy pass walidacji generuje pakiet dowodowy:
- data i wersja playbooka,
- lista sprawdzonych kontraktow,
- lista naruszen,
- decyzja: pass/fail,
- podpis operatora (GateDecision dla zmiany playbooka).
