# Baseline Architecture Correctas

## Stan obecny przed zmianami

`workflow/setup.md` wymagalo bogatszego baseline niz `runtime/playbook-exec.yaml`.
Przed korekta exec spec wymuszal glownie:
- `overview.md`,
- `constraints.md`,
- `glossary.md`,
- `Project`.

Brakowalo twardego baseline dla:
- `Requirement`,
- `Constraint`,
- `DecisionRecord`,
- `UseCase`,
- `PortContract`,
- `Component`,
- `ActorRolePermission`,
- artefaktow architektury i UX.

## CRUD dla punktu

Create:
- baseline OP i artefakty architektoniczne nie byly tworzone obowiazkowo.

Read:
- operator nie mial gwarancji, ze po bootstrapie istnieje spis use case, portow i komponentow.

Update:
- zmiany baseline mogly powstawac poza spojnyn kontraktem workflow<->exec.

Remove:
- brak jednoznacznej polityki deprecacji/usuwania baseline OP.

## Praktyki zewnetrzne

- arc42: pragmatyczna dokumentacja architektury i quality requirements.
- C4 model: system context, containers, components i dynamiczne interakcje.

Linki:
- https://arc42.org/overview
- https://arc42.org/develop
- https://c4model.com/
- https://c4model.com/diagrams
- https://c4model.com/diagrams/dynamic

## Plan zmian

1. Ujednolicic baseline miedzy `workflow/setup.md` i `playbook-exec.yaml`.
2. Dodac wymagane artefakty `.ai/adr/*`, `.ai/architecture/*`, `.ai/ux/*`.
3. Wymusic creation bundle dla baseline OP.
4. Dodac walidacyjny baseline completeness contract.

## Czy plan domyka problem

Tak. Po wdrozeniu problem przestaje byc "interpretacja workflow", bo baseline jest juz wymuszony jednoczesnie w workflow, runtime i validation.

## Wprowadzone zmiany

- `playbook/workflow/setup.md` rozszerzony o artefakty architektury, UX i `ActorRolePermission`,
- `playbook/runtime/playbook-exec.yaml` ma `baseline_contract`, nowe pliki wymagane po `new_project` i `required_op_types_after_new_project`,
- `playbook/validation/playbook-contracts.md` ma `Baseline completeness contract`.

## Podsumowanie

Playbook nie pozwala juz uczciwie uznac "ubogiego baseline" za poprawny start projektu. Bazowy model produktu i architektury zostal przywrocony do wspolnego kontraktu.
