# UI State Machine

## Cel
Widoczność i dostępność akcji są sterowane maszyną stanów, nie ręcznie przez widoki.

## Stany główne
- `project_uninitialized`
- `project_ready`
- `idea_backlog`
- `idea_selected`
- `features_ready`
- `prd_ready`
- `ux_contract_ready`
- `bdd_ready`
- `tests_ready`
- `implementation_ready`
- `validation_ready`
- `stabilized`

## Przejścia
- `project_uninitialized -> project_ready`: zakończony setup + baseline product docs
- `project_ready -> idea_backlog`: istnieje co najmniej jedna idea
- `idea_backlog -> idea_selected`: jedna idea oznaczona jako aktywna
- `idea_selected -> features_ready`: zaakceptowany artefakt Features
- `features_ready -> prd_ready`: zaakceptowany artefakt PRD
- `prd_ready -> ux_contract_ready`: zaakceptowany UX Contract
- `ux_contract_ready -> bdd_ready`: zaakceptowany artefakt BDD
- `bdd_ready -> tests_ready`: zaakceptowany artefakt Tests
- `tests_ready -> implementation_ready`: zaakceptowany artefakt Implementation
- `implementation_ready -> validation_ready`: zielony build/test/lint
- `validation_ready -> stabilized`: cleanup + sync dokumentacji

## Reguła invalidation
Zmiana artefaktu w stanie `X` resetuje wszystkie bramki downstream.
Przykład: zmiana PRD resetuje `UX/BDD/Tests/Implementation/Validation`.
