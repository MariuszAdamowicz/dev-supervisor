# Śledzalność

- Reguła: Bootstrap jest inicjowany wyłącznie przez operatora.
  - Pokryte przez: Scenariusz 1 "Utworzenie nowego projektu z profilem file-ai"

- Reguła: Nazwa projektu i katalog główny muszą być niepuste.
  - Pokryte przez: Scenariusz 2 "Odrzucenie bootstrapu przy pustej nazwie projektu"
  - Pokryte przez: Scenariusz 3 "Odrzucenie bootstrapu przy pustej ścieżce katalogu głównego"

- Reguła: Jeśli docelowy katalog projektu już istnieje i nie jest pusty, bootstrap jest odrzucany jawnie.
  - Pokryte przez: Scenariusz 4 "Odrzucenie bootstrapu dla istniejącego niepustego katalogu"

- Reguła: Profil storage musi być jawny i zapisany.
  - Pokryte przez: Scenariusz 1 "Utworzenie nowego projektu z profilem file-ai"
  - Pokryte przez: Scenariusz 5 "Utworzenie projektu z profilem sqlbase"

- Reguła: Dla `sqlbase` musi powstać lokalny artefakt bazy.
  - Pokryte przez: Scenariusz 5 "Utworzenie projektu z profilem sqlbase"

- Reguła: Inspekcja istniejącego projektu nie modyfikuje stanu i zwraca jawny raport.
  - Pokryte przez: Scenariusz 6 "Inspekcja istniejącego projektu wykrywa artefakty bootstrapu"

- Reguła: Inspekcja nieistniejącej ścieżki zwraca jawny błąd.
  - Pokryte przez: Scenariusz 7 "Odrzucenie inspekcji nieistniejącej ścieżki"

- Reguła: Walidacja testów jest deterministyczna i wymaga realnie wykonanych testów (`testsCount > 0`).
  - Pokryte przez: Scenariusz 8 "Deterministyczny gate testów wymaga wykonania testów"

- Reguła: Walidacja testów nie może blokować workflow bez końca (timeout watchdog).
  - Pokryte przez: Scenariusz 9 "Deterministyczny gate testów nie może zawiesić workflow"

- Reguła: Product Gate (`overview/constraints/glossary`) musi być spełniony przed przejściem `IDEA -> FEATURES`.
  - Pokryte przez: Scenariusz 10 "Product Gate blokuje przejście do flow idei przy brakach"

- Reguła: Po udanym bootstrapie projekt jest automatycznie rejestrowany i aktywowany w `project-registry`.
  - Pokryte przez: Scenariusz 11 "Bootstrap automatycznie rejestruje projekt w rejestrze projektów"

- Reguła: Dla profilu `sqlbase` artefakty muszą być synchronizowalne dwukierunkowo (`DB <-> .ai`).
  - Pokryte przez: Scenariusz 12 "sqlbase import/export synchronizuje artefakty DB <-> .ai"

- Reguła: Rejestr projektów musi być trwały i odtwarzalny po restarcie aplikacji, z separacją per profil.
  - Pokryte przez: Scenariusz 13 "Rejestr projektów jest odtwarzany po restarcie aplikacji"
