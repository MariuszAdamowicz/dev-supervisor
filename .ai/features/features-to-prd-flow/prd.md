# Funkcja: Features to PRD Flow

## Cel
Zapewnić jawny i deterministyczny krok `FEATURES -> PRD`, który buduje prompt PRD na podstawie zatwierdzonego zestawu funkcjonalności.

## Wejścia
- Aktywny projekt.
- Tożsamość idei źródłowej.
- Tytuł idei.
- Lista kandydatów funkcjonalnych (feature candidates).
- Kontekst minimalny (`overview`, `constraints`, `glossary`, `stack-rules`).

## Wyjścia
- Prompt `FEATURES -> PRD` gotowy do użycia przez operatora.
- Jawny sukces albo jawna porażka.
- Ślad operacyjny powiązany z ideą i projektem.

## Reguły
- Brak aktywnego projektu blokuje operację.
- Tytuł idei i lista funkcjonalności są wymagane.
- Brak źródeł kontekstu powoduje jawną porażkę.
- Prompt jest deterministyczny dla tych samych wejść.
- Aplikacja nie wykonuje promptu u dostawcy AI.

## Poza zakresem
- Automatyczne zapisanie wygenerowanego PRD do plików bez decyzji operatora.
- Automatyczne uruchamianie kolejnego kroku `PRD -> BDD`.
