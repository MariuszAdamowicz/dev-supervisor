# Interaction Patterns (OP-aligned)

## Pattern 1: Next OP Action
UI pokazuje jedna glowna akcje wynikajaca z next_transition dla current_op.

## Pattern 1a: Task Framing
Primary copy opisuje zadanie operatora i oczekiwany efekt dla uzytkownika/systemu.

## Pattern 2: Transition Card
Kazdy krok ma karte przejscia:
- target OP
- from_state -> to_state
- required guards
- status guardow
- akcje operatora

## Pattern 3: Review Before GateDecisionRecord
Operator podejmuje GateDecisionRecord po review package:
- diff
- mapowanie do scenariuszy
- quality signals
- event history

## Pattern 3a: Audit Drawer
Szczegoly runtime i audit sa widoczne dopiero po wejsciu w inspection/details mode.

## Pattern 4: Invalidation Preview
Przy zmianie upstream UI pokazuje dokladne downstream OP, ktore beda invalidated.

## Pattern 5: Deterministic Audit Trail
Kazda akcja operatora zapisuje ProcessEventRecord:
- actor
- timestamp
- event_type
- target_op
- payload fingerprint

## Pattern 6: Exception First
Dla ExceptionCase i timeout scheduler'a UI pokazuje najpierw:
- severity
- impact
- failure policy (retry/compensation/escalation)

## Pattern 7: Inline Recovery
Blad formularza, authz deny, gate defer i partial success musza miec jednoznaczna kolejna akcje.
