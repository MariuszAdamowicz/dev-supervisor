# Static Validation

Cel:
potwierdzic, ze dokumenty playbooka sa formalnie spojne (bez uruchamiania projektu).

## Wejscie
- layers/op/object-catalog.md
- layers/op/state-machines.md
- layers/op/trigger-rules.md
- tooling/action-catalog.md
- tooling/tool-registry.md
- tooling/bindings.md
- validation/playbook-contracts.md

## Procedura
1. Sprawdz execution spec (`runtime/playbook-exec.yaml`) i regule one-tool-per-step.
2. Sprawdz coverage `transition -> binding`.
3. Sprawdz `action -> capability -> tool`.
4. Sprawdz gate-required + decision envelope.
5. Sprawdz no-silent-transitions (ProcessEvent).
6. Sprawdz FSM completeness oraz non-happy path contract.
7. Sprawdz architecture alignment (UseCase/PortContract/Component).
8. Sprawdz dependency/no-cycle/composition root contracts.

## Wynik
- PASS: brak naruszen krytycznych kontraktow.
- FAIL: co najmniej jedno naruszenie z impactem na determinism/audit/safety.

## Minimalne metryki
- transition coverage: 100%
- gate-required coverage: 100%
- no-silent-transitions: 100%
- OP z non-happy path: 100%
