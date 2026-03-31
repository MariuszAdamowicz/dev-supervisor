## Codzienny workflow (OP-aligned)

Zasada nadrzedna:
To jest procedura operatora mapowana na OP Layer.
Kanoniczne stany, triggery i gate values sa w layers/op.

### 0. Wybierz aktywny krok
Wykonuj tylko jeden nastepny krok pipeline.
Szczegoly UI: experience/ui-state-machine.md.

### 1. Wybierz idee i zrob scoping
Zdecyduj:
- jeden feature czy wiele
- ktory feature jest aktywny teraz

### 1a. Zmapuj OP i triggery
Dla zmiany okresl:
- target OP
- eventy
- wymagane PromptTask
- guardy do kolejnego przejscia

Szczegoly:
- layers/op/object-catalog.md
- layers/op/trigger-rules.md

### 2. Zaladuj minimalny kontekst
- feature/prd.md
- feature/bdd.md
- overview.md
- constraints.md
- glossary.md
- odpowiednie pliki stack

### 3. Plan
Wygeneruj maly plan krokow.

### 4. Test-first
Wygeneruj lub popraw testy na bazie bdd.

### 5. Implementacja
Wykonaj jeden krok planu bez zmian niepowiazanych.

### 6. Review package
Pokaz operatorowi:
- diff
- mapowanie zmiana -> scenariusz
- build/test/lint
- status OP (eventy i guardy)

### 7. Walidacja
Uruchom:
- Scripts/build.sh
- Scripts/test.sh
- Scripts/lint.sh

### 8. Gate decyzji operatora
Operator podejmuje decyzje gate.
Wartosci decyzji i efekty sa kanoniczne w OP Layer.

### 9. Poprawki
Jesli gate nie jest approve, wykonaj minimalne poprawki i powtorz loop.

### 10. Stabilizacja
Porownaj implementacje z prd i bdd.
Usun dead code.
Zaktualizuj notes i traceability.

### 11. Integration hardening
Sprawdz:
- duplikacje miedzy feature
- dryf PRD-BDD-testy
- readiness UI lub jawne odroczenie
- dependency/risk status

### 12. Release handoff
Jesli feature jest stabilny, przygotuj przekazanie do Release OP.
