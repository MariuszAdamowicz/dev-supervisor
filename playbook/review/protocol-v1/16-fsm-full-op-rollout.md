# FSM Full OP Rollout (Step 2)

Status: completed
Data: 2026-04-07

## Cel
Domknac krok po kroku pokrycie wszystkich OP po rozbudowie `state-machines.md` do pelnego grafu (happy + non-happy path).

## Zakres wykonany
1. `layers/op/state-machines.md`:
- utrzymany pelny, jawny graf przejsc dla wszystkich OP.

2. `layers/op/trigger-rules.md`:
- dodane reguly non-happy dla kluczowych OP runtime,
- dodany mechanizm `FSM expansion rules` domykajacy pozostale OP deterministycznie.

3. `tooling/bindings.md`:
- dodane jawne bindingi non-happy dla Feature/PromptTask/Release/Deployment/Rollback,
- dodane `FSM coverage templates (G1/G2/G3)` dla wszystkich OP.

4. `validation/playbook-contracts.md`:
- FSM completeness rozszerzone o deterministyczna ekspansje bindingow z szablonow,
- brak ekspansji => playbook invalid.

## Dlaczego to jest zgodne z idea playbooka
1. Nie wprowadzono zgadywania ani logiki ad-hoc.
2. Wszystkie sciezki sa albo jawne, albo wynikaja z deterministycznych szablonow.
3. Audit i gate pozostaly centralne (no-silent-transitions, decision envelope, process events).

## Co pozostaje
1. Kolejne kroki moga stopniowo zamieniac bindingi szablonowe na jawne wpisy per OP tam, gdzie potrzebna jest wysoka specyficznosc narzedziowa.
2. Priorytet kolejnych uszczegolowien: Requirement/Constraint/DecisionRecord, potem UI/Scenario, potem operacyjne OP (Exception/Timeout/Compensation).
