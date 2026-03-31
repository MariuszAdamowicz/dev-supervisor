# Project Instance Layer

Rola:
- runtime procesu dla konkretnego projektu prowadzonego przez operatora.

Zakres:
- artefakty projektu,
- stany OP dla danego projektu,
- decyzje gate,
- historia zdarzen,
- kod i testy produktu.

Przyklady storage:
- .ai/* (file-ai)
- SQLBase (db-backed)

Co dzieje sie w tej warstwie:
- CRUD na obiektach OP dla konkretnej instancji projektu,
- wykonanie promptow i walidacji,
- realne przejscia stanowe i decyzje operatora.

Co ta warstwa nie robi:
- nie definiuje modelu OP,
- nie zmienia regul playbooka bez jawnej aktualizacji Playbook Layer.
