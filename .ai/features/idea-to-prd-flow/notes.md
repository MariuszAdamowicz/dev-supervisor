# Idea to PRD Flow — Kontrola Spójności

Data: 2026-03-30
Zakres:
- `.ai/features/idea-to-prd-flow/prd.md`
- `.ai/features/idea-to-prd-flow/bdd.md`
- `Tests/IdeaToPRDFlow/IdeaToPRDFlowBDDTests.swift`
- `App/Core/Domain/IdeaToPRDFlowContract.swift`
- `App/Core/Domain/IdeaToPRDFlowModels.swift`
- `App/Core/IdeaToPRDFlow/IdeaToPRDFlowInMemory.swift`

## Wynik ogólny
Spójność rdzenia jest dobra: reguły PRD są odzwierciedlone w BDD i pokryte implementacją domenową `idea-to-prd-flow` w wariancie in-memory.

## Potwierdzona zgodność
- Generowanie promptu dla idei z aktywnego projektu zwraca jawny sukces i niepusty wynik.
- Blokada bez aktywnego projektu jest jawna i zwraca przyczynę błędu.
- Odrzucenie idei nieistniejącej lub spoza aktywnego projektu jest jawne.
- Walidacja dostępności minimalnego kontekstu (`overview`, `constraints`, `glossary`, `stack rules`) jest pokryta.
- Deterministyczność wyniku dla niezmienionych danych wejściowych jest pokryta.
- Brak automatycznego wysłania promptu do dostawcy AI jest pokryty.
- Jawna identyfikacja idei i projektu w wyniku jest pokryta.
- Brak efektów ubocznych na stanie idei jest pokryty.
- Rejestrowanie śladu operacyjnego powiązanego z ideą i projektem jest pokryte.

## Braki lub niespójności
- Brak krytycznych niespójności PRD <-> BDD <-> implementacja w aktualnym zakresie funkcji.
- Testy `IdeaToPRDFlowBDDTests` są obecnie poza domyślnym zakresem wykonywania `./Scripts/test.sh` ze względu na konfigurację targetu testowego w projekcie Xcode (kwestia infrastrukturalna, nie domenowa).

## Elementy nieaktualne
- Nie znaleziono wyraźnie nieaktualnych reguł PRD.
- Nie znaleziono wyraźnie nieaktualnych scenariuszy BDD.
- Nie znaleziono wyraźnie nieaktualnych testów.

## Rekomendowany następny pojedynczy krok
Dodać pierwszy artefakt wejściowy dla kolejnego etapu (`PRD -> BDD`) i uruchomić dla niego ten sam cykl: PRD, BDD, testy, implementacja, traceability.
