# Project Bootstrap Flow — Status Zadań

Data: 2026-03-30

- [x] domknięcie zakresu i reguł PRD
- [x] wygenerowanie scenariuszy BDD
- [x] implementacja kontraktu bootstrapu i inspekcji projektu (filesystem)
- [x] dodanie pierwszego UI dla operatora (bootstrap + inspect)
- [x] dodanie testów dla bootstrapu i inspekcji
- [x] poprawa konfiguracji test target, aby testy BDD były kompilowane przez Xcode
- [x] pełne domknięcie pętli walidacyjnej `test` z deterministic gate (`testsCount > 0`)
- [x] uzupełnienie traceability i notes po finalnym hardeningu

## Odroczone / Następne
- [x] integracja bootstrapu z rejestrem projektów domenowych
- [x] Product Gate w UI (sekcje, checklista, status pass/fail)
- [x] import/eksport artefaktów dla trybu sqlbase (DB <-> `.ai`)
- [x] trwała persystencja `project-registry` per profil (`file-ai`, `sqlbase`) z odtwarzaniem po restarcie
