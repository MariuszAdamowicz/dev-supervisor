## 🔄 Zmiana feature (rewrite protocol)

### ⚠️ Najważniejsza zasada

Zmiana feature bez zmiany testów = błąd procesu.

Jeśli zmieniasz feature:
- stare testy MUSZĄ przestać przechodzić
- nowe testy MUSZĄ definiować nowe zachowanie

Zmiana feature nie powinna zaczynać się od zmiany kodu.

Prawidłowy flow:

```text
update spec → update BDD → update tests → migrate code → cleanup → stabilize
```

### krok 1 — zaktualizuj `prd.md`
Najpierw opisz nowe zachowanie.

### krok 2 — zaktualizuj `bdd.md`
Scenariusze muszą odzwierciedlać nową specyfikację.

### krok 3 — zaktualizuj testy
Najpierw popraw lub wygeneruj od nowa testy.
Testy są executable spec.
Stara implementacja ma teraz nie przechodzić.

### krok 3a — zaktualizuj traceability
Upewnij się, że każda nowa lub zmieniona reguła z `prd.md` ma odpowiadający scenariusz w `bdd.md`.
Usuń referencje do starych scenariuszy, które już nie obowiązują.

### krok 4 — porównaj stan aktualny z nową specyfikacją
Prompt:
```text
Compare current implementation, BDD scenarios and tests with the new feature spec.
List mismatches.
```

### krok 5 — przygotuj plan migracji
Prompt:
```text
Create a migration plan to replace the old implementation with the new one.
Include cleanup of obsolete logic and tests.
```

### krok 6 — wdrożenie
Prompt:
```text
Apply the migration plan.
Remove obsolete code.
Remove or rewrite obsolete tests.
Do not leave compatibility shims unless explicitly requested.
```

### krok 7 — stabilizacja
- build
- test
- lint
- cleanup
- update traceability
