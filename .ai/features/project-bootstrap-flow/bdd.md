# Funkcja: Project Bootstrap Flow

## Scenariusz 1: Utworzenie nowego projektu z profilem file-ai
Zakładając, że operator podaje poprawną nazwę projektu i poprawną ścieżkę katalogu głównego
Kiedy operator uruchamia bootstrap projektu z profilem storage `file-ai`
Wtedy tworzony jest katalog projektu ze strukturą bootstrapową
Oraz tworzony jest baseline `.ai` i skrypty `Scripts/*`
Oraz wynik operacji to jawny sukces

## Scenariusz 2: Odrzucenie bootstrapu przy pustej nazwie projektu
Zakładając, że nazwa projektu jest pusta
Kiedy operator uruchamia bootstrap projektu
Wtedy projekt nie jest tworzony
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 3: Odrzucenie bootstrapu przy pustej ścieżce katalogu głównego
Zakładając, że ścieżka katalogu głównego jest pusta
Kiedy operator uruchamia bootstrap projektu
Wtedy projekt nie jest tworzony
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 4: Odrzucenie bootstrapu dla istniejącego niepustego katalogu
Zakładając, że docelowy katalog projektu już istnieje i zawiera pliki
Kiedy operator uruchamia bootstrap projektu
Wtedy operacja zostaje odrzucona
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 5: Utworzenie projektu z profilem sqlbase
Zakładając, że operator podaje poprawne wejścia
Kiedy operator uruchamia bootstrap projektu z profilem storage `sqlbase`
Wtedy tworzony jest baseline `.ai`
Oraz tworzony jest lokalny artefakt bazy `State/supervisor.sqlite3`
Oraz wynik operacji to jawny sukces

## Scenariusz 6: Inspekcja istniejącego projektu wykrywa artefakty bootstrapu
Zakładając, że istnieje projekt utworzony przez bootstrap
Kiedy operator uruchamia inspekcję projektu
Wtedy wynik zawiera status obecności `.ai`, `Scripts`, repozytorium git
Oraz wynik zawiera wykryty storage profile
Oraz inspekcja nie modyfikuje stanu projektu

## Scenariusz 7: Odrzucenie inspekcji nieistniejącej ścieżki
Zakładając, że wskazana ścieżka nie istnieje lub nie jest katalogiem
Kiedy operator uruchamia inspekcję projektu
Wtedy wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 8: Deterministyczny gate testów wymaga wykonania testów
Zakładając, że uruchamiana jest walidacja testów przez `./Scripts/test.sh`
Oraz domyślnie uruchamiany jest target `DevSupervisorTests` (bez UI testów)
Kiedy `xcodebuild` nie raportuje wykonanych testów lub raportuje `0`
Wtedy skrypt kończy się jawną porażką
Oraz gate testowy nie może zostać uznany za zaliczony

## Scenariusz 9: Deterministyczny gate testów nie może zawiesić workflow
Zakładając, że `xcodebuild` zawiesza się lub przekracza limit czasu
Kiedy uruchamiany jest `./Scripts/test.sh`
Wtedy watchdog timeout przerywa proces testów
Oraz skrypt kończy się jawną porażką zamiast nieskończonego oczekiwania

## Scenariusz 10: Product Gate blokuje przejście do flow idei przy brakach
Zakładając, że w projekcie brakuje jednego z artefaktów `overview/constraints/glossary`
Kiedy operator uruchamia inspekcję projektu
Wtedy wynik Product Gate ma status `fail` z listą braków
Oraz przejście `IDEA -> FEATURES` jest blokowane jawnym komunikatem

## Scenariusz 11: Bootstrap automatycznie rejestruje projekt w rejestrze projektów
Zakładając, że bootstrap nowego projektu zakończył się sukcesem
Kiedy aplikacja kończy krok bootstrapu
Wtedy nowy projekt jest automatycznie rejestrowany w `project-registry`
Oraz nowy projekt jest ustawiany jako aktywny projekt roboczy
Oraz status rejestracji jest jawnie raportowany operatorowi

## Scenariusz 12: sqlbase import/export synchronizuje artefakty DB <-> .ai
Zakładając, że aktywny projekt działa w profilu `sqlbase`
Kiedy operator uruchamia eksport `.ai -> sqlbase`
Wtedy artefakty produktu są kopiowane do `State/sqlbase/*`
Kiedy operator uruchamia import `sqlbase -> .ai`
Wtedy artefakty są odtwarzane z `State/sqlbase/*` do `.ai/*`
Oraz status synchronizacji jest jawnie raportowany operatorowi
