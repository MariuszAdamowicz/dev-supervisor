## 🔁 Codzienny workflow

### 1. wybór feature
Wybierz jeden aktywny feature.

### 2. minimalny kontekst
Ładuj tylko:
- `.ai/features/<feature>/prd.md`
- `.ai/features/<feature>/bdd.md`
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

### 6. loop walidacyjny
Uruchom:
```text
./Scripts/build.sh
./Scripts/test.sh
./Scripts/lint.sh
```

### 7. poprawki
Prompt:
```text
Here are the build/test/lint results.
Fix the issues with minimal changes.
```

### 8. stabilizacja
Prompt:
```text
Compare the implementation with prd.md and bdd.md.
Remove dead code.
Update notes.md and traceability.md if needed.
```
