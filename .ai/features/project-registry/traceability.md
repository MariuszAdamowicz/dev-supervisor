# Śledzalność

- Reguła: Projekt musi mieć niepustą nazwę i niepustą lokalną ścieżkę/odniesienie.
  - Pokryte przez: Scenariusz 3 "Odrzucenie rejestracji z brakującymi wymaganymi polami"

- Reguła: Każdy projekt musi być jednoznacznie identyfikowalny w rejestrze.
  - Pokryte przez: Scenariusz 1 "Rejestracja poprawnego projektu"
  - Pokryte przez: Scenariusz 2 "Rejestracja wielu projektów równolegle"

- Reguła: Dwa aktywne rekordy projektów nie mogą wskazywać tej samej lokalnej ścieżki/odniesienia.
  - Pokryte przez: Scenariusz 4 "Odrzucenie zduplikowanej aktywnej ścieżki/odniesienia"
  - Pokryte przez: Scenariusz 20 "Odrzucenie aktualizacji wprowadzającej zduplikowaną aktywną ścieżkę/odniesienie"
  - Pokryte przez: Scenariusz 23 "Odrzucenie reaktywacji, gdy ścieżka/odniesienie koliduje z innym aktywnym projektem"

- Reguła: Rejestracja i aktualizacje projektu muszą być inicjowane przez operatora; brak niejawnego tworzenia projektu.
  - Pokryte przez: Scenariusz 1 "Rejestracja poprawnego projektu"
  - Pokryte przez: Scenariusz 5 "Aktualizacja metadanych projektu przez jawne działanie operatora"
  - Pokryte przez: Scenariusz 15 "Zachowanie listy, gdy nie istnieją żadne projekty"

- Reguła: Dane projektu muszą pozostać odizolowane od idei, funkcji, postępu i metadanych innych projektów.
  - Pokryte przez: Scenariusz 14 "Izolacja projektu w nadzorowanych danych"

- Reguła: Operacje archiwizacji/reaktywacji muszą zachowywać historię i tożsamość projektu.
  - Pokryte przez: Scenariusz 7 "Archiwizacja projektu zachowuje tożsamość i historię"
  - Pokryte przez: Scenariusz 8 "Reaktywacja zarchiwizowanego projektu zachowuje tożsamość i historię"

- Reguła: Rejestr musi wspierać wiele projektów jednocześnie.
  - Pokryte przez: Scenariusz 2 "Rejestracja wielu projektów równolegle"
  - Pokryte przez: Scenariusz 22 "Lista zawiera razem projekty aktywne i zarchiwizowane"

- Reguła: Zmiany stanu muszą być jawne i śledzalne; ciche błędy są niedozwolone.
  - Pokryte przez: Scenariusz 3 "Odrzucenie rejestracji z brakującymi wymaganymi polami"
  - Pokryte przez: Scenariusz 4 "Odrzucenie zduplikowanej aktywnej ścieżki/odniesienia"
  - Pokryte przez: Scenariusz 6 "Odrzucenie aktualizacji dla nieistniejącego projektu"
  - Pokryte przez: Scenariusz 9 "Odrzucenie archiwizacji już zarchiwizowanego projektu"
  - Pokryte przez: Scenariusz 10 "Odrzucenie reaktywacji już aktywnego projektu"
  - Pokryte przez: Scenariusz 16 "Odrzucenie archiwizacji dla nieistniejącego projektu"
  - Pokryte przez: Scenariusz 17 "Jawna porażka, gdy zarejestrowana ścieżka/odniesienie jest niedostępna"
  - Pokryte przez: Scenariusz 18 "Odrzucenie wyboru nieistniejącego projektu"
  - Pokryte przez: Scenariusz 19 "Odrzucenie wyboru zarchiwizowanego projektu"
  - Pokryte przez: Scenariusz 20 "Odrzucenie aktualizacji wprowadzającej zduplikowaną aktywną ścieżkę/odniesienie"
  - Pokryte przez: Scenariusz 23 "Odrzucenie reaktywacji, gdy ścieżka/odniesienie koliduje z innym aktywnym projektem"

- Reguła: Dokładnie jeden projekt może być wybrany jako aktywny projekt roboczy w danym momencie.
  - Pokryte przez: Scenariusz 11 "Jawny wybór jednego aktywnego projektu roboczego"
  - Pokryte przez: Scenariusz 12 "Zamiana wyboru aktywnego projektu roboczego"

- Reguła: Aktywny projekt musi być jawnie ustawiony przez operatora.
  - Pokryte przez: Scenariusz 11 "Jawny wybór jednego aktywnego projektu roboczego"
  - Pokryte przez: Scenariusz 12 "Zamiana wyboru aktywnego projektu roboczego"

- Reguła: Jeśli żaden projekt nie jest wybrany, operacje na poziomie funkcji muszą być blokowane lub zwracać jawny błąd.
  - Pokryte przez: Scenariusz 13 "Blokowanie operacji na poziomie funkcji, gdy nie wybrano projektu"
