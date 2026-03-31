## Storage Profile: file-ai

Cel:
- przechowywac runtime i artefakty procesu bezposrednio w plikach repo
- traktowac folder `.ai/` jako glowny nosnik runtime

## Model danych
- source-of-truth dla artefaktow runtime: `.ai/*`
- stan OP moze byc wyliczany z plikow lub trzymany pomocniczo w pamieci

## Zakres
- `.ai/prd/*`
- `.ai/features/<feature>/*`
- `.ai/ideas.md`
- `.ai/stack/*`
- `.ai/ux/*`

## Reguly
- kazda zmiana procesu aktualizuje odpowiednie pliki `.ai`
- decyzje gate i audit sa zapisywane w modelu OP (GateDecision + ProcessEvent)
- notes/tasks moga zawierac kontekst pomocniczy, ale nie zastepuja audit trail
- transport promptow moze byc zautomatyzowany (np. MCP), ale zapis artefaktow pozostaje audytowalny w repo

## Zalety
- prosty audyt przez git
- niski prog wejscia
- brak zaleznosci od silnika DB

## Ograniczenia
- trudniejsze query przekrojowe (cross-feature/cross-project)
- wieksza ilosc recznych aktualizacji przy rozbudowanym runtime
