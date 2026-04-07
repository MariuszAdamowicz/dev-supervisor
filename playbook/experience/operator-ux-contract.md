# Operator UX Contract

Cel:
zamienic projection OP -> UI w twardy kontrakt wykonawczy i walidacyjny dla aplikacji operatora.

## 1. Zasady nadrzedne

1. Task-first
- primary UI komunikuje cel operatora, nie nazwe transition ani stan OP.
- nazwy OP, eventy i runtime ids sa detalem audit/debug, nie primary copy.

2. One primary job
- kazdy ekran ma jeden glowny cel i jedna domyslna akcje.
- pozostale akcje sa secondary, tertiary albo ukryte do czasu spelnienia guardow.

3. Progressive disclosure
- operator widzi najpierw tylko dane potrzebne do nastepnej decyzji.
- audit trail, event history, ids, payload hashes, retry policy i details sa domyslnie zwiniete.

4. Operator UI != audit/debug UI
- tryb operacyjny sluzy do wykonania pracy.
- tryb audit/debug sluzy do inspekcji procesu.
- te tryby musza byc rozdzielone na poziomie informacji, nawigacji i CTA.

5. Feedback and recovery
- kazdy dluzszy krok pokazuje status: waiting, running, blocked, needs-decision, completed, failed.
- kazdy blad musi zawierac skutek, przyczyne zrozumiala dla operatora i nastepna akcje.

6. Accessibility minimum
- kazdy formularz ma labels/instructions, inline validation, focus order i obsluge klawiatury.
- kontrast, stany focus i status messages sa obowiazkowe dla krytycznych flow.

## 2. Kontrakt entrypointu

Kazdy entrypoint runtime musi miec jawny kontrakt UX z polami:
- `user_goal`
- `primary_actor`
- `primary_screen`
- `primary_job`
- `primary_action`
- `step_sequence`
- `required_inputs`
- `field_labels`
- `inline_validation_rules`
- `loading_state`
- `success_state`
- `error_state`
- `empty_state`
- `blocked_state`
- `copy_style`
- `audit_mode_sections`
- `accessibility_notes`

## 3. Artefakt runtime

Kazdy istotny entrypoint tworzy `.ai/ux/<entrypoint>.md`, zawierajacy:
- user goal,
- screen inventory,
- happy path,
- non-happy path,
- widoczne CTA,
- stany empty/loading/error/success/blocked,
- reguly copy,
- rozdzial operator vs audit,
- trace do OP i guardow.

Brak tego artefaktu blokuje gate dla nowego entrypointu lub zmiany UX o krytycznym impact.

## 4. CRUD dla artefaktow UX

Create:
- nowe entrypointy i nowe krytyczne ekrany musza tworzyc nowy artefakt `.ai/ux/*`.

Read:
- operator musi miec dostep do task-first view.
- audit/debug moze czytac trace i event history, ale nie jako domyslny widok.

Update:
- zmiana flow, copy, walidacji lub CTA wymaga update artefaktu UX i review package.

Remove:
- hard delete artefaktu UX po uruchomionym runtime jest zabronione.
- deprecacja wymaga replacement map i audytowalnej decyzji.

## 5. Wymagania walidacyjne

Minimalny zestaw testow i dowodow:
- happy path bez znajomosci pojec OP,
- guard visibility tests,
- inline validation tests,
- loading/success/error/blocked tests,
- keyboard/focus tests dla krytycznych formularzy,
- audit/debug separation tests,
- screen-to-transition traceability.

## 6. Zrodla praktyk

Punkty odniesienia:
- Apple Human Interface Guidelines: clarity, feedback, hierarchy, system status.
- GOV.UK Design System: czytelne bledy formularzy i actionable copy.
- W3C WCAG 2.2: labels, error identification, status messages.
- Material Design: state handling, empty/error/loading patterns.
- Nielsen Norman Group heuristics: visibility of system status, progressive disclosure, error prevention.

Linki:
- https://developer.apple.com/design/human-interface-guidelines/
- https://design-system.service.gov.uk/components/error-message/
- https://www.w3.org/WAI/WCAG22/Understanding/labels-or-instructions.html
- https://www.w3.org/WAI/WCAG22/Understanding/error-identification.html
- https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html
- https://m3.material.io/
- https://www.nngroup.com/articles/ten-usability-heuristics/
