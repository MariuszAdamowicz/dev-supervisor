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
