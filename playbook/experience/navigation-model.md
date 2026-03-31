# Navigation Model (OP-aligned)

## Model nawigacji
- Lewy panel: timeline OP transitions dla aktywnego scope.
- Srodek: aktywny krok (current_op + current_state + next_transition).
- Prawy panel: kontekst, artefakty i audit (ProcessEvent, GateDecision, QualitySignal).

## Reguly nawigacji
- Domyslnie otwarty jest tylko aktywny krok.
- Przejscie dalej jest mozliwe tylko po spelnieniu guardow OP.
- Wczesniejsze kroki sa dostepne read-only.
- Edycja kroku upstream pokazuje liste downstream invalidations z trigger rules.

## Widoki minimalne
- Project Setup View (Project/Requirement/Constraint/DecisionRecord)
- Idea & Feature View (Idea/Feature/Scenario)
- UX View (Term/UIComponent/UIScreen)
- Delivery View (Release/Deployment/Rollback)
- Audit View (ProcessEvent/GateDecision/QualitySignal/Exception)
