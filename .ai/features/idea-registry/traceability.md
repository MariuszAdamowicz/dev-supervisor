# Śledzalność

- Reguła: Każda idea musi należeć dokładnie do jednego projektu.
  - Pokryte przez: Scenariusz 1 "Utworzenie idei dla aktywnego projektu z poprawnym tytułem"
  - Pokryte przez: Scenariusz 13 "Lista idei ograniczona wyłącznie do aktywnego projektu"
  - Pokryte przez: Scenariusz 16 "Zachowanie izolacji projektów przy dostępie do idei"

- Reguła: Operacje na ideach muszą być blokowane lub jawnie odrzucane, gdy nie wybrano aktywnego projektu.
  - Pokryte przez: Scenariusz 3 "Odrzucenie tworzenia idei, gdy nie wybrano aktywnego projektu"
  - Pokryte przez: Scenariusz 12 "Odrzucenie aktualizacji i zmian statusu, gdy nie wybrano aktywnego projektu"

- Reguła: Tworzenie i aktualizacje idei muszą być inicjowane przez operatora; brak niejawnego tworzenia idei.
  - Pokryte przez: Scenariusz 1 "Utworzenie idei dla aktywnego projektu z poprawnym tytułem"
  - Pokryte przez: Scenariusz 5 "Aktualizacja treści idei przez jawne działanie operatora"
  - Pokryte przez: Scenariusz 14 "Listowanie idei zwraca jawną pustą listę"

- Reguła: Idea musi mieć niepusty tytuł.
  - Pokryte przez: Scenariusz 4 "Odrzucenie tworzenia idei z pustym tytułem"

- Reguła: Status idei musi być jawny i ograniczony do dozwolonych stanów: `new`, `selected`, `deferred`, `done`.
  - Pokryte przez: Scenariusz 7 "Zmiana statusu idei na deferred"
  - Pokryte przez: Scenariusz 8 "Wybranie jednej idei jako kandydata do PRD"
  - Pokryte przez: Scenariusz 10 "Odrzucenie nieprawidłowej wartości statusu idei"

- Reguła: W danym projekcie co najwyżej jedna idea może mieć jednocześnie status `selected`.
  - Pokryte przez: Scenariusz 8 "Wybranie jednej idei jako kandydata do PRD"
  - Pokryte przez: Scenariusz 9 "Odrzucenie drugiej idei ze statusem selected w tym samym projekcie"

- Reguła: Wybór idei jako kandydata do PRD musi być jawny i śledzalny.
  - Pokryte przez: Scenariusz 8 "Wybranie jednej idei jako kandydata do PRD"
  - Pokryte przez: Scenariusz 15 "Wybór kandydata do PRD jest jawny i śledzalny"

- Reguła: Lista idei musi zwracać wyłącznie idee ograniczone do aktywnego projektu.
  - Pokryte przez: Scenariusz 13 "Lista idei ograniczona wyłącznie do aktywnego projektu"
  - Pokryte przez: Scenariusz 16 "Zachowanie izolacji projektów przy dostępie do idei"

- Reguła: Zmiany stanu muszą być jawne i śledzalne; ciche błędy są niedozwolone.
  - Pokryte przez: Scenariusz 3 "Odrzucenie tworzenia idei, gdy nie wybrano aktywnego projektu"
  - Pokryte przez: Scenariusz 4 "Odrzucenie tworzenia idei z pustym tytułem"
  - Pokryte przez: Scenariusz 6 "Odrzucenie aktualizacji dla nieistniejącej idei"
  - Pokryte przez: Scenariusz 9 "Odrzucenie drugiej idei ze statusem selected w tym samym projekcie"
  - Pokryte przez: Scenariusz 10 "Odrzucenie nieprawidłowej wartości statusu idei"
  - Pokryte przez: Scenariusz 11 "Odrzucenie zmiany statusu dla nieistniejącej idei"
  - Pokryte przez: Scenariusz 12 "Odrzucenie aktualizacji i zmian statusu, gdy nie wybrano aktywnego projektu"
  - Pokryte przez: Scenariusz 16 "Zachowanie izolacji projektów przy dostępie do idei"

- Reguła: Rejestr idei musi wspierać wiele idei na projekt.
  - Pokryte przez: Scenariusz 2 "Obsługa wielu idei w ramach jednego projektu"
  - Pokryte przez: Scenariusz 13 "Lista idei ograniczona wyłącznie do aktywnego projektu"
