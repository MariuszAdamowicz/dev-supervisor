# UX Validation (OP-aligned)

## Kryteria jakosci UX
- Operator bez znajomosci kodu przechodzi flow przez current_op -> next_transition.
- UI nie pokazuje akcji bez spelnionych guardow.
- Kazda blokada ma reason pochodzacy z OP.
- Kazda decyzja operatora jest audytowalna (ProcessEvent).

## Testy UX (obowiazkowe)
1. OP state reflection tests (UI pokazuje prawidlowy current_state)
2. Guard visibility tests (CTA aktywne tylko przy spelnionych guardach)
3. Gate decision tests (approve/request_changes/defer/reject)
4. Invalidation propagation tests (upstream -> downstream)
5. Permission tests (ActorRolePermission)
6. Exception/timeout handling tests
7. Audit continuity tests (ProcessEvent completeness)

## Definition of Done (UX)
- Kazdy nowy krok ma jawne mapowanie do OP transition.
- Widocznosc i CTA wynikaja z guardow OP.
- Testy UX pokrywaja stany, blokady, invalidation i audit.
