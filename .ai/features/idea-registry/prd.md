# Funkcja: Rejestr Idei

## Cel
Zapewnić deterministyczny i ograniczony do projektu sposób zapisywania, organizowania i wybierania idei, tak aby operator mógł przenosić idee do przepływu specyfikacji funkcji bez utraty kontekstu i bez mieszania pracy między projektami.

## Wejścia
- Działanie operatora polegające na utworzeniu idei dla aktywnego projektu.
- Ładunek idei podany przez operatora (tytuł + opcjonalny opis/kontekst).
- Działanie operatora polegające na aktualizacji treści idei.
- Działanie operatora polegające na zmianie statusu idei.
- Żądanie operatora dotyczące listy idei dla aktywnego projektu.
- Działanie operatora polegające na wybraniu jednej idei jako kolejnego kandydata do wygenerowania PRD.

## Wyjścia
- Utrwalony rekord idei ze stabilną tożsamością i jawnym statusem.
- Lista idei ograniczona do projektu, widoczna dla operatora.
- Deterministyczne wyniki operacji (jawny sukces albo jawna przyczyna błędu).
- Jawny wskaźnik, która idea jest wybrana jako następny kandydat do PRD.

## Reguły
- Każda idea musi należeć dokładnie do jednego projektu.
- Operacje na ideach muszą być blokowane lub jawnie odrzucane, gdy nie wybrano aktywnego projektu.
- Tworzenie i aktualizacje idei muszą być inicjowane przez operatora; brak niejawnego tworzenia idei.
- Idea musi mieć niepusty tytuł.
- Status idei musi być jawny i ograniczony do dozwolonych stanów: `new`, `selected`, `deferred`, `done`.
- W danym projekcie co najwyżej jedna idea może mieć jednocześnie status `selected`.
- Wybór idei jako kandydata do PRD musi być jawny i śledzalny.
- Lista idei musi zwracać wyłącznie idee ograniczone do aktywnego projektu.
- Zmiany stanu muszą być jawne i śledzalne; ciche błędy są niedozwolone.
- Rejestr idei musi wspierać wiele idei na projekt.

## Przypadki brzegowe
- Próba utworzenia idei, gdy nie wybrano aktywnego projektu.
- Próba utworzenia idei z pustym tytułem.
- Próba aktualizacji lub zmiany statusu nieistniejącej idei.
- Próba ustawienia `selected` dla idei, gdy inna idea w tym samym projekcie ma już status `selected`.
- Próba dostępu do idei z innego kontekstu projektu.
- Listowanie idei, gdy projekt nie ma żadnych idei.

## Poza zakresem
- Automatyczne generowanie PRD z idei bez działania operatora.
- Automatyczne wykonywanie promptów wobec dowolnego dostawcy AI.
- Deduplikacja idei między projektami lub globalne wyszukiwanie idei w zakresie tej funkcji.
- Ranking/priorytetyzacja z wykorzystaniem scoringu AI.
- Zarządzanie artefaktami implementacyjnymi wykraczającymi poza rekordy na poziomie idei.
