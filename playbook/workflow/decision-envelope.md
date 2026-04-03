## Decision Envelope (gate package)

Cel:
- dostarczyc operatorowi pelny, jawny obszar decyzji gate,
- ograniczyc decyzje "w ciemno",
- ujednolicic evidence dla approve/request_changes/defer/reject.

## Minimalny kontrakt envelope

Kazdy gate-required transition MUSI miec pakiet:
- `transition_ref` (`OP.from -> OP.to`)
- `current_state`
- `target_state`
- `preconditions` (guardy + ich status pass/fail)
- `scope` (co zmienia transition)
- `change_set` (diff/artifacts/files/op updates)
- `validation` (build/test/lint + QualitySignal)
- `traceability` (mapowanie Requirement/Scenario/Test gdy dotyczy)
- `risks` (otwarte ryzyka, dependencies, exceptions)
- `rollback_or_rework_plan`
- `decision_options` (`approve | request_changes | defer | reject`)
- `decision_effects` (co stanie sie po kazdej opcji)
- `required_actor` (kto moze podjac decyzje)
- `audit_refs` (ProcessEvent/GateDecision IDs)

## Gate-required transitions (baseline)

Za gate-required uznajemy transition, ktore:
- maja `decide_gate` w `action_plan`,
- oraz `operator-ui` jako narzedzie decyzji.

Lista bazowa:
1. `Project.configured -> Project.baseline-approved`
2. `Idea.scoped -> Idea.converted`
3. `Idea.scoped -> Idea.dropped`
4. `Feature.implemented -> Feature.stabilized`
5. `Term.proposed -> Term.approved`
6. `UIComponent.implemented -> UIComponent.verified`
7. `UIScreen.mapped -> UIScreen.verified`
8. `Exception.detected -> Exception.handled`
9. `Release.candidate -> Release.approved`
10. `Deployment.failed -> Rollback.succeeded` (gate zamkniecia rollback)

## Zasada wykonania

- Brak kompletnego Decision Envelope blokuje wyswietlenie przyciskow gate w UI.
- Operator podejmuje decyzje dopiero po otrzymaniu envelope.
- Kazda decyzja gate MUSI wskazywac `audit_refs` z envelope.

## Zasada negatywna

Nie wolno:
- prosic operatora o gate bez jawnego `change_set`,
- prosic operatora o gate bez jawnego wyniku walidacji,
- ukrywac skutkow decyzji `defer` i `reject`.
