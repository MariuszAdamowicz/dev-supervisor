## 🔗 Referencje między PRD a testami

Tak — warto mieć lekką warstwę traceability.

Nie buduj ciężkiego systemu.
Wystarczy `traceability.md` w folderze feature.

### Minimalna zasada
Każda ważna reguła z `prd.md` powinna mieć odniesienie do scenariusza w `bdd.md`.

**Przykład:**
```markdown
# Traceability

- Rule: fallback on provider error
  - Scenario: fallback to next provider

- Rule: skip disabled provider
  - Scenario: disabled provider is ignored
```

To wystarczy, żeby:
- AI widziało związek między wymaganiem i testem
- łatwo było poprawiać testy przy zmianie feature
- nie zostawiać starych scenariuszy po refactorze

---

## Rule → Scenario Mapping

`traceability.md` wiąże reguły z `prd.md` ze scenariuszami z `bdd.md`.
Nie chodzi o ciężki system śledzenia, tylko o prostą mapę reguła → scenariusz.

Dodatkowy przykład mapowania:
```markdown
# Traceability

- Rule: fallback on provider error
  - Covered by: Scenario "fallback to next provider"

- Rule: skip disabled provider
  - Covered by: Scenario "disabled provider is ignored"
```
