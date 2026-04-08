## Decision Envelope (gate package)

Cel:
- dostarczyc operatorowi pelny, jawny obszar decyzji gate,
- ograniczyc decyzje "w ciemno",
- ujednolicic evidence dla approve/request_changes/defer/reject.

## Minimalny kontrakt envelope

Kazdy gate-required transition MUSI miec pakiet:
- `transition_ref` (`OP.from -> OP.to` albo `control.status change`)
- `current_state`
- `target_state`
- `preconditions` (guardy + ich status pass/fail)
- `scope` (co zmienia transition)
- `change_set` (diff/artifacts/files/op updates)
- `validation` (build/test/lint + QualityEvidenceRecord)
- `traceability` (mapowanie Requirement/Scenario/Test gdy dotyczy)
- `risks` (otwarte ryzyka, dependencies, exceptions)
- `rollback_or_rework_plan`
- `decision_options` (`approve | request_changes | defer | reject`)
- `decision_effects` (co stanie sie po kazdej opcji)
- `required_actor` (kto moze podjac decyzje)
- `audit_refs` (ProcessEventRecord/GateDecisionRecord IDs)

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
2. `Project.active -> Project.archived`
3. `Idea.scoped -> Idea.converted`
4. `Idea.scoped -> Idea.dropped`
5. `Requirement.clarified -> Requirement.approved`
6. `Requirement.linked -> Requirement.deprecated`
7. `Constraint.validated -> Constraint.enforced`
8. `Constraint.revised -> Constraint.retired`
9. `DecisionRecord.reviewed -> DecisionRecord.approved`
10. `DecisionRecord.approved -> DecisionRecord.superseded`
11. `Scenario.reviewed -> Scenario.approved`
12. `Feature.implemented -> Feature.stabilized`
13. `GlossaryEntry.proposed -> GlossaryEntry.approved`
14. `GlossaryEntry.approved -> GlossaryEntry.deprecated`
15. `UIComponent.implemented -> UIComponent.verified`
16. `UIComponent.verified -> UIComponent.deprecated`
17. `UIScreen.mapped -> UIScreen.verified`
18. `UIScreen.verified -> UIScreen.deprecated`
19. `PromptTask.executed -> PromptTask.validated`
20. `AccessGrant.defined -> AccessGrant.active`
21. `AccessGrant.active -> AccessGrant.revised`
22. `AccessGrant.revised -> AccessGrant.revoked`
23. `RiskEntry.assessed -> RiskEntry.mitigated`
24. `RiskEntry.assessed -> RiskEntry.accepted`
25. `RiskEntry.assessed -> RiskEntry.escalated`
26. `RiskEntry.escalated -> RiskEntry.closed`
27. `Repository.remote-attached -> Repository.policy-aligned`
28. `ChangeSet.staged -> ChangeSet.validated`
29. `VerificationPolicy.reviewed -> VerificationPolicy.approved`
30. `DataSchema.reviewed -> DataSchema.approved`
31. `MigrationAction.reviewed -> MigrationAction.approved`
32. `MigrationAction.applied -> MigrationAction.rolled-back`
33. `EnvironmentTarget.validated -> EnvironmentTarget.ready`
34. `Scenario.passing -> Scenario.obsolete`
35. `ExceptionCase.classified -> ExceptionCase.handled`
36. `ReleaseBundle.candidate -> ReleaseBundle.approved`
37. `DeploymentRun.failed -> RollbackAction.completed` (gate zamkniecia recovery)
38. `Feature.released -> Feature.done`
39. `ReleaseBundle.published -> ReleaseBundle.closed`

## Zasada wykonania

- Brak kompletnego Decision Envelope blokuje wyswietlenie przyciskow gate w UI.
- Operator podejmuje decyzje dopiero po otrzymaniu envelope.
- Kazda decyzja gate MUSI wskazywac `audit_refs` z envelope.

## Zasada negatywna

Nie wolno:
- prosic operatora o gate bez jawnego `change_set`,
- prosic operatora o gate bez jawnego wyniku walidacji,
- ukrywac skutkow decyzji `defer` i `reject`.
