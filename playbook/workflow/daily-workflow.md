## 🔁 Codzienny workflow

### 0. wybór aktywnego kroku (state-driven)
Sprawdź aktualny stan procesu i wykonuj tylko jeden następny krok.
Nie pracuj równolegle na kilku krokach pipeline.

Szczegóły: `experience/ui-state-machine.md`.

### 1. wybór idei i scoping
Wybierz ideę i podejmij decyzję:
- czy to jeden feature czy kilka
- który feature realizujesz teraz

Dopiero po tej decyzji tworzysz aktywny feature.

### 2. minimalny kontekst
Ładuj tylko:
- `.ai/features/<feature>/prd.md`
- `.ai/features/<feature>/bdd.md`
- `.ai/prd/overview.md`
- `.ai/prd/constraints.md`
- `.ai/prd/glossary.md`
- odpowiednie pliki z `.ai/stack/`

### 🔍 Reguła kontekstu

Im mniejszy kontekst → tym lepsza jakość AI.

Nigdy nie:
- ładuj całego repo
- ładuj wszystkich feature

Zawsze:
- jeden feature
- minimalny stack

### 3. plan
Prompt:
```text
Read the feature spec, BDD scenarios and relevant stack files.
Propose a small step-by-step implementation plan.
```

### 4. test-first
Prompt:
```text
Generate or update unit tests based on bdd.md.
```

### 5. implementacja
Prompt:
```text
Implement step 1 from the plan.
Do not modify unrelated files.
```

### 6. review package (obowiązkowe przed decyzją)
Aplikacja musi pokazać operatorowi:
- diff zmian plików
- mapowanie zmiana -> scenariusz BDD
- wynik build/test/lint

Bez review package nie przechodź dalej.

### 7. loop walidacyjny
Uruchom:
```text
./Scripts/build.sh
./Scripts/test.sh
./Scripts/lint.sh
```

### 8. gate decyzji operatora
Po każdej iteracji operator wybiera:
- approve
- request changes
- defer
- reject

Transport promptów i wyników może być zautomatyzowany przez MCP, ale decyzja gate należy do operatora.

### 9. poprawki
Prompt:
```text
Here are the build/test/lint results.
Fix the issues with minimal changes.
```

### 10. stabilizacja
Prompt:
```text
Compare the implementation with prd.md and bdd.md.
Remove dead code.
Update notes.md and traceability.md if needed.
```

### 11. integration hardening
Przed finalnym merge:
- sprawdź duplikacje między feature
- sprawdź dryf PRD <-> BDD <-> testy
- sprawdź czy nowe capability ma punkt wejścia UI lub jawne odroczenie

### 12. UX/Gate consistency check
Sprawdź, czy zmiana nie narusza:
- reguł widoczności
- reguł dostępności akcji
- reguł invalidation downstream

Szczegóły: `experience/visibility-rules.md`, `experience/ux-validation.md`.
