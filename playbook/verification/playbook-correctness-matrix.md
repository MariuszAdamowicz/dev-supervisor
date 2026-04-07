# Playbook Correctness Matrix

Cel:
jednoznacznie pokazac, czy playbook jest poprawny operacyjnie dla wszystkich OP.

## Definicja "poprawny playbook"

Dla kazdego OP musza byc spelnione 4 warstwy:
1. `static`: definicja OP + FSM + binding coverage.
2. `replay`: deterministyczny wynik (run1 == run2).
3. `e2e`: runtime evidence (ProcessEvent + GateDecision + legal final state).
4. `chaos`: legalna reakcja na zaklocenia i komplet audytu.

## Zakres runu full-op (2026-04-07)

- static audit: `playbook/verification/scripts/op-coverage-audit.sh`
- replay scenarios:
  - `playbook/verification/replay/scenario-e2e-full-op.csv`
  - `playbook/verification/replay/scenario-chaos-full-op.csv`
- replay evidence: `playbook/verification/replay/run-2026-04-07-full-op/`
- e2e runtime fixture: `playbook/verification/e2e-fixture/run-2026-04-07-full-op/`
- chaos runtime fixture: `playbook/verification/e2e-fixture/run-2026-04-07-chaos-full-op/`

## Matryca OP x 4 warstwy

| OP | static | replay | e2e | chaos | status |
| --- | --- | --- | --- | --- | --- |
| Project | pass | pass | pass | pass | verified |
| Requirement | pass | pass | pass | pass | verified |
| Constraint | pass | pass | pass | pass | verified |
| DecisionRecord | pass | pass | pass | pass | verified |
| Idea | pass | pass | pass | pass | verified |
| Feature | pass | pass | pass | pass | verified |
| Scenario | pass | pass | pass | pass | verified |
| Term | pass | pass | pass | pass | verified |
| UIComponent | pass | pass | pass | pass | verified |
| UIScreen | pass | pass | pass | pass | verified |
| PromptTask | pass | pass | pass | pass | verified |
| GateDecision | pass | pass | pass | pass | verified |
| ActorRolePermission | pass | pass | pass | pass | verified |
| Dependency | pass | pass | pass | pass | verified |
| UseCase | pass | pass | pass | pass | verified |
| PortContract | pass | pass | pass | pass | verified |
| Component | pass | pass | pass | pass | verified |
| Risk | pass | pass | pass | pass | verified |
| Release | pass | pass | pass | pass | verified |
| Deployment | pass | pass | pass | pass | verified |
| Rollback | pass | pass | pass | pass | verified |
| QualitySignal | pass | pass | pass | pass | verified |
| Exception | pass | pass | pass | pass | verified |
| Timeout | pass | pass | pass | pass | verified |
| Compensation | pass | pass | pass | pass | verified |
| ProcessEvent | pass | pass | pass | pass | verified |

## Podsumowanie

- `verified`: 26/26
- `partial`: 0/26
- `missing`: 0/26

Wniosek:
playbook w aktualnej wersji ma domknieta weryfikacje 4-warstwowa dla wszystkich OP.
