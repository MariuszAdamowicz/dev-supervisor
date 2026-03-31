## Checklista entrypoint OP

- wybrany target OP (entrypoint)
- odczytany current_state
- wyznaczony next_transition
- sprawdzone guardy transition
- okreslone pending PromptTask
- okreslony wymagany GateDecision

## Checklista wykonania transition

- wykonany prompt/akcja dla transition
- przygotowany review package (diff + mapowanie + build/test/lint)
- decyzja GateDecision zapisana
- QualitySignal zaktualizowany
- ProcessEvent zapisany
- stan OP po transition zaktualizowany

## Checklista feature runtime

- Feature OP utworzony i powiazany z Idea
- Requirement/Constraint/DecisionRecord powiazane z Feature
- Scenario OP powiazane z testami
- Dependency i Risk ocenione
- brak krytycznych otwartych PromptTask

## Checklista release runtime

- Release OP candidate utworzony
- GateDecision approve dla release
- QualitySignal pass
- Deployment OP przygotowany
- rollback/compensation plan gotowy

## Checklista audytu OP

- kazde krytyczne przejscie ma event + guard + actor
- kazda decyzja gate ma ProcessEvent
- brak osieroconych OP
- brak niespojnych stanow OP nadrzedny/podrzedny
