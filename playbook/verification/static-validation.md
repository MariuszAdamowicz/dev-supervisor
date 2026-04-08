# Static Validation

Cel:
potwierdzic, ze dokumenty playbooka sa formalnie spojne (bez uruchamiania projektu).

## Wejscie
- layers/op/object-catalog.md
- layers/op/authz-contracts.md
- layers/op/data-contracts.md
- layers/op/decision-contracts.md
- layers/op/delivery-contracts.md
- layers/op/environment-contracts.md
- layers/op/exception-contracts.md
- layers/op/glossary-contracts.md
- layers/op/job-contracts.md
- layers/op/relation-contracts.md
- layers/op/risk-contracts.md
- layers/op/recovery-contracts.md
- layers/op/scheduler-contracts.md
- layers/op/verification-contracts.md
- runtime/scheduling-contract.md
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
5. Sprawdz no-silent-transitions (ProcessEventRecord).
6. Sprawdz FSM completeness oraz non-happy path contract.
7. Sprawdz architecture alignment (UseCase/PortContract/Component).
8. Sprawdz dependency/no-cycle/composition root contracts.
9. Sprawdz workflow<->exec alignment i baseline completeness.
10. Sprawdz presence `policy-engine` i authz precheck coverage.
11. Sprawdz CRUD integrity contract.
12. Sprawdz evidence provenance labeling.
13. Sprawdz runtime scheduling contract i jednoznacznosc `primary active step`.

## Wynik
- PASS: brak naruszen krytycznych kontraktow.
- FAIL: co najmniej jedno naruszenie z impactem na determinism/audit/safety.

## Minimalne metryki
- transition coverage: 100%
- gate-required coverage: 100%
- no-silent-transitions: 100%
- OP z non-happy path: 100%
- workflow_exec_alignment: 100%
- provenance_labeling: 100%
