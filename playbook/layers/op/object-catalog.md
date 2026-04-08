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

Kontrakt runtime dla CRUD i grafu:
- `playbook/workflow/op-crud-contract.md`

Semantyka operacyjna i stosowalnosc OP:
- `playbook/layers/op/operational-semantics.md`

## Klasy OP i recordow systemowych

- `work-object`: obiekt pracy projektowej lub produktowej.
- `control-object`: obiekt sterujacy polityka, jakoscia, uprawnieniami albo decyzja.
- `execution-object`: obiekt wykonania pracy, wdrozenia albo ograniczonego pakietu zmian.
- `environment-object`: obiekt opisujacy repo, schemat danych lub srodowisko uruchomieniowe.
- `recovery-control`: mutowalny runtime handle undo/compensation; nie jest OP.
- `scheduler-control`: mutowalny runtime handle czasu i retry; nie jest OP.
- `system-record`: append-only record audytowy lub dowodowy; nie jest OP.

## Reguly stosowalnosci

- `always`: wymagany dla kazdego projektu.
- `interactive-ui`: tylko gdy produkt ma interaktywny interfejs.
- `version-controlled`: tylko gdy projekt jest rozwijany w VCS.
- `formal-validation`: tylko gdy projekt utrzymuje jawne quality lanes i gate.
- `persistent-data`: tylko gdy projekt utrzymuje trwale dane ze schematem.
- `deployable-runtime`: tylko gdy projekt ma srodowiska uruchomieniowe lub wdrozenia.

## Typy OP (kanoniczne)

### 1. Project
- Rola: instancja projektu zarzadzana przez DS.
- Klasa: `work-object`
- Stosowalnosc: `always`
- Kluczowe pola: name, description, selected_profiles, storage_mode.

### 2. Requirement
- Rola: wymaganie produktowe/funkcjonalne.
- Klasa: `work-object`
- Stosowalnosc: `always`
- Kluczowe pola: requirement_id, source, priority, acceptance_criteria.

### 3. Constraint
- Rola: ograniczenie techniczne, prawne, operacyjne lub architektoniczne.
- Klasa: `control-object`
- Stosowalnosc: `always`
- Kluczowe pola: constraint_id, class, rationale, enforce_level.

### 4. DecisionRecord
- Rola: decyzja architektoniczna/produktowa (ADR).
- Klasa: `control-object`
- Stosowalnosc: `always`
- Kluczowe pola: decision_id, options_considered, selected_option, consequence.

### 5. Idea
- Rola: luzna koncepcja biznesowa.
- Klasa: `work-object`
- Stosowalnosc: `always`
- Kluczowe pola: idea_id, title, description.

### 6. Feature
- Rola: jednostka implementacyjna wynikajaca z idei.
- Klasa: `work-object`
- Stosowalnosc: `always`
- Kluczowe pola: feature_id, scope, deferred_items.

### 7. Scenario
- Rola: scenariusz BDD i slad testowy.
- Klasa: `work-object`
- Stosowalnosc: `formal-validation`
- Kluczowe pola: scenario_id, feature_id, test_links.

### 8. Term
- Rola: pojecie domenowe i UX.
- Klasa: `work-object`
- Stosowalnosc: `always`
- Kluczowe pola: term, definition, status, source, aliases.

### 9. UIComponent
- Rola: komponent interfejsu.
- Klasa: `work-object`
- Stosowalnosc: `interactive-ui`
- Kluczowe pola: component_id, purpose, visibility_rules, gate_rules.

### 10. UIScreen
- Rola: ekran/widok agregujacy komponenty.
- Klasa: `work-object`
- Stosowalnosc: `interactive-ui`
- Kluczowe pola: screen_id, state_binding, components.

### 11. PromptTask
- Rola: zadanie promptowe uruchamiane przez operatora/AI.
- Klasa: `execution-object`
- Stosowalnosc: `always`
- Kluczowe pola: task_id, task_type, context_set, target_op.

### 12. ActorRolePermission
- Rola: ownership, role i uprawnienia do operacji.
- Klasa: `control-object`
- Stosowalnosc: `always`
- Kluczowe pola: actor_id, role, allowed_actions, scope.

