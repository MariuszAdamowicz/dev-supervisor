# Funkcja: Tests to Implementation Flow

## Cel
Zapewnić jawny i deterministyczny krok `TESTY -> IMPLEMENTACJA`, który buduje prompt implementacyjny na podstawie zatwierdzonego dokumentu testów.

## Wejścia
- Aktywny projekt.
- Tożsamość idei źródłowej.
- Tytuł idei.
- Treść dokumentu testów.
- Kontekst minimalny (`overview`, `constraints`, `glossary`, `stack-rules`).

## Wyjścia
- Prompt `TESTY -> IMPLEMENTACJA` gotowy do użycia przez operatora.
- Jawny sukces albo jawna porażka.
- Ślad operacyjny powiązany z ideą i projektem.

## Reguły
- Brak aktywnego projektu blokuje operację.
- Tytuł idei i dokument testów są wymagane.
- Brak źródeł kontekstu powoduje jawną porażkę.
- Prompt jest deterministyczny dla tych samych wejść.
- Aplikacja nie wykonuje promptu u dostawcy AI.

## Poza zakresem
- Automatyczne zapisanie wygenerowanej implementacji do kodu bez decyzji operatora.
- Automatyczne uruchamianie kolejnego kroku walidacyjnego.
