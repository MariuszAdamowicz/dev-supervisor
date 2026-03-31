# Interaction Patterns (OP-aligned)

## Pattern 1: Next OP Action
UI pokazuje jedna glowna akcje wynikajaca z next_transition dla current_op.

## Pattern 2: Transition Card
Kazdy krok ma karte przejscia:
- target OP
- from_state -> to_state
- required guards
- status guardow
- akcje operatora

## Pattern 3: Review Before GateDecision
Operator podejmuje GateDecision po review package:
- diff
- mapowanie do scenariuszy
- quality signals
- event history

## Pattern 4: Invalidation Preview
Przy zmianie upstream UI pokazuje dokladne downstream OP, ktore beda invalidated.

## Pattern 5: Deterministic Audit Trail
Kazda akcja operatora zapisuje ProcessEvent:
- actor
- timestamp
- event_type
- target_op
- payload fingerprint

## Pattern 6: Exception First
Dla Exception/Timeout UI pokazuje najpierw:
- severity
- impact
- failure policy (retry/compensation/escalation)
