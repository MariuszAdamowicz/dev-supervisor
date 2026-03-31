# Visibility Rules (OP-aligned)

## Zasada nadrzedna
Widocznosc i dostepnosc sa wyliczane z OP:
- current_state
- guards
- pending PromptTask
- latest GateDecision

## Reguly widocznosci
1. Pokazuj tylko aktywny krok wynikajacy z current_op/current_state.
2. Kroki przyszle pokazuj jako zablokowane (read-only), bez CTA wykonania.
3. Kroki zakonczone pokazuj jako skrot + audyt.
4. Nie pokazuj CTA dla akcji bez spelnionych guardow.

## Reguly dostepnosci akcji
Akcja jest aktywna tylko gdy:
- target OP istnieje,
- przejscie jest dozwolone przez state machine,
- wszystkie guardy sa spelnione,
- actor ma uprawnienia (ActorRolePermission).

## Komunikaty blokad
Dla kazdej blokady UI zwraca reason pochodzacy z OP:
- missing target OP
- guard not satisfied
- permission denied
- pending critical PromptTask
- gate decision required
- invalidated by upstream transition
