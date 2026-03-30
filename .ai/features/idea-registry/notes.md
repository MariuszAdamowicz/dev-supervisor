# Rejestr Idei — Kontrola Spójności

Data: 2026-03-30
Zakres:
- `.ai/features/idea-registry/prd.md`
- `.ai/features/idea-registry/bdd.md`
- `Tests/IdeaRegistry/IdeaRegistryBDDTests.swift`
- `App/Core/Domain/IdeaRegistryContract.swift`
- `App/Core/Domain/IdeaRegistryModels.swift`
- `App/Core/IdeaRegistry/IdeaRegistryInMemory.swift`

## Wynik ogólny
Spójność rdzenia jest dobra: reguły PRD są odzwierciedlone w BDD i zaimplementowane w domenie `idea-registry` in-memory.

## Potwierdzona zgodność
- Tworzenie idei z poprawnym tytułem i stabilną tożsamością jest pokryte.
- Obsługa wielu idei w jednym projekcie jest pokryta.
- Blokada operacji przy braku aktywnego projektu jest pokryta.
- Walidacja pustego tytułu jest pokryta.
- Aktualizacja treści idei i zachowanie tożsamości są pokryte.
- Zmiany statusów idei (`new`, `selected`, `deferred`, `done`) oraz odrzucanie statusów nieprawidłowych są pokryte.
- Reguła pojedynczej idei `selected` w obrębie projektu jest pokryta.
- Izolacja projektowa przy listowaniu i mutacjach idei jest pokryta.
- Pusta lista idei dla projektu bez idei jest pokryta.

## Braki lub niespójności
- Brak krytycznych niespójności PRD <-> BDD <-> implementacja w aktualnym zakresie funkcji.
- Testy `IdeaRegistryBDDTests` są obecnie poza domyślnym zakresem wykonywania `./Scripts/test.sh` ze względu na konfigurację targetu testowego w projekcie Xcode (kwestia infrastrukturalna, nie domenowa).

## Elementy nieaktualne
- Nie znaleziono wyraźnie nieaktualnych reguł PRD.
- Nie znaleziono wyraźnie nieaktualnych scenariuszy BDD.
- Nie znaleziono wyraźnie nieaktualnych testów.

## Rekomendowany następny pojedynczy krok
Dodać artefakt funkcji wiążący `idea-registry` z przejściem do generowania PRD (np. jawna operacja wyboru idei i uruchomienia kroku `IDEA -> PRD`), a następnie opisać go w PRD/BDD jako nową funkcję lub rozszerzenie istniejącej.
