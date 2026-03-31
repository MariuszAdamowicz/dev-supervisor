# Operator Journey

## Cel
Operator nie zarządza "wszystkim naraz". Operator zawsze wykonuje jeden następny krok wskazany przez stan procesu.

## Zasada główna
Interfejs pokazuje tylko:
- bieżący krok
- dane wejściowe wymagane do tego kroku
- artefakty potrzebne do decyzji

Wszystkie pozostałe sekcje są ukryte lub zwinięte.

## Główny przebieg pracy (nowy projekt)
1. Project setup
2. Product baseline (`overview.md`, `constraints.md`, `glossary.md`)
3. Idea registry
4. Idea selection
5. Idea -> Features
6. Features -> PRD
7. PRD -> UX Contract
8. UX Contract -> BDD
9. BDD -> Tests
10. Tests -> Implementation
11. Implementation -> Validation
12. Stabilization and close

## Decyzje operatora
Operator podejmuje decyzje w punktach:
- akceptacja/odrzucenie wyniku bramki
- wybór aktywnej idei
- wybór strategii wykonania (`iterative`, `batch`, `hybrid`)
- decyzja o przejściu do kolejnego kroku
- decyzja o cofnięciu i regeneracji artefaktu upstream

## Cofanie i regeneracja
Jeśli artefakt upstream został zmieniony, downstream gate traci ważność.
Przykład: zmiana `bdd.md` unieważnia gate `BDD -> Tests`.
