# Funkcja: PRD to BDD Flow

## Cel
Zapewnić jawny i deterministyczny krok `PRD -> BDD`, który buduje prompt BDD na podstawie zatwierdzonego dokumentu PRD.

## Wejścia
- Aktywny projekt.
- Tożsamość idei źródłowej.
- Tytuł idei.
- Treść dokumentu PRD.
- Kontekst minimalny (`overview`, `constraints`, `glossary`, `stack-rules`).

## Wyjścia
- Prompt `PRD -> BDD` gotowy do użycia przez operatora.
- Jawny sukces albo jawna porażka.
- Ślad operacyjny powiązany z ideą i projektem.

## Reguły
- Brak aktywnego projektu blokuje operację.
- Tytuł idei i dokument PRD są wymagane.
- Brak źródeł kontekstu powoduje jawną porażkę.
- Prompt jest deterministyczny dla tych samych wejść.
- Aplikacja nie wykonuje promptu u dostawcy AI.

## Poza zakresem
- Automatyczne zapisanie wygenerowanego BDD do plików bez decyzji operatora.
- Automatyczne uruchamianie kolejnego kroku `BDD -> TESTY`.