### 13. UseCase
- Rola: przypadek uzycia opisujacy zachowanie aplikacyjne niezalezne od frameworka.
- Klasa: `work-object`
- Stosowalnosc: `always` dla zachowania biznesowego
- Kluczowe pola: use_case_id, actor, goal, input_dto, output_dto, business_rules_refs.

### 14. PortContract
- Rola: kontrakt granicy (wejscie/wyjscie) miedzy rdzeniem a adapterem.
- Klasa: `work-object`
- Stosowalnosc: `always` przy granicy rdzen <-> zewnetrze
- Kluczowe pola: port_id, direction(inbound|outbound), contract_schema_ref, dto_set, owner_use_case.

### 15. Component
- Rola: komponent/modul architektoniczny do kontroli spojnosci i zaleznosci.
- Klasa: `work-object`
- Stosowalnosc: `always`
- Kluczowe pola: component_id, responsibility, stability_index, abstraction_level, dependencies.

### 16. Risk
- Rola: ryzyko produktu/procesu.
- Klasa: `control-object`
- Stosowalnosc: `formal-validation`
- Kluczowe pola: risk_id, probability, impact, mitigation_plan.

### 17. Release
- Rola: pakiet zmian gotowy do wydania.
- Klasa: `execution-object`
- Stosowalnosc: `formal-validation`
- Kluczowe pola: release_id, included_features, release_gate_status.

### 18. Deployment
- Rola: wykonanie wdrozenia.
- Klasa: `execution-object`
- Stosowalnosc: `deployable-runtime`
- Kluczowe pola: deployment_id, environment, result, rollback_ref.

### 19. Rollback
- Rola: cofniecie wdrozenia.
- Klasa: `execution-object`
- Stosowalnosc: `deployable-runtime`
- Kluczowe pola: rollback_id, trigger_reason, recovered_state.

### 20. Exception
- Rola: blad procesu lub biznesowy exception case.
- Klasa: `execution-object`
- Stosowalnosc: `always`
- Kluczowe pola: exception_id, class, severity, compensation_required.

### 21. Repository
- Rola: stan repozytorium projektu i polityk VCS.
- Klasa: `environment-object`
- Stosowalnosc: `version-controlled`
- Kluczowe pola: repo_id, vcs, local_root, remote_origin, default_branch, branch_policy, cleanliness.

### 22. ChangeSet
- Rola: ograniczony pakiet zmian powiazany z OP, plikami i commitami.
- Klasa: `execution-object`
- Stosowalnosc: `version-controlled`
- Kluczowe pola: changeset_id, repository_ref, branch_ref, file_scope, op_refs, commit_refs, validation_refs.

### 23. VerificationPlan
- Rola: plan warstw testow i evidence dla Feature, ChangeSet lub Release.
- Klasa: `control-object`
- Stosowalnosc: `formal-validation`
- Kluczowe pola: verification_id, target_scope, required_lanes, pass_criteria, evidence_rules.

### 24. DataSchema
- Rola: kanoniczny kontrakt modelu danych i kompatybilnosci.
- Klasa: `environment-object`
- Stosowalnosc: `persistent-data`
- Kluczowe pola: schema_id, storage_engine, compatibility_policy, owned_structures, migration_refs.

### 25. Migration
- Rola: wykonanie zmiany schematu lub danych z jawna gotowoscia rollback.
- Klasa: `execution-object`
- Stosowalnosc: `persistent-data`
- Kluczowe pola: migration_id, schema_ref, direction, compatibility_window, execution_lane, rollback_ref.

### 26. RuntimeEnvironment
- Rola: srodowisko lokalne, CI, staging lub prod wraz z capability i config policy.
- Klasa: `environment-object`
- Stosowalnosc: `deployable-runtime`
- Kluczowe pola: environment_id, class, capabilities, secret_policy, deploy_constraints, release_refs.

## Graph Relations (nie sa OP, ale sa kanoniczne i mutowalne)

### DependencyRelation
- Rola: mutowalna krawedz grafu opisujaca zaleznosc source -> target/external_ref.
- Klasa: `graph-relation`
- Stosowalnosc: `always`
- Kluczowe pola: relation_id, source_ref, target_ref|external_ref, status, scope, criticality, blocking_scope, waiver_ref.

