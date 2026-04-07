# Runtime Lifecycle Coverage Correctas

## Stan obecny przed zmianami

Kanoniczny exec spec konczyl sie praktycznie na `new_project` i `add_idea`.
`workflow/daily-workflow.md` opisywal znacznie szerszy lifecycle:
- Feature,
- UseCase/PortContract,
- Component/Dependency,
- Release,
- Exception/Timeout.

To powodowalo, ze kontrakt wykonawczy nie domykal wiekszosci realnego runtime.

## CRUD dla punktu

Create:
- mozna bylo stworzyc `Project` i `Idea`, ale brakowalo kanonicznych runtime bundle dla Feature delivery, UX alignment, release i recovery.

Read:
- operator nie mial gwarantowanego katalogu entrypointow wykonawczych.

Update:
- dalszy lifecycle byl oparty bardziej na dokumentach opisowych niz na exec coverage.

Remove:
- brak, bo problem dotyczyl nie usuwania, tylko brakujacego coverage.

## Praktyki zewnetrzne

- Temporal: workflow powinien jawnie modelowac retry, timeout, recovery i determinism.
- C4 dynamic diagrams: zlozone, runtimeowe interakcje powinny miec jawny model wspolpracy elementow.

Linki:
- https://docs.temporal.io/workflow-definition
- https://docs.temporal.io/encyclopedia/retry-policies
- https://c4model.com/diagrams/dynamic

## Plan zmian

1. Dodac runtime catalog entrypointow poza `new_project` i `add_idea`.
2. Zdefiniowac templates dla baseline, feature refinement, UX alignment, scenario prep, implementation, release i exception recovery.
3. Dodac validation contract dla lifecycle coverage.

## Czy plan domyka problem

Tak dla warstwy specyfikacji. Nadal potrzeba kolejnych iteracji implementacyjnych w silniku/aplikacji, ale playbook ma juz kanoniczna liste i shape runtime coverage.

## Wprowadzone zmiany

- `playbook/runtime/playbook-exec.yaml` ma `entrypoint_catalog` oraz nowe templates wykonawcze,
- `playbook/validation/playbook-contracts.md` ma `Runtime lifecycle coverage contract`,
- `playbook/workflow/daily-workflow.md` rozszerza jawny zakres entrypointow.

## Podsumowanie

Najwieksza luka wykonawcza zostala zamknieta: lifecycle po `add_idea` przestal byc "poza exec spec". Teraz jest co najmniej jawnie skatalogowany i objety template coverage.
