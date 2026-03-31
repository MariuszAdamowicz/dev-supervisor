## Object Catalog (OP: Obiekt Procesu)

Cel: warstwa OP jest kanonicznym modelem procesu. Kazda zmiana w projekcie musi byc opisana jako operacja na OP.

## Kontrakt wspolny (wymagany dla kazdego OP)

Kazdy OP ma pola:
- op_id
- op_type
- op_version
- state
- owner
- created_at
- updated_at
- links (relacje do innych OP)
- tags

Kazdy OP ma tez:
- CRUD policy
- state machine
- eventy wejsciowe i wyjsciowe
- guard conditions
- invariants
- SLA/deadline (gdy dotyczy)
- retry/idempotency policy (gdy dotyczy)
- audit trail

## Typy OP (kanoniczne)

### 1. Project
- Rola: instancja projektu zarzadzana przez DS.
- Kluczowe pola: name, description, selected_profiles, storage_mode.

### 2. Requirement
- Rola: wymaganie produktowe/funkcjonalne.
- Kluczowe pola: requirement_id, source, priority, acceptance_criteria.

### 3. Constraint
- Rola: ograniczenie techniczne, prawne, operacyjne lub architektoniczne.
- Kluczowe pola: constraint_id, class, rationale, enforce_level.

### 4. DecisionRecord
- Rola: decyzja architektoniczna/produktowa (ADR).
- Kluczowe pola: decision_id, options_considered, selected_option, consequence.

### 5. Idea
- Rola: luzna koncepcja biznesowa.
- Kluczowe pola: idea_id, title, description.

### 6. Feature
- Rola: jednostka implementacyjna wynikajaca z idei.
- Kluczowe pola: feature_id, scope, deferred_items.

### 7. Scenario
- Rola: scenariusz BDD i slad testowy.
- Kluczowe pola: scenario_id, feature_id, test_links.

### 8. Term
- Rola: pojecie domenowe i UX.
- Kluczowe pola: term, definition, status, source, aliases.

### 9. UIComponent
- Rola: komponent interfejsu.
- Kluczowe pola: component_id, purpose, visibility_rules, gate_rules.

### 10. UIScreen
- Rola: ekran/widok agregujacy komponenty.
- Kluczowe pola: screen_id, state_binding, components.

### 11. PromptTask
- Rola: zadanie promptowe uruchamiane przez operatora/AI.
- Kluczowe pola: task_id, task_type, context_set, target_op.

### 12. GateDecision
- Rola: jawna decyzja operatora po review package.
- Kluczowe pola: gate_type, decision, reason, timestamp.

### 13. ActorRolePermission
- Rola: ownership, role i uprawnienia do operacji.
- Kluczowe pola: actor_id, role, allowed_actions, scope.

### 14. Dependency
- Rola: zaleznosc miedzy OP lub zewnetrznym elementem.
- Kluczowe pola: dependency_id, source_op, target_op, criticality.

### 15. Risk
- Rola: ryzyko produktu/procesu.
- Kluczowe pola: risk_id, probability, impact, mitigation_plan.

### 16. Release
- Rola: pakiet zmian gotowy do wydania.
- Kluczowe pola: release_id, included_features, release_gate_status.

### 17. Deployment
- Rola: wykonanie wdrozenia.
- Kluczowe pola: deployment_id, environment, result, rollback_ref.

### 18. Rollback
- Rola: cofniecie wdrozenia.
- Kluczowe pola: rollback_id, trigger_reason, recovered_state.

### 19. QualitySignal
- Rola: sygnal jakosci/reliability (SLO, error budget, quality gates).
- Kluczowe pola: signal_id, signal_type, value, threshold, window.

### 20. Exception
- Rola: blad procesu lub biznesowy exception case.
- Kluczowe pola: exception_id, class, severity, compensation_required.

### 21. Timeout
- Rola: przekroczenie SLA/deadline.
- Kluczowe pola: timeout_id, related_op, deadline, escalation_policy.

### 22. Compensation
- Rola: akcja kompensacyjna po bledzie.
- Kluczowe pola: compensation_id, target_op, action_plan, status.

### 23. ProcessEvent
- Rola: niezmienny event log (audit, odtwarzanie procesu).
- Kluczowe pola: event_id, op_id, event_type, payload_hash, actor, ts.

## Minimalny graf relacji
- Project -> Requirement -> Feature -> Scenario -> Testy
- Project -> Constraint -> DecisionRecord -> Feature
- Feature -> Term -> UIComponent -> UIScreen
- Feature -> PromptTask -> GateDecision
- Feature -> Dependency
- Feature -> Risk
- Feature -> Release -> Deployment -> Rollback
- QualitySignal -> GateDecision
- Exception/Timeout -> Compensation
- Wszystko emituje ProcessEvent

## Invariants warstwy OP
- Brak osieroconych OP (kazdy OP poza Project ma parent linkage).
- Kazdy state transition ma event + guard + actor.
- Kazda decyzja gate ma audytowalny ProcessEvent.
- Kazdy krytyczny blad ma policy: retry albo compensation.
- Zamkniecie Feature wymaga braku krytycznych otwartych PromptTask.