## Scheduler Controls (nie sa OP, ale sa kanoniczne i mutowalne)

### SchedulerTimer
- Rola: runtime handle harmonogramu dla defer, retry i SLA/deadline.
- Klasa: `scheduler-control`
- Stosowalnosc: `always`
- Kluczowe pola: timer_id, target_ref, status, due_at, reason, fire_policy, retry_budget.

## Recovery Controls (nie sa OP, ale sa kanoniczne i mutowalne)

### CompensationAction
- Rola: mutowalny plan undo/cleanup po awarii, rollbacku albo nieudanym kroku z side effect.
- Klasa: `recovery-control`
- Stosowalnosc: `always` gdy failure_policy wymaga recovery
- Kluczowe pola: recovery_id, target_ref, source_exception_ref|source_deployment_ref, status, action_plan, retry_budget, reason.

## System Records (nie sa OP, ale sa kanoniczne i wymagane)

### GateDecisionRecord
- Rola: jawna decyzja operatora po review package.
- Klasa: `system-record`
- Stosowalnosc: `always`
- Kluczowe pola: gate_type, decision, reason, timestamp, decision_effects.

### ProcessEventRecord
- Rola: niezmienny event log (audit, odtwarzanie procesu).
- Klasa: `system-record`
- Stosowalnosc: `always`
- Kluczowe pola: event_id, subject_ref, event_type, payload_hash, actor, ts.

### QualityEvidenceRecord
- Rola: wynik konkretnej lane walidacyjnej lub quality check.
- Klasa: `system-record`
- Stosowalnosc: `formal-validation`
- Kluczowe pola: signal_type, value, threshold, subject_ref, lane_ref, provenance_class.

## Minimalny graf relacji
- Project -> Repository -> ChangeSet
- Project -> VerificationPlan
- Project -> Requirement -> Feature -> Scenario -> Testy
- Project -> Constraint -> DecisionRecord -> Feature
- Feature -> UseCase -> PortContract
- Feature -> Term -> UIComponent -> UIScreen
- Feature -> Component
- Feature -> PromptTask
- Feature -> ChangeSet
- Feature -> VerificationPlan
- Feature -(DependencyRelation)-> external_ref|Component|RuntimeEnvironment
- Feature -> Risk
- Feature -> DataSchema -> Migration
- Feature -> Release -> Deployment -> Rollback
- Release -> RuntimeEnvironment
- Exception -(CompensationAction)-> target_ref
- Rollback -(CompensationAction)-> target_ref
- target_ref -(SchedulerTimer)-> timeout.fired
- Wszystko emituje ProcessEventRecord i moze miec GateDecisionRecord / QualityEvidenceRecord

## Invariants warstwy OP
- Brak osieroconych OP (kazdy OP poza Project ma parent linkage).
- Kazdy state transition ma event + guard + actor.
- Kazda decyzja gate ma GateDecisionRecord i audytowalny ProcessEventRecord.
- Kazdy krytyczny blad ma policy: retry albo compensation.
- Zamkniecie Feature wymaga braku krytycznych otwartych PromptTask.
- Repository i ChangeSet musza zachowac traceability do powiazanych Feature/Requirement/Scenario.
- VerificationPlan musi byc przypisany do Feature, ChangeSet albo Release wymagajacego formalnej walidacji.
- DataSchema i Migration sa wymagane, gdy zmiana obejmuje trwale dane lub niekompatybilna ewolucje schematu.
- Deployment i Release nie moga byc wykonane bez RuntimeEnvironment w stanie co najmniej `ready`.
- DependencyRelation z `status=blocked` musi byc widoczna w reverse lookup i projection operatora.
- Exception z `compensation_required=true` musi miec jawny `CompensationAction` zanim zamknie downstream scope.
- SchedulerTimer musi byc consumowany albo anulowany po domknieciu target scope.
- CompensationAction musi byc domkniety jako `completed` albo `cancelled` z audytowalnym reason.
- UseCase i PortContract musza byc utrzymane bez zaleznosci od frameworkowych typow.
- Component graph nie moze zawierac cykli.
- Hard delete OP po pojawieniu sie ProcessEventRecord jest zabronione.
- Remove semantyczny wymaga tombstone metadata i zachowania link integrity.
