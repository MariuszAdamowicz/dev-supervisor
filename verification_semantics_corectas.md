# Verification Semantics Correctas

## Stan obecny przed zmianami

Walidacja mocno sprawdzala coverage, nazwy i fixture, a za slabo sprawdzala semantyke:
- workflow vs exec,
- authz,
- invariants,
- CRUD,
- provenance,
- rozdzial simulation vs runtime capture.

## CRUD dla punktu

Create:
- raporty i logi powstawaly, ale bez klasy dowodu i bez jasnego odroznienia syntetycznego od realnego.

Read:
- odbiorca raportu nie mial wystarczajacej informacji, co jest fixture, a co real runtime.

Update:
- raporty mogly byc uznane za PASS mimo brakow semantycznych.

Remove:
- nie dotyczy bezposrednio, ale brakowalo zasad retencji i klasyfikacji evidence.

## Praktyki zewnetrzne

- Pact: kontrakt ma sprawdzac zachowanie na granicy.
- OWASP: testy autoryzacyjne musza byc jawne.
- Temporal: replay jest przydatny, ale nie zastapi realnego wykonania workflow.

Linki:
- https://docs.pact.io/
- https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html
- https://docs.temporal.io/workflow-definition

## Plan zmian

1. Dodac osobna warstwe `semantic validation`.
2. Dodac skrypt audytujacy semantyczne kontrakty.
3. Zmienic definicje globalnego PASS.
4. Urealnic report template i correctness matrix.

## Czy plan domyka problem

Tak. Po zmianie nie da sie juz twierdzic, ze "full verification" oznacza tylko ładne coverage i fixture.

## Wprowadzone zmiany

- dodany `playbook/verification/semantic-validation.md`,
- dodany `playbook/verification/scripts/semantic-contract-audit.sh`,
- zaktualizowane `playbook/verification/index.md`,
- zaktualizowane `playbook/verification/static-validation.md`,
- zaktualizowane `playbook/verification/playbook-correctness-matrix.md`,
- zaktualizowany `playbook/verification/report-template.md`,
- `playbook/verification/scripts/verify-all.sh` rozroznia semantic validation i partial status bez real runtime capture.

## Podsumowanie

Walidacja przestala byc "sprawdzaniem kompletnej tabelki". Zaczela weryfikowac, czy playbook rzeczywiscie opisuje egzekwowalny i uczciwie raportowany proces.
