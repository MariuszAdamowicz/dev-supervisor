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

Classifier (deterministyczny):
1. Odczytaj `transition_ref` w `tooling/bindings.md`.
2. Jesli `action_plan` zawiera `decide_gate` ORAZ `tool_plan` zawiera `operator-ui` z akcja decyzyjna (approve/request_changes/defer/reject), ustaw `gate_required=true`.
3. W przeciwnym razie `gate_required=false`.
4. Dla `gate_required=true` brak Decision Envelope oznacza transition invalid.

Lista bazowa:
1. `Project.configured -> Project.baseline-approved`
2. `Idea.scoped -> Idea.converted`
3. `Idea.scoped -> Idea.dropped`
4. `Feature.implemented -> Feature.stabilized`
5. `Requirement.clarified -> Requirement.approved`
6. `Requirement.linked -> Requirement.deprecated`
7. `Constraint.validated -> Constraint.enforced`
8. `Constraint.revised -> Constraint.retired`
9. `Term.proposed -> Term.approved`
10. `UIComponent.implemented -> UIComponent.verified`
11. `UIScreen.mapped -> UIScreen.verified`
12. `Exception.detected -> Exception.handled`
13. `Release.candidate -> Release.approved`
14. `Deployment.failed -> Rollback.succeeded` (gate zamkniecia rollback)
15. `Project.active -> Project.archived`
16. `PromptTask.executed -> PromptTask.validated`
17. `Feature.released -> Feature.done`
18. `Release.published -> Release.closed`

## Zasada wykonania

- Brak kompletnego Decision Envelope blokuje wyswietlenie przyciskow gate w UI.
- Operator podejmuje decyzje dopiero po otrzymaniu envelope.
- Kazda decyzja gate MUSI wskazywac `audit_refs` z envelope.

## Zasada negatywna

Nie wolno:
- prosic operatora o gate bez jawnego `change_set`,
- prosic operatora o gate bez jawnego wyniku walidacji,
- ukrywac skutkow decyzji `defer` i `reject`.
