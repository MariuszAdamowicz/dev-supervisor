# UI State Machine (OP-aligned)

## Cel
UI nie definiuje lokalnej semantyki procesu.
UI odzwierciedla stany OP z layers/op/state-machines.md.

## Zasada mapowania
- Jeden aktywny krok UI = jeden aktywny target OP + oczekiwane przejscie stanu.
- Przejscia UI sa skutkiem eventow OP, nie oddzielna logika.

## Kanoniczne zrodla stanu
- layers/op/object-catalog.md
- layers/op/state-machines.md
- layers/op/trigger-rules.md

## Minimalny model widoku stanu
- current_op: typ OP aktualnie obslugiwany
- current_state: aktualny stan OP
- next_transition: oczekiwane przejscie
- blocking_guards: lista guardow blokujacych przejscie
- pending_tasks: otwarte PromptTask dla current_op
- latest_gate: ostatnia GateDecision dla current_op

## Regula invalidation
Zmiana upstream OP powoduje invalidation downstream zgodnie z trigger rules OP.
UI pokazuje invalidation jako efekt OP, nie jako lokalna regule.

## Regula spojnosc
Jesli UI i OP sa niespojne, prawda procesu jest po stronie OP.
