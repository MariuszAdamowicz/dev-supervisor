## Storage Profile: sqlbase

Cel:
- przechowywać stan operacyjny procesu w lokalnej bazie SQL (np. SQLite)
- zachować spójne workflowy i decyzje operatorskie bez ręcznego zarządzania wszystkimi artefaktami

## Model danych
- source-of-truth dla stanu operacyjnego: lokalna baza SQL
- artefakty specyfikacji (`PRD`, `BDD`, `traceability`) pozostają eksportowalne do plików `.ai/*`

## Zakres danych w DB
- projekty, feature, scenariusze, statusy
- decyzje gate operatora i historia walidacji
- mapowania traceability
- log promptów i hash kontekstu

## Reguły
- każdy stan workflow ma odpowiadający rekord/transakcję w DB
- eksport artefaktów do `.ai/*` musi być deterministyczny
- import zmian z plików do DB musi być jawny i walidowany
- brak automatycznego wykonywania promptów przez aplikację (operator-driven model)

## Zalety
- łatwe query i raportowanie przekrojowe
- lepsza skalowalność procesu
- prostsza automatyzacja gate'ów i dashboardów

## Ograniczenia
- wyższa złożoność implementacyjna
- konieczność utrzymania migracji schematu i polityki synchronizacji DB <-> pliki
