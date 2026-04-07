# Start Prompt Revalidation

Cel:
sprawdzic, czy po korektach playbook poprowadzilby sesje startowa sensowniej niz poprzednio.

## Co sprawdzilem

1. Odczytalem ponownie `.prompt/start-prompt.txt`.
2. Uruchomilem `./playbook/verification/scripts/exec-dry-run.sh new_project playbook/runtime/playbook-exec.yaml`.
3. Porownalem nowy shape runtime z poprzednia porazka UX.

## Wynik

Zmiany pomagaja.

Najwazniejsze roznice:
- `new_project` zaczyna sie od task-first contract (`user_goal`, `primary_job`, `screen_id`, `primary_action`), a nie od samego `prompt_id/prompt_text`.
- exec spec wymaga teraz baseline bundle bogatszego niz tylko `overview/constraints/glossary`.
- authz precheck jest jawny (`NP-03A` / `policy-engine`).
- playbook rozroznia evidence syntetyczne od realnego runtime.
- verification nie pozwala juz uznac fixture za globalny PASS.

## Oczekiwana pierwsza odpowiedz na prompt po korektach

1. Potwierdzenie zadania:
   - sesja ma dostarczyc end-to-end flow `New Project -> baseline -> Idea -> downstream OP -> kod + testy + commit`,
   - ale wykonanie musi od poczatku uwzglednic task-first UX, baseline architecture, authz i evidence provenance.

2. Plan:
   1. zweryfikowac kontrakt `new_project` w `playbook-exec.yaml`,
   2. zweryfikowac baseline completeness,
   3. zweryfikowac `ActorRolePermission` i authz precheck,
   4. przygotowac artefakt `.ai/ux/new-project.md`,
   5. uruchomic `new_project`,
   6. uruchomic `add_idea`,
   7. utworzyc downstream OP,
   8. przejsc do `refine_feature` i `align_feature_ux`,
   9. wykonac quality lane,
   10. wygenerowac runtime/evidence package,
   11. dopiero potem uznac wynik za gotowy.

3. Pierwsze dzialanie:
   - walidacja, czy `new_project` ma komplet kontraktow: UX, baseline, authz, CRUD, provenance.

## Wniosek

Poprawiony playbook nie gwarantuje automatycznie dobrego UI, ale blokuje poprzedni blad systemowy:
- nie da sie juz uczciwie dowiezc promptu, ignorujac UX contract,
- nie da sie uczciwie nazwac fixture pelnym PASS,
- nie da sie uczciwie pominac baseline architecture i authz.
