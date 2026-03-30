# Funkcja: Idea to Features Flow

## Cel
Zapewnić deterministyczny i jawny krok `IDEA -> FEATURES`, który materializuje wybraną ideę do zestawu funkcjonalności możliwych do dalszego uszczegółowienia w PRD.

## Wejścia
- Aktywny projekt wybrany przez operatora.
- Idea należąca do aktywnego projektu.
- Idea w statusie `selected`.
- Kontekst minimalny (`overview`, `constraints`, `glossary`).
- Jawne działanie operatora uruchamiające krok `IDEA -> FEATURES`.

## Wyjścia
- Wygenerowany prompt `IDEA -> FEATURES`.
- Deterministyczna lista kandydatów funkcjonalnych (feature candidates).
- Jawny sukces albo jawna porażka z przyczyną.
- Ślad operacyjny powiązany z ideą i projektem.

## Reguły
- Brak aktywnego projektu blokuje operację jawnie.
- Idea spoza aktywnego projektu jest odrzucana jawnie.
- Idea musi mieć status `selected`.
- Prompt używa wyłącznie minimalnego kontekstu.
- Aplikacja nie wysyła promptu do AI; operator uruchamia go ręcznie.
- Wielokrotne uruchomienie dla tych samych danych daje deterministyczny wynik.
- Operacja nie modyfikuje treści ani statusu idei.

## Przypadki brzegowe
- Brak aktywnego projektu.
- Nieistniejąca idea.
- Idea spoza aktywnego projektu.
- Idea w statusie innym niż `selected`.
- Brak jednego ze źródeł kontekstu.

## Poza zakresem
- Generowanie finalnego PRD.
- Automatyczna synchronizacja wyniku do plików PRD bez decyzji operatora.
- Ranking biznesowy feature'ów przez AI.
