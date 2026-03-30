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
