# Ograniczenia

## Platforma

- tylko macOS (faza początkowa)
- aplikacja desktopowa (interfejs okienkowy)
- brak web UI
- brak Electron
- brak interfejsu głównego opartego o przeglądarkę

---

## Język i Framework

- Swift jako główny język
- SwiftUI dla warstwy UI
- preferowane natywne frameworki Apple

---

## Architektura

- w fazie początkowej preferowany prosty modularny monolit
- jasna separacja między:
  - UI (App/)
  - logiką domenową (Core/)
  - integracjami (Services/)
- unikać over-engineeringu (brak mikroserwisów, brak systemów rozproszonych)

---

## Niezależność od narzędzi

- System nie może zależeć od żadnego konkretnego:
  - dostawcy AI
  - narzędzia CLI
  - języka programowania używanego w nadzorowanych projektach

- Aplikacja nadzoruje proces, a nie silnik wykonawczy

---

## Model interakcji z AI

- Aplikacja NIE może automatycznie wykonywać promptów
- Prompty są generowane i prezentowane operatorowi
- Operator odpowiada za wykonanie

---

## Przechowywanie danych

- Lokalna baza danych jest wymagana
- Brak zależności od chmury w fazie początkowej
- Baza przechowuje:
  - metadane projektu
  - stan funkcji
  - śledzenie postępu
  - odniesienia śledzalności

- Pliki projektu pozostają źródłem prawdy dla:
  - PRD
  - BDD
  - specyfikacji funkcji

---

## Zakres projektu

- Obsługa wielu projektów
- Każdy projekt jest odizolowany pod względem:
  - idei
  - funkcji
  - postępu
  - metadanych

---

## Walidacja

- Każda funkcja musi być weryfikowalna przez:
  - build
  - testy
  - lint

- System musi śledzić stan walidacji, ale nie wykonuje jej automatycznie

---

## System Promptów

- Szablony promptów mogą być przechowywane poza plikami projektu
- Prompty muszą być:
  - deterministyczne
  - ustrukturyzowane
  - minimalne kontekstowo

---

## Reguły jakości

- Brak cichych błędów
- Brak ukrytych zmian stanu
- Brak niejawnych zachowań bez śledzalności

- Preferuj jawne modele zamiast struktur dynamicznych
- Preferuj klarowność zamiast sprytu

---

## Ograniczenia ewolucji

- Nowe możliwości nie mogą psuć:
  - istniejących workflowów funkcji
  - modelu śledzalności
  - zasady minimalnego kontekstu

- Zmiany workflow muszą być odzwierciedlone w:
  - PRD
  - BDD
  - testach
