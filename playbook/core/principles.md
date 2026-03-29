## 🎯 Cel systemu

Zbudować workflow, w którym:
- AI implementuje kod
- dokumentacja steruje AI
- kontekst jest minimalny i precyzyjny
- kod pozostaje spójny i utrzymywany
- zmiany feature są prowadzone przez specyfikację i testy, a nie przez przypadkowe poprawki w kodzie

---

## Deterministic Product Guardrails

`dev-supervisor` to deterministyczny supervisor procesu, nie agent AI.

System ma pozostać:
- deterministic
- operator-driven
- local-first
- tool-agnostic
- provider-agnostic
- stack-agnostic in principle

Model operacyjny:
1. supervisor przygotowuje kontekst i prompt
2. operator przegląda/edytuje prompt
3. operator uruchamia prompt w zewnętrznym narzędziu
4. operator przenosi wyniki z powrotem do procesu

Granice:
- system nie wykonuje promptów automatycznie
- system nie zastępuje IDE
- system nie zastępuje inżynierskiego osądu
- system nie mutuje stanu projektu po cichu

---

## 🧩 Zasada modularności `.ai`

Każdy katalog ma jedną odpowiedzialność:

- `prd/` → czym jest system
- `features/` → jak działa konkretny feature
- `stack/` → jak budujemy system
- `prompts/` → jak komunikujemy się z AI

---

## 🔥 Zasada kontekstu

AI NIGDY nie powinno czytać całego `.ai/`.

Zawsze tylko:
- jeden feature (`.ai/features/<feature>/`)
- + minimalne pliki ze stack (`.ai/stack/`)

---

## 🎯 Efekt

- mniejszy kontekst → lepsze odpowiedzi
- brak „rozmycia” logiki
- większa przewidywalność AI

---

## 🚫 Zasady negatywne

Nie rób:
- jednego ogromnego PRD
- jednej rozmowy AI obejmującej cały projekt
- implementacji bez testów
- zmian feature zaczynanych od kodu
- trzymania dwóch różnych źródeł prawdy dla jednego feature
- dublowania helperów między feature'ami
- wrzucania kodu współdzielonego do losowych miejsc tylko dlatego, że "zadziałał"
- mergowania brancha bez build + test + lint

---

## ✅ Zasady finalne

1. Globalny PRD opisuje produkt, a nie każdy detal feature.
2. Każdy feature ma własny folder w `.ai/features/`.
3. `prd.md` opisuje wymagania feature.
4. `bdd.md` opisuje zachowanie feature.
5. Testy są wykonywalną specyfikacją.
6. Zmiana feature zaczyna się od specyfikacji i testów, nie od kodu.
7. AI dostaje tylko minimalny potrzebny kontekst.
8. Każda iteracja kończy się build + test + lint.
9. Po zmianach usuwasz martwy kod i nieaktualne testy.
10. `traceability.md` utrzymuje lekkie powiązanie między wymaganiami i scenariuszami.
11. Kod współdzielony jest zarządzany jawnie, a nie przypadkowo.
12. Duplikacja to sygnał do extraction, nie do copy-paste.
13. Git workflow jest częścią procesu, a nie dodatkiem po implementacji.
14. `main` ma być zawsze w stanie nadającym się do uruchomienia.
15. Setup musi obejmować realne sprawdzenie CLI build/test flow, nie tylko utworzenie projektu.
16. Dla projektów zależnych od stack profile konfiguracja narzędzi jest częścią procesu, a nie detalem narzędziowym (np. scheme/Test Plan/test targets dla Xcode).

---

## 🔥 Finalny model pracy

```text
idea → feature PRD → BDD → tests → code → validate → cleanup → merge → evolve
```

### Ostateczna interpretacja modelu

- idea → zapisujesz pomysł
- feature PRD → definiujesz kontrakt
- BDD → definiujesz zachowanie
- tests → egzekwujesz zachowanie
- code → dopasowujesz implementację
- validate → build + test + lint
- cleanup → usuwasz martwy kod i stabilizujesz dokumentację
- merge → integrujesz zmianę do `main`
- evolve → rozwijasz system dalej bez psucia fundamentów
