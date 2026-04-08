# UX Validation (OP-aligned)

## Kryteria jakosci UX
- Operator bez znajomosci kodu przechodzi flow przez current_op -> next_transition.
- UI nie pokazuje akcji bez spelnionych guardow.
- Kazda blokada ma reason pochodzacy z OP.
- Kazda decyzja operatora jest audytowalna (ProcessEventRecord).
- Primary copy opisuje zadanie operatora, nie transition labels.
- Audit/debug details nie sa primary UI.
- Formularze krytyczne maja labels, inline validation i status feedback.
- Istnieja stany: empty, loading, success, blocked, error.

## Testy UX (obowiazkowe)
1. OP state reflection tests (UI pokazuje prawidlowy current_state)
2. Guard visibility tests (CTA aktywne tylko przy spelnionych guardach)
3. Gate decision tests (approve/request_changes/defer/reject)
4. Invalidation propagation tests (upstream -> downstream)
5. Permission tests (AccessGrant)
6. ExceptionCase/timeout handling tests
7. Audit continuity tests (ProcessEventRecord completeness)
8. Task-first copy tests (operator nie musi rozumiec OP labels)
9. Empty/loading/error/blocked state tests
10. Accessibility smoke tests (labels, keyboard, focus order, status messages)
11. Audit/debug separation tests

## Definition of Done (UX)
- Kazdy nowy krok ma jawne mapowanie do OP transition.
- Widocznosc i CTA wynikaja z guardow OP.
- Testy UX pokrywaja stany, blokady, invalidation i audit.
- Dla kazdego entrypointu istnieje `.ai/ux/<entrypoint>.md`.
- Operator UI i audit/debug UI maja osobne sekcje oraz osobne primary CTA.
