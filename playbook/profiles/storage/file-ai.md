## Storage Profile: file-ai

Cel:
- przechowywać stan i artefakty procesu bezpośrednio w plikach repo
- traktować folder `.ai/` jako główny nośnik procesu

## Model danych
- source-of-truth dla artefaktów: pliki `.ai/*`
- stan operacyjny może być wyliczany z plików lub trzymany pomocniczo w pamięci

## Zakres
- `.ai/prd/*`
- `.ai/features/<feature>/*`
- `.ai/ideas.md`
- `.ai/stack/*`

## Reguły
- każda zmiana procesu musi aktualizować odpowiednie pliki `.ai`
- decyzje gate operatora muszą być jawnie zapisane w artefaktach feature (`notes.md`/`tasks.md`)
- transport promptów może być zautomatyzowany (np. MCP), ale finalny zapis artefaktów pozostaje audytowalny w repo

## Zalety
- prosty audyt przez git
- niski próg wejścia
- brak zależności od silnika DB

## Ograniczenia
- trudniejsze query przekrojowe (cross-feature/cross-project)
- większa ilość ręcznych aktualizacji przy rozbudowanym workflow
