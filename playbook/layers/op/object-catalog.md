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
- `verification-control`: mutowalna polityka lane, evidence i gate dla scope formalnej walidacji; nie jest OP.
- `environment-control`: mutowalny target srodowiska i gotowosci runtime; nie jest OP.
- `authz-control`: mutowalny control autoryzacji i ownership; nie jest OP.
- `glossary-control`: mutowalny wpis slownika domenowego i UX; nie jest OP.
- `exception-control`: mutowalny przypadek bledu procesu lub runtime; nie jest OP.
- `risk-control`: mutowalny wpis rejestru ryzyka; nie jest OP.
- `delivery-control`: mutowalny runtime handle rollout/deploy; nie jest OP.
- `job-control`: mutowalny runtime handle dla pracy AI albo operatora; nie jest OP.
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

### 8. UIComponent
- Rola: komponent interfejsu.
- Klasa: `work-object`
- Stosowalnosc: `interactive-ui`
- Kluczowe pola: component_id, purpose, visibility_rules, gate_rules.

### 9. UIScreen
- Rola: ekran/widok agregujacy komponenty.
- Klasa: `work-object`
- Stosowalnosc: `interactive-ui`
- Kluczowe pola: screen_id, state_binding, components.

### 10. UseCase
- Rola: przypadek uzycia opisujacy zachowanie aplikacyjne niezalezne od frameworka.
- Klasa: `work-object`
- Stosowalnosc: `always` dla zachowania biznesowego
- Kluczowe pola: use_case_id, actor, goal, input_dto, output_dto, business_rules_refs.

### 11. PortContract
- Rola: kontrakt granicy (wejscie/wyjscie) miedzy rdzeniem a adapterem.
- Klasa: `work-object`
- Stosowalnosc: `always` przy granicy rdzen <-> zewnetrze
- Kluczowe pola: port_id, direction(inbound|outbound), contract_schema_ref, dto_set, owner_use_case.

### 12. Component
- Rola: komponent/modul architektoniczny do kontroli spojnosci i zaleznosci.
- Klasa: `work-object`
- Stosowalnosc: `always`
- Kluczowe pola: component_id, responsibility, stability_index, abstraction_level, dependencies.

### 13. Repository
- Rola: stan repozytorium projektu i polityk VCS.
- Klasa: `environment-object`
- Stosowalnosc: `version-controlled`
- Kluczowe pola: repo_id, vcs, local_root, remote_origin, default_branch, branch_policy, cleanliness.

### 14. ChangeSet
- Rola: ograniczony pakiet zmian powiazany z OP, plikami i commitami.
- Klasa: `execution-object`
- Stosowalnosc: `version-controlled`
- Kluczowe pola: changeset_id, repository_ref, branch_ref, file_scope, op_refs, commit_refs, validation_refs.

### 15. DataSchema
- Rola: kanoniczny kontrakt modelu danych i kompatybilnosci.
- Klasa: `environment-object`
- Stosowalnosc: `persistent-data`
- Kluczowe pola: schema_id, storage_engine, compatibility_policy, owned_structures, migration_refs.

### 16. Migration
- Rola: wykonanie zmiany schematu lub danych z jawna gotowoscia rollback.
- Klasa: `execution-object`
- Stosowalnosc: `persistent-data`
- Kluczowe pola: migration_id, schema_ref, direction, compatibility_window, execution_lane, rollback_action_ref.

## Delivery Controls (nie sa OP, ale sa kanoniczne i mutowalne)

### ReleaseBundle
- Rola: mutowalny bundle delivery grupujacy scope wydania, approval i publish state.
- Klasa: `delivery-control`
- Stosowalnosc: `formal-validation`
- Kluczowe pola: release_ref, delivery_scope_ref, status, included_features, gate_status, environment_ref.

### DeploymentRun
- Rola: mutowalne wykonanie rolloutu/wdrozenia dla ReleaseBundle i EnvironmentTarget.
- Klasa: `delivery-control`
- Stosowalnosc: `deployable-runtime`
- Kluczowe pola: run_id, release_ref, environment_ref, status, strategy, target_revision, rollback_action_ref.

## Job Controls (nie sa OP, ale sa kanoniczne i mutowalne)

### PromptTask
- Rola: mutowalne zadanie runtime uruchamiane przez ai-runner albo operator review.
- Klasa: `job-control`
- Stosowalnosc: `always`
- Kluczowe pola: task_id, task_type, context_set, target_ref, status, retry_budget, assignee_mode.

## Verification Controls (nie sa OP, ale sa kanoniczne i mutowalne)

### VerificationPolicy
- Rola: mutowalna polityka lane testowych, evidence i pass criteria dla Feature, ChangeSet albo ReleaseBundle.
- Klasa: `verification-control`
- Stosowalnosc: `formal-validation`
- Kluczowe pola: policy_id, target_scope, required_lanes, pass_criteria, evidence_rules, status.

## Authz Controls (nie sa OP, ale sa kanoniczne i mutowalne)

### AccessGrant
- Rola: mutowalny grant autoryzacji i ownership dla operatora albo roli w danym scope.
- Klasa: `authz-control`
- Stosowalnosc: `always`
- Kluczowe pola: grant_id, principal_ref, role_ref, scope_ref, allowed_actions, status.

## Glossary Controls (nie sa OP, ale sa kanoniczne i mutowalne)

### GlossaryEntry
- Rola: mutowalny wpis slownika domenowego dla copy, UX i scenariuszy.
- Klasa: `glossary-control`
- Stosowalnosc: `always`
- Kluczowe pola: entry_id, term, definition, status, aliases, replacement_ref, impacted_scope_refs.

