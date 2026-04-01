## Storage Profile: sqlbase

Cel:
- przechowywac stan operacyjny procesu w lokalnej bazie SQL (np. SQLite)
- zachowac spojne workflowy i decyzje operatorskie bez recznego zarzadzania wszystkimi artefaktami

## Model danych
- source-of-truth dla stanu operacyjnego: lokalna baza SQL
- artefakty specyfikacji (PRD, BDD, traceability) pozostaja eksportowalne do plikow .ai/*

## Zakres danych w DB
- projekty, feature, scenariusze, statusy
- decyzje gate operatora i historia walidacji
- mapowania traceability
- log promptow i hash kontekstu

## Reguly
- kazdy stan workflow ma odpowiadajacy rekord/transakcje w DB
- eksport artefaktow do .ai/* musi byc deterministyczny
- import zmian z plikow do DB musi byc jawny i walidowany
- brak automatycznego wykonywania promptow przez aplikacje (operator-driven model)
- kontrola job lifecycle AI (submit/poll/retry/cancel/reset_context) nalezy do DS
- MCP moze byc adapterem transportowym, ale nie control-plane

## Zalety
- latwe query i raportowanie przekrojowe
- lepsza skalowalnosc procesu
- prostsza automatyzacja gate i dashboardow

## Ograniczenia
- wyzsza zlozonosc implementacyjna
- koniecznosc utrzymania migracji schematu i polityki synchronizacji DB <-> pliki
