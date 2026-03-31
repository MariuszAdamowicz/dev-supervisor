## Checklista startowa projektu (OP-aligned)

- repo utworzone
- wybrany storage profile (file-ai lub sqlbase)
- baseline produktu utworzony: overview, constraints, glossary
- Requirement OP utworzone i powiazane z baseline
- Constraint OP utworzone i sklasyfikowane
- DecisionRecord OP utworzony dla kluczowych decyzji startowych
- ActorRolePermission OP zdefiniowany
- Product Gate zatwierdzony przez operatora
- .ai lub SQLBase zainicjalizowane zgodnie ze storage
- scripts build/test/lint gotowe
- potwierdzone realne wykonanie testow (testsCount > 0)

## Checklista dodania feature

- idea dodana i scoped do feature(s)
- Feature OP utworzony
- Requirement OP powiazane z Feature OP
- Dependency OP zidentyfikowane i ocenione
- Risk OP zidentyfikowane i ocenione
- feature capsule utworzony (prd, bdd, tasks, notes, traceability)
- UX contract utworzony
- Scenario OP utworzone i powiazane z testami
- PromptTask utworzone zgodnie z trigger rules
- review package przygotowany
- GateDecision zapisany
- quality sygnaly zebrane (build/test/lint)
- QualitySignal OP oceniony (pass/fail)
- integration hardening wykonany
- brak krytycznych otwartych PromptTask

## Checklista zmiany feature

- Feature OP w stanie wymagajacym zmiany
- Requirement/Constraint/DecisionRecord zaktualizowane jesli dotkniete
- bdd i testy zaktualizowane
- traceability zaktualizowane
- dependency/risk status zaktualizowany
- review package + GateDecision zapisane
- quality sygnaly ponownie ocenione
- exceptiony i timeouty obsluzone (retry lub compensation)
- ProcessEvent zapisany dla kluczowych przejsc

## Checklista release handoff

- Feature OP: stabilized lub release-ready
- Release OP utworzony (candidate)
- GateDecision approve dla release
- QualitySignal pass w wymaganym oknie
- Deployment OP przygotowany
- plan rollback i compensation gotowy

## Checklista UX warstwy procesu

- stany procesu zdefiniowane
- przejscia zdefiniowane
- reguly widocznosci zdefiniowane
- reguly dostepnosci akcji zdefiniowane
- invalidation downstream zdefiniowane
- testy visibility i state transitions przygotowane

## Checklista audytu OP

- kazde krytyczne przejscie ma event + guard + actor
- kazda decyzja gate ma ProcessEvent
- brak osieroconych OP
- brak niespojnych stanow miedzy OP nadrzednym i podrzednym
