# Funkcja: BDD to Tests Flow

## Cel
Zapewnić jawny i deterministyczny krok `BDD -> TESTY`, który buduje prompt testów na podstawie zatwierdzonego dokumentu BDD.

## Wejścia
- Aktywny projekt.
- Tożsamość idei źródłowej.
- Tytuł idei.
- Treść dokumentu BDD.
- Kontekst minimalny (`overview`, `constraints`, `glossary`, `stack-rules`).

## Wyjścia
- Prompt `BDD -> TESTY` gotowy do użycia przez operatora.
- Jawny sukces albo jawna porażka.
- Ślad operacyjny powiązany z ideą i projektem.

## Reguły
- Brak aktywnego projektu blokuje operację.
- Tytuł idei i dokument BDD są wymagane.
- Brak źródeł kontekstu powoduje jawną porażkę.
- Prompt jest deterministyczny dla tych samych wejść.
- Aplikacja nie wykonuje promptu u dostawcy AI.

## Poza zakresem
- Automatyczne zapisanie wygenerowanych testów do plików bez decyzji operatora.
- Automatyczne uruchamianie kolejnego kroku implementacyjnego.
