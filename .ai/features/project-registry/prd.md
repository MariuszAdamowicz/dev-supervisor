# Funkcja: Rejestr Projektów

## Cel
Zapewnić deterministyczny sposób rejestrowania, przeglądania i zarządzania nadzorowanymi projektami, aby każdy projekt miał jawną tożsamość, izolację i widoczność cyklu życia w Dev Supervisor.

## Wejścia
- Działanie operatora polegające na utworzeniu rekordu projektu.
- Metadane projektu podane przez operatora (nazwa projektu i lokalna ścieżka/odniesienie).
- Działanie operatora polegające na aktualizacji metadanych projektu.
- Działanie operatora polegające na archiwizacji lub reaktywacji projektu.
- Żądanie operatora dotyczące listy projektów.
- Działanie operatora polegające na wyborze aktywnego projektu.

## Wyjścia
- Utrwalony rekord projektu ze stabilną tożsamością i jawnymi metadanymi.
- Lista projektów widoczna dla operatora.
- Widoczność statusu projektu (aktywny lub zarchiwizowany).
- Deterministyczna informacja zwrotna dla każdej operacji (sukces albo jawna przyczyna błędu).
- Informacja o aktualnie aktywnym projekcie.

## Reguły
- Projekt musi mieć niepustą nazwę i niepustą lokalną ścieżkę/odniesienie.
- Każdy projekt musi być jednoznacznie identyfikowalny w rejestrze.
- Dwa aktywne rekordy projektów nie mogą wskazywać tej samej lokalnej ścieżki/odniesienia.
- Rejestracja i aktualizacje projektu muszą być inicjowane przez operatora; brak niejawnego tworzenia projektu.
- Dane projektu muszą pozostać odizolowane od idei, funkcji, postępu i metadanych innych projektów.
- Operacje archiwizacji/reaktywacji muszą zachowywać historię i tożsamość projektu.
- Rejestr musi wspierać wiele projektów jednocześnie.
- Zmiany stanu muszą być jawne i śledzalne; ciche błędy są niedozwolone.
- Dokładnie jeden projekt może być wybrany jako aktywny projekt roboczy w danym momencie.
- Aktywny projekt musi być jawnie ustawiony przez operatora.
- Jeśli żaden projekt nie jest wybrany, operacje na poziomie funkcji muszą być blokowane lub zwracać jawny błąd.

## Przypadki brzegowe
- Próba zarejestrowania projektu z brakującymi wymaganymi polami.
- Próba zarejestrowania projektu, którego lokalna ścieżka/odniesienie jest już używana przez inny aktywny projekt.
- Próba archiwizacji projektu, który jest już zarchiwizowany.
- Próba reaktywacji projektu, który jest już aktywny.
- Próba aktualizacji lub archiwizacji nieistniejącego projektu.
- Lokalna ścieżka/odniesienie projektu staje się niedostępna po rejestracji.
- W rejestrze nie istnieją żadne projekty.

## Poza zakresem
- Wykonywanie build/test/lint lub promptów projektu.
- Automatyczne wykrywanie projektów bez działania operatora.
- Zarządzanie artefaktami implementacyjnymi (PRD/BDD/testy/kod) wykraczającymi poza odniesienia rejestru.
- Łączenie projektów między sobą, synchronizacja lub współdzielony stan mutowalny między projektami.
- Rejestr projektów oparty o chmurę lub zachowania zdalnej współpracy.
