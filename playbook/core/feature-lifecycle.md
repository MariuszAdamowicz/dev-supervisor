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
idea → PRD → BDD → testy → implementacja → walidacja → stabilizacja
```

### 🔍 Interpretacja etapów

- idea → wpis w `ideas.md` (brak zobowiązania)
- PRD → kontrakt (co ma powstać)
- BDD → zachowanie (jak ma działać)
- testy → egzekucja zachowania
- implementacja → dopasowanie kodu do testów
- walidacja → build + test + lint
- stabilizacja → cleanup + synchronizacja dokumentacji

### 1. Idea
Wpisz pomysł do `.ai/ideas.md`.

### 2. Spec
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

### 3. BDD
Opisz scenariusze zachowania w `bdd.md`.

### 4. Testy
Na podstawie `bdd.md` wygeneruj lub popraw testy.

### 4a. Traceability
Powiąż reguły z `prd.md` ze scenariuszami z `bdd.md`.
Nie chodzi o ciężki system śledzenia, tylko o prostą mapę reguła → scenariusz.

### 5. Implementacja
Implementuj kod dopiero po przygotowaniu scenariuszy i testów. Dla feature tworzących model domenowy preferuj test-by-test / scenario-by-scenario implementation

### 6. Stabilizacja
Po implementacji:
- porównaj kod z `prd.md`
- porównaj testy z `bdd.md`
- usuń nieużywany kod
- uzupełnij `notes.md`
- zaktualizuj `traceability.md`

---

## 🔁 Lifecycle projektu

```text
setup → feature loop → stabilizacja → rozwój
```

Szczegóły fazy setup: `workflow/setup.md`.
Szczegóły pętli dziennej: `workflow/daily-workflow.md`.
Szczegóły stabilizacji i domknięcia: `workflow/session-closure.md`.
