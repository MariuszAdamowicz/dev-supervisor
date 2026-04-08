# Navigation Model (OP-aligned)

## Model nawigacji
- Lewy panel: timeline OP transitions dla aktywnego scope.
- Srodek: aktywny krok (current_op + current_state + next_transition).
- Prawy panel: kontekst, artefakty i audit (ProcessEventRecord, GateDecisionRecord, QualityEvidenceRecord).

## Reguly nawigacji
- Domyslnie otwarty jest tylko aktywny krok.
- Przejscie dalej jest mozliwe tylko po spelnieniu guardow OP.
- Wczesniejsze kroki sa dostepne read-only.
- Edycja kroku upstream pokazuje liste downstream invalidations z trigger rules.

## Widoki minimalne
- Project Setup View (Project/Repository/Requirement/Constraint/DecisionRecord/VerificationPolicy)
- Idea & Feature View (Idea/Feature/Scenario/ChangeSet)
- UX View (GlossaryEntry/UIComponent/UIScreen)
- Data & Environment View (DataSchema/Migration/EnvironmentTarget)
- Delivery View (ReleaseBundle/DeploymentRun/Recovery Controls)
- Audit View (ProcessEventRecord/GateDecisionRecord/QualityEvidenceRecord/ExceptionCase)
