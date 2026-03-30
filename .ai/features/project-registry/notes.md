# Rejestr Projektów — Kontrola Spójności

Data: 2026-03-29
Zakres:
- `.ai/features/project-registry/prd.md`
- `.ai/features/project-registry/bdd.md`
- `Tests/ProjectRegistry/ProjectRegistryBDDTests.swift`
- `App/Core/Domain/ProjectRegistryContract.swift`
- `App/Core/ProjectRegistry/ProjectRegistryInMemory.swift`

## Wynik ogólny
Spójność rdzenia jest dobra: reguły PRD są szeroko odzwierciedlone w BDD i wykonywalnych testach, a bieżąca implementacja przechodzi build+test.

Główna niespójność: testy zawierają zachowania, które nie były jeszcze zamodelowane w BDD.

## Potwierdzona zgodność
- Walidacja rejestracji, unikalna tożsamość i odrzucanie duplikatu aktywnej ścieżki są pokryte.
- Aktualizacja metadanych, archiwizacja/reaktywacja oraz błędy dla nieistniejących projektów są pokryte.
- Semantyka wyboru aktywnego projektu roboczego jest pokryta.
- Zachowanie blokowania przy "braku wybranego projektu" jest pokryte.
- Zachowanie izolacji ograniczonej do projektu jest pokryte.
- Zachowanie pustej listy przy pustym rejestrze jest pokryte.
- Zachowanie jawnej porażki przy niedostępnej ścieżce jest pokryte.
- W testach egzekwowany jest wzorzec jawnej przyczyny błędu.

## Braki lub niespójności
1. Testy zawierają scenariusze, których nie ma w BDD:
- Test Scenariusz 21: aktualizacja lokalnej ścieżki na nową unikalną wartość kończy się sukcesem.
- Test Scenariusz 22: lista zawiera łącznie projekty zarchiwizowane i aktywne.

2. Luka na poziomie reguł w BDD/testach dla konfliktu reaktywacji:
- Reguła PRD mówi, że dwa aktywne projekty nie mogą współdzielić tej samej lokalnej ścieżki/odniesienia.
- Konflikt ścieżek przy rejestracji i aktualizacji jest pokryty.
- Konflikt ścieżek przy reaktywacji jest zaimplementowany w kodzie (`reactivateProject`), ale nie był jawnie pokryty w BDD/teście.

## Elementy nieaktualne
- Nie znaleziono wyraźnie nieaktualnych reguł PRD.
- Nie znaleziono wyraźnie nieaktualnych scenariuszy BDD.
- Nie znaleziono wyraźnie nieaktualnych testów.

## Rekomendowany następny pojedynczy krok
Zaktualizować `bdd.md`, aby dodać brakujące zachowanie obecnie egzekwowane przez testy (scenariusze 21 i 22), oraz dodać jeden scenariusz dla konfliktu reaktywacji przy zduplikowanej aktywnej ścieżce/odniesieniu. Następnie uruchomić generację/aktualizację testów tylko jeśli będzie to potrzebne.

---

## Aktualizacja zamknięcia

Data: 2026-03-29

Status:
- Ukończono: BDD zaktualizowane o scenariusze 21, 22, 23.
- Ukończono: dodano i zweryfikowano test dla Scenariusza 23.
- Ukończono: synchronizacja traceability z aktualnym PRD/BDD.
- Ukończono: skrypty walidacji przechodzą w obecnej konfiguracji (`build`, `test`, `lint` z ostrzeżeniami stylu).

Decyzja dla funkcji:
- `project-registry` jest uznany za funkcjonalnie domknięty w bieżącym zakresie.
- Dalsza praca przechodzi do kolejnej funkcji, chyba że zostanie wykryty defekt/regresja.
