## 🔁 Lifecycle feature

## 🧠 Granice feature

Nowy feature:
- nowe zachowanie biznesowe
- nowa odpowiedzialność

Rozszerzenie feature:
- wariant istniejącego zachowania
- brak nowego kontekstu

Zasada:
Feature = jedna odpowiedzialność

```text
idea → feature(s) → feature PRD → UX contract → BDD → testy → implementacja → walidacja → stabilizacja
```

### 🔍 Interpretacja etapów

- idea → wpis w `ideas.md` (brak zobowiązania)
- feature(s) → scoping idei na jeden lub więcej feature
- feature PRD → kontrakt (co ma powstać dla konkretnego feature)
- UX contract → kontrakt interakcji (co, kiedy i komu pokazać)
- BDD → zachowanie (jak ma działać)
- testy → egzekucja zachowania
- implementacja → dopasowanie kodu do testów
- walidacja → build + test + lint
- stabilizacja → cleanup + synchronizacja dokumentacji

### 1. Idea
Wpisz pomysł do `.ai/ideas.md`.

### 2. Idea -> Feature(s) (scoping)
Podejmij decyzję operatorską:
- czy idea to jeden feature czy kilka
- co jest in-scope dla pierwszego feature
- co trafia do odroczenia

Bez tej decyzji nie twórz PRD.

### 2a. Orchestration seed
Przed utworzeniem specyfikacji wykonaj mapowanie OP i triggerow:
- wskaz OP, ktore beda modyfikowane
- zdefiniuj eventy wejsciowe
- przygotuj liste PromptTask uruchamianych przez trigger rules

Szczegoly: `layers/op/object-catalog.md`, `layers/op/state-machines.md`, `layers/op/trigger-rules.md`.

### 3. Spec
Utwórz folder:
```text
.ai/features/<feature>/
```

Minimalnie dodaj:
- `prd.md`
- `bdd.md`
- `tasks.md`
- `notes.md`
- `traceability.md`

### 4. UX Contract
Zdefiniuj kontrakt UX przed BDD:
- stany procesu
- widoczność komponentów
- dostępność akcji (gates)
- reguły invalidation downstream

Szczegóły: `experience/ui-state-machine.md`, `experience/visibility-rules.md`.

### 5. BDD
Opisz scenariusze zachowania w `bdd.md`.

### 6. Testy
Na podstawie `bdd.md` wygeneruj lub popraw testy.

### 6a. Traceability
Powiąż reguły z `prd.md` ze scenariuszami z `bdd.md`.
Nie chodzi o ciężki system śledzenia, tylko o prostą mapę reguła → scenariusz.

### 7. Implementacja
Implementuj kod dopiero po przygotowaniu scenariuszy i testów. Dla feature tworzących model domenowy preferuj test-by-test / scenario-by-scenario implementation

### 7a. Gate operatorski po każdej iteracji
Po każdej iteracji operator musi podjąć decyzję:
- approve
- request changes
- defer
- reject

Decyzja ma być oparta o:
- diff kodu i dokumentacji
- mapowanie zmiana -> scenariusz BDD
- wynik walidacji

Transport promptów i wyników może być zautomatyzowany przez MCP, ale decyzja gate pozostaje po stronie operatora.

### 8. Stabilizacja
Po implementacji:
- porównaj kod z `prd.md`
- porównaj testy z `bdd.md`
- usuń nieużywany kod
- uzupełnij `notes.md`
- zaktualizuj `traceability.md`

### 9. Integration Hardening
Po domknięciu feature wykonaj kontrolę integracyjną:
- duplikacja modeli i helperów między feature
- spójność PRD <-> BDD <-> testy
- ewentualny drift dokumentacji globalnej (`overview.md`, `constraints.md`, `glossary.md`)
- gotowość punktów wejścia UI dla nowego capability (lub jawne odroczenie)

---

## 🔁 Lifecycle projektu

```text
setup → feature loop → stabilizacja → rozwój
```

Szczegóły fazy setup: `workflow/setup.md`.
Szczegóły pętli dziennej: `workflow/daily-workflow.md`.
Szczegóły stabilizacji i domknięcia: `workflow/session-closure.md`.
