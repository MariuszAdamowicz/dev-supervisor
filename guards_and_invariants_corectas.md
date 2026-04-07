# Guards And Invariants Correctas

## Stan obecny przed zmianami

Guardy i invarianty byly dobrze opisane w OP Layer, ale slabo dowodzone semantycznie.
Istnialy glownie jako:
- opis w FSM,
- opis w trigger rules,
- niektore testy coverage po nazwach.

Brakowalo twardego mechanizmu: "sprawdz guardy/invarianty przed write_state".

## CRUD dla punktu

Create:
- nowe OP mogly powstawac bez gwarancji semantycznego sprawdzenia parent linkage.

Read:
- operator mogl widziec blokade, ale nie bylo gwarancji, ze jest to blokada faktycznie egzekwowana przez runtime.

Update:
- zmiany linkow i guardow nie wymuszaly rewalidacji invariantow.

Remove:
- deprecacje/drop/revoke nie wymuszaly twardo tombstone + integrity checks.

## Praktyki zewnetrzne

- PostgreSQL constraints: nielegalny zapis powinien byc zablokowany przez kontrakt, nie przez "dobra wole" klienta.
- Temporal: workflow determinism i retry/recovery musza byc jawne i sprawdzalne.

Linki:
- https://www.postgresql.org/docs/current/ddl-constraints.html
- https://docs.temporal.io/workflow-definition
- https://docs.temporal.io/encyclopedia/retry-policies

## Plan zmian

1. Dodac `validate_semantics` i `validate_invariants` jako czesc runtime.
2. Dodac validation contract dla semantic guard checks.
3. Wpisac rewalidacje invariantow do workflow i verification.

## Czy plan domyka problem

Tak na poziomie kontraktu playbooka. Nadal potrzeba przyszlej implementacji egzekutora, ale spec i validation nie pozwalaja juz traktowac guardow jako czysto opisowych.

## Wprowadzone zmiany

- `playbook/tooling/tool-registry.md` i `action-catalog.md` rozszerzone o `validate_semantics`,
- `playbook/tooling/bindings.md` ma globalny precheck guard/invariant/CRUD,
- `playbook/runtime/playbook-exec.yaml` wymaga `semantic_guard_precheck_required_before_state_write`,
- `playbook/validation/playbook-contracts.md` ma `Semantic guard contract`,
- `playbook/verification/semantic-validation.md` opisuje metody sprawdzania.

## Podsumowanie

Guardy i invarianty przestaly byc tylko elementem dokumentacji OP. Sa teraz jawna czescia kontraktu wykonawczego i walidacyjnego.