## Risk Controls (nie sa OP, ale sa kanoniczne i mutowalne)

### RiskEntry
- Rola: mutowalny wpis rejestru ryzyka dla produktu, procesu albo delivery scope.
- Klasa: `risk-control`
- Stosowalnosc: `formal-validation`
- Kluczowe pola: risk_id, subject_ref, risk_class, probability, impact, criticality, status.

## Exception Controls (nie sa OP, ale sa kanoniczne i mutowalne)

### ExceptionCase
- Rola: mutowalny przypadek bledu procesu albo runtime wymagajacy klasyfikacji i resolution path.
- Klasa: `exception-control`
- Stosowalnosc: `always`
- Kluczowe pola: exception_id, subject_ref, exception_class, severity, status, compensation_required.

## Environment Controls (nie sa OP, ale sa kanoniczne i mutowalne)

### EnvironmentTarget
- Rola: mutowalny target srodowiska dla local/ci/stage/prod z jawna gotowoscia i capability.
- Klasa: `environment-control`
- Stosowalnosc: `deployable-runtime`
- Kluczowe pola: environment_id, environment_name, environment_class, capabilities, config_policy, status.

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

### RollbackAction
- Rola: mutowalne cofniecie deploymentu albo migracji po awarii runtime.
- Klasa: `recovery-control`
- Stosowalnosc: `deployable-runtime` albo `persistent-data`, gdy policy wymaga revert.
- Kluczowe pola: recovery_id, target_ref, source_deployment_ref|source_migration_ref, status, target_revision, retry_budget, reason.

### CompensationAction
- Rola: mutowalny plan undo/cleanup po awarii, rollbacku albo nieudanym kroku z side effect.
- Klasa: `recovery-control`
- Stosowalnosc: `always` gdy failure_policy wymaga recovery
- Kluczowe pola: recovery_id, target_ref, source_exception_case_ref|source_deployment_ref, status, action_plan, retry_budget, reason.

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
- Project -(AccessGrant)-> operator|scope
- Project -(VerificationPolicy)-> scope formal-validation
- Project -> Requirement -> Feature -> Scenario -> Testy
- Project -> Constraint -> DecisionRecord -> Feature
- Feature -> UseCase -> PortContract
- Feature -> GlossaryEntry -> UIComponent -> UIScreen
- Feature -> Component
- Feature -(PromptTask)-> runtime work item
- Feature -> ChangeSet
- Feature -(VerificationPolicy)-> lane scope
- Feature -(DependencyRelation)-> external_ref|Component|EnvironmentTarget
- Feature -(RiskEntry)-> scope
- Feature -> DataSchema -> Migration
- Feature -(ReleaseBundle)-> delivery scope
- ReleaseBundle -(DeploymentRun)-> EnvironmentTarget
- ReleaseBundle -> EnvironmentTarget
- DeploymentRun -(RollbackAction)-> target_ref
- Migration -(RollbackAction)-> target_ref
- ExceptionCase -(CompensationAction)-> target_ref
- target_ref -(SchedulerTimer)-> timeout.fired
- Wszystko emituje ProcessEventRecord i moze miec GateDecisionRecord / QualityEvidenceRecord

## Invariants warstwy OP
- Brak osieroconych OP (kazdy OP poza Project ma parent linkage).
- Kazdy state transition ma event + guard + actor.
- Kazda decyzja gate ma GateDecisionRecord i audytowalny ProcessEventRecord.
- Brak aktywnego `AccessGrant` dla akcji objetej authz uniewaznia transition.
- `GlossaryEntry.deprecated` wymaga replacement albo cleanup dla impacted UI/scenario scope.
- Kazdy krytyczny blad ma policy: retry albo recovery control.
- Zamkniecie Feature wymaga braku krytycznych otwartych PromptTask.
- Repository i ChangeSet musza zachowac traceability do powiazanych Feature/Requirement/Scenario.
- VerificationPolicy musi byc przypisana do Feature, ChangeSet albo ReleaseBundle wymagajacego formalnej walidacji.
- DataSchema i Migration sa wymagane, gdy zmiana obejmuje trwale dane lub niekompatybilna ewolucje schematu.
- ReleaseBundle nie moze byc opublikowany bez `EnvironmentTarget` w stanie co najmniej `ready`.
- DeploymentRun.failed musi utworzyc jawny `RollbackAction` albo miec jawny waiver z reason.
- DependencyRelation z `status=blocked` musi byc widoczna w reverse lookup i projection operatora.
- `RiskEntry.escalated` musi blokowac delivery scope do czasu jawnej closure albo override.
- `ExceptionCase.escalated` musi byc widoczny w projection operatora dla impacted scope.
- ExceptionCase z `compensation_required=true` musi miec jawny `CompensationAction` zanim zamknie downstream scope.
- RollbackAction musi byc domkniety jako `completed` albo `cancelled` z audytowalnym reason.
- SchedulerTimer musi byc consumowany albo anulowany po domknieciu target scope.
- CompensationAction musi byc domkniety jako `completed` albo `cancelled` z audytowalnym reason.
- UseCase i PortContract musza byc utrzymane bez zaleznosci od frameworkowych typow.
- Component graph nie moze zawierac cykli.
- Hard delete OP po pojawieniu sie ProcessEventRecord jest zabronione.
- Remove semantyczny wymaga tombstone metadata i zachowania link integrity.
