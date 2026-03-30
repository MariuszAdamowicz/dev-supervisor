# Funkcja: Implementation to Validation Flow

## Cel
Zapewnić jawny i deterministyczny krok `IMPLEMENTACJA -> WALIDACJA`, który buduje prompt walidacji i stabilizacji na podstawie opisu implementacji.

## Wejścia
- Aktywny projekt.
- Tożsamość idei źródłowej.
- Tytuł idei.
- Treść dokumentu implementacji.
- Kontekst minimalny (`overview`, `constraints`, `glossary`, `stack-rules`).

## Wyjścia
- Prompt `IMPLEMENTACJA -> WALIDACJA` gotowy do użycia przez operatora.
- Jawny sukces albo jawna porażka.
- Ślad operacyjny powiązany z ideą i projektem.

## Reguły
- Brak aktywnego projektu blokuje operację.
- Tytuł idei i dokument implementacji są wymagane.
- Brak źródeł kontekstu powoduje jawną porażkę.
- Prompt jest deterministyczny dla tych samych wejść.
- Aplikacja nie wykonuje promptu u dostawcy AI.

## Poza zakresem
- Automatyczne wykonanie planu walidacji bez decyzji operatora.
- Automatyczne modyfikacje kodu wynikające ze stabilizacji.
