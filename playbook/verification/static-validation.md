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
1. Sprawdz coverage `transition -> binding`.
2. Sprawdz `action -> capability -> tool`.
3. Sprawdz gate-required + decision envelope.
4. Sprawdz no-silent-transitions (ProcessEvent).
5. Sprawdz FSM completeness oraz non-happy path contract.
6. Sprawdz architecture alignment (UseCase/PortContract/Component).
7. Sprawdz dependency/no-cycle/composition root contracts.

## Wynik
- PASS: brak naruszen krytycznych kontraktow.
- FAIL: co najmniej jedno naruszenie z impactem na determinism/audit/safety.

## Minimalne metryki
- transition coverage: 100%
- gate-required coverage: 100%
- no-silent-transitions: 100%
- OP z non-happy path: 100%
