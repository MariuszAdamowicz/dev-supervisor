# OP Operational Semantics

Cel:
opisac, kiedy dany OP jest potrzebny, jak zachowuje sie w procesie wytwarzania oprogramowania
oraz jakie sa jego praktyczne oczekiwania lifecycle/CRUD.

Ta specyfikacja nie zastępuje:
- `object-catalog.md` jako katalogu kanonicznych typow,
- `state-machines.md` jako kanonicznego FSM,
- `trigger-rules.md` jako kanonicznej automatyki.

Ta specyfikacja dopowiada:
- stosowalnosc OP zalezną od stacku, storage i charakteru produktu,
- roznice miedzy OP pracy, OP polityki, OP srodowiska i recordami audytowymi,
- semantyke CRUD, gdy hard delete jest zabroniony.

## Zrodla praktyk

Praktyki w tej specyfikacji opieraja sie na:
- IREB Requirements Management: wersjonowanie, zmiana, priorytetyzacja i traceability wymagan.
- Martin Fowler ADR: pojedyncza decyzja na rekord, krótka forma, supersedowanie zamiast nadpisywania.
- Martin Fowler Ubiquitous Language: terminy domenowe musza ewoluowac wraz ze zrozumieniem domeny.
- Cucumber Gherkin Reference: scenariusz ma reprezentowac regule biznesowa przez konkretne przyklady.
- Git Distributed Workflows: repozytorium i przeplyw zmian sa elementem procesu, nie tylko narzedziem.
- Practical Test Pyramid: weryfikacja wymaga warstw testow o roznej granulacji.
- Twelve-Factor Config: konfiguracja srodowiskowa musi byc oddzielona od kodu.
- Azure Compensating Transaction / Saga: dlugie procesy i awarie wymagaja jawnej kompensacji i retry.
- Microservices.io Saga: compensation jest aplikacyjnie specyficznym krokiem undo, nie odrebnym artefaktem produktu.

Linki:
- https://cpre.ireb.org/en/concept/requirements-management
- https://martinfowler.com/bliki/ArchitectureDecisionRecord.html
- https://martinfowler.com/bliki/UbiquitousLanguage.html
- https://cucumber.io/docs/gherkin/reference/
- https://git-scm.com/book/en/v2/Distributed-Git-Distributed-Workflows
- https://martinfowler.com/articles/practical-test-pyramid.html
- https://12factor.net/config
- https://learn.microsoft.com/en-us/azure/architecture/patterns/compensating-transaction
- https://microservices.io/post/microservices/2019/07/09/developing-sagas-part-1.html

## Klasy OP i recordow systemowych

- `work-object`: obiekt pracy projektowej lub produktowej. Operator tworzy go, czyta, aktualizuje i deprecjonuje.
- `control-object`: obiekt sterujacy polityka, uprawnieniami, jakością albo decyzja.
- `decision-control`: mutowalny rekord decyzji architektonicznej lub produktowej, niebedacy OP.
- `execution-object`: obiekt wykonawczy zwiazany z uruchomieniem pracy, zmian lub wdrozen.
- `environment-object`: obiekt opisujacy repo, schemat danych lub srodowisko uruchomieniowe.
- `verification-control`: mutowalna polityka lane, evidence i gate dla scope formalnej walidacji, niebedaca OP.
- `data-control`: mutowalny handle review/apply/rollback zmiany danych, niebedacy OP.
- `environment-control`: mutowalny target srodowiska i gotowosci runtime, niebedacy OP.
- `exception-control`: mutowalny przypadek bledu procesu lub runtime, niebedacy OP.
- `delivery-control`: mutowalny runtime handle rollout/deploy, niebedacy OP.
- `job-control`: mutowalny runtime handle dla pracy AI albo operatora review, niebedacy OP.
- `graph-relation`: mutowalna relacja w grafie OP, niebedaca osobnym OP.
- `recovery-control`: mutowalny runtime handle undo/cleanup, niebedacy OP.
- `scheduler-control`: mutowalny runtime handle czasu i retry, niebedacy OP.
- `system-record`: rekord audytowy lub dowodowy. Nie jest OP, jest append-only i rzadko jest primary task.

## Reguly stosowalnosci

- `always`: OP jest wymagany dla kazdego projektu.
- `interactive-ui`: OP wymagany tylko gdy produkt ma interfejs operatora lub uzytkownika.
- `version-controlled`: OP wymagany gdy projekt jest rozwijany w repozytorium VCS.
- `formal-validation`: OP wymagany gdy projekt ma jawna polityke testow/gate/release.
- `persistent-data`: OP wymagany gdy projekt przechowuje dane z ewolucja schematu.
- `deployable-runtime`: OP wymagany gdy projekt ma srodowiska uruchomieniowe lub wdrozenia.

## OP semantics

### Project
- class: `work-object`
- applies_when: `always`
- znaczenie: kotwica dla baseline, profili, ownership i wszystkich relacji parent/child.
- lifecycle: przechodzi od bootstrap do aktywnego projektu i archiwizacji; re-konfiguracja nie tworzy nowego Project bez jawnego powodu.
- CRUD: create podczas setup; read w kazdej sesji; update przez reconfiguration/baseline maintenance; remove = archive z zachowaniem audytu.

### Requirement
- class: `work-object`
- applies_when: `always`
- znaczenie: wymaga wersjonowania, priorytetyzacji, traceability i kontroli zmian.
- lifecycle: od propozycji, przez doprecyzowanie i approval, do powiazania z downstream OP lub deprecacji.
- CRUD: create przy baseline albo zmianie scope; update przez clarify/rework; remove = deprecate lub supersede, nigdy silent delete.

### Constraint
- class: `control-object`
- applies_when: `always`
- znaczenie: ograniczenia architektoniczne, prawne, operacyjne i NFR nie moga byc tylko tekstem w overview.
- lifecycle: constraint jest walidowany, egzekwowany, rewidowany i dopiero potem wycofywany.
- CRUD: create gdy pojawia sie nowe ograniczenie; update przez revise/enforce; remove = retire tylko po analizie skutkow downstream.

### Idea
- class: `work-object`
- applies_when: `always`
- znaczenie: lekki pojemnik na wczesny scope i opcje produktowe przed konwersja do Feature.
- lifecycle: idea moze byc uchwycona, doprecyzowana, przekonwertowana albo odrzucona.
- CRUD: create przy intake; update podczas scope; remove = drop, z zachowaniem sladu dlaczego nie weszla do backlogu.

### Feature
- class: `work-object`
- applies_when: `always`
- znaczenie: glowna jednostka dostarczania zachowania, spinajaca spec, UX, testy, implementacje i release.
- lifecycle: feature powinna przechodzic przez spec, UX, scenariusze, testy, implementacje, stabilizacje i delivery.
- CRUD: create z Idea lub Requirement; update w cyklu rework; remove = reject/supersede albo explicit descope, bez kasowania audytu.

### Scenario
- class: `work-object`
- applies_when: `formal-validation`
- znaczenie: scenariusz jest konkretnym przykladem reguly biznesowej, nie tylko test case id.
- lifecycle: scenariusz powstaje, przechodzi review, approval, powiazanie z testami, stan passing i eventual obsolescence.
- CRUD: create dla nowej reguly/przykladu; update przy zmianie zachowania; remove = obsolete gdy regula przestaje byc aktualna.

### UIComponent
- class: `work-object`
- applies_when: `interactive-ui`
- znaczenie: najmniejsza jednostka UX, ktora ma wlasny cel, widocznosc i reguly CTA.
- lifecycle: proposed -> mapped -> implemented -> verified -> deprecated.
- CRUD: create przy nowym wzorcu interakcji; update przy zmianie copy, placement lub reguly; remove = deprecate, nie ukrycie bez sladu.

### UIScreen
- class: `work-object`
- applies_when: `interactive-ui`
- znaczenie: projekcja jednego primary task i zestawu legalnych akcji dla danego stanu OP.
- lifecycle: proposed -> mapped -> verified -> deprecated.
- CRUD: create dla nowego entrypointu/trybu; update przy zmianie projekcji; remove = deprecate lub replace przez nowy ekran.

### UseCase
- class: `work-object`
- applies_when: `always` dla zachowania biznesowego
- znaczenie: opisuje zachowanie niezalezne od frameworka i jest kotwica dla testow domeny.
- lifecycle: drafted -> reviewed -> approved -> implemented -> verified -> deprecated.
- CRUD: create dla kazdego istotnego zachowania; update przez review/rework; remove = deprecate po utracie znaczenia.

### PortContract
- class: `work-object`
- applies_when: `always` przy granicy rdzen <-> zewnetrze
- znaczenie: kontrakt portu pilnuje DTO boundary i stabilnosci granic.
- lifecycle: proposed -> reviewed -> approved -> adopted -> deprecated.
- CRUD: create dla kazdej granicy; update przez revise; remove = deprecate po migracji lub replace.

### Component
- class: `work-object`
- applies_when: `always`
- znaczenie: komponent jest nosnikiem odpowiedzialnosci, owned paths i reguly zaleznosci.
- lifecycle: identified -> mapped -> checked -> compliant albo refactor-required -> deprecated.
- CRUD: create dla istotnej jednostki architektonicznej; update przy refaktorze i zmianie odpowiedzialnosci; remove = deprecate po merge/replacement.

### Repository
- class: `environment-object`
- applies_when: `version-controlled`
- znaczenie: repozytorium jest stanem projektu: init, remote, branch policy, cleanliness i divergence maja skutki procesowe.
- lifecycle: detected -> initialized -> remote-attached -> policy-aligned -> active -> archived.
- CRUD: create przy bootstrap projektu; update przy zmianie remote/policy; remove = archive/detach przy zachowaniu historii.

### ChangeSet
- class: `execution-object`
- applies_when: `version-controlled`
- znaczenie: bounded pakiet zmian powiazany z OP, plikami, testami i commitami; sluzy traceability oraz invalidation downstream.
- lifecycle: drafted -> staged -> validated -> committed -> superseded.
- CRUD: create dla kazdego pakietu pracy nadajacego sie do review; update podczas staging/rework; remove = supersede lub abandon z reason.

### DataSchema
- class: `environment-object`
- applies_when: `persistent-data`
- znaczenie: schema i compatibility policy to stan projektu, nie tylko plik SQL lub ORM migration.
- lifecycle: drafted -> reviewed -> approved -> applied -> superseded -> deprecated.
- CRUD: create dla nowego obszaru danych; update przez kolejne rewizje; remove = deprecate po migracji off path.

## Graph Relations

### DependencyRelation
- class: `graph-relation`
- applies_when: `always`
- znaczenie: zaleznosc jest krawedzia grafu z wlasnosciami, nie obiektem pracy. To pozwala pytac o downstream/upstream bez sztucznego tworzenia OP.
- lifecycle: relacja nie ma pelnego FSM OP; ma mutowalny `status` opisany w `relation-contracts.md`.
- CRUD: create przy odkryciu blokera lub warunku zewnetrznego; update przez zmiane `status` i propagation; remove = `retired`, nigdy hard delete po audycie.

### SchedulerTimer
- class: `scheduler-control`
- applies_when: `always`
- znaczenie: timer jest runtime handle scheduler'a, a nie obiektem pracy. Ma gwarantowac deterministyczne `timeout.fired`, cancel i consume.
- lifecycle: timer nie ma pelnego FSM OP; ma mutowalny `status` opisany w `scheduler-contracts.md`.
- CRUD: create przy defer/retry/deadline; update przez `scheduled -> fired|cancelled -> consumed`; remove = `cancelled` albo `consumed`.

## Data Controls

### MigrationAction
- class: `data-control`
- applies_when: `persistent-data`
- znaczenie: migracja jest mutowalnym handle review/apply/rollback zmiany danych; to wykonanie operacyjne, nie samodzielny obiekt pracy projektu.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `data-contracts.md`.
- CRUD: create przy kazdej niekompatybilnej lub operacyjnie istotnej zmianie schematu; update przy review/readiness/apply/rollback; remove = `superseded` albo `rolled-back`, nigdy hard delete po audycie.

## Delivery Controls

### ReleaseBundle
- class: `delivery-control`
- applies_when: `formal-validation`
- znaczenie: bundle delivery jest mutowalnym zakresem wydania i gate approval, ale nie samodzielnym obiektem pracy produktu.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `delivery-contracts.md`.
- CRUD: create przy gotowosci delivery; update przez approval/publish/closure; remove = `closed`, nigdy hard delete po audycie.

### DeploymentRun
- class: `delivery-control`
- applies_when: `deployable-runtime`
- znaczenie: deployment run jest runtime wykonaniem rolloutu dla konkretnego `ReleaseBundle` i `EnvironmentTarget`. To nie jest samodzielny obiekt pracy projektu.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `delivery-contracts.md`.
- CRUD: create po `ReleaseBundle.approved`; update przez `planned -> running -> succeeded|failed|cancelled`; remove = `succeeded` albo `cancelled`.

## Job Controls

### PromptTask
- class: `job-control`
- applies_when: `always`
- znaczenie: PromptTask materializuje runtime job AI albo review task operatora. To jednostka wykonania i retry, ale nie samodzielny obiekt projektu.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `job-contracts.md`.
- CRUD: create przy triggerze procesu; update przez retry/context changes/validation; remove = `closed` albo `cancelled`, nigdy hard delete po audycie.

## Decision Controls

### DecisionRecord
- class: `decision-control`
- applies_when: `always`
- znaczenie: jeden rekord = jedna decyzja z kontekstem, opcjami i konsekwencjami; nowe decyzje supersedują stare zamiast je nadpisywac, ale sam rekord nie jest obiektem pracy produktu.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `decision-contracts.md`.
- CRUD: create dla pojedynczej decyzji; update do chwili approval albo supersede; remove = `superseded`, nigdy rewrite history.

## Verification Controls

### VerificationPolicy
- class: `verification-control`
- applies_when: `formal-validation`
- znaczenie: polityka walidacji opisuje wymagane lane testowe, evidence i provenance dla Feature, ChangeSet albo ReleaseBundle, ale nie jest samodzielnym obiektem pracy projektu.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `verification-contracts.md`.
- CRUD: create przy baseline i dla nowych klas zmian; update przy zmianie ryzyka, stacku lub delivery lane; remove = `retired`, nigdy hard delete po audycie.

## Risk Controls

### RiskEntry
- class: `risk-control`
- applies_when: `formal-validation`
- znaczenie: ryzyko jest jawna pozycja rejestru i blockerem governance, ale nie samodzielnym obiektem pracy projektowej.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `risk-contracts.md`.
- CRUD: create przy identyfikacji ryzyka; update przez ocene i resolution path; remove = `closed`, nigdy hard delete po audycie.

## Exception Controls

### ExceptionCase
- class: `exception-control`
- applies_when: `always`
- znaczenie: exception case jest jawna kontrola bledu procesu lub runtime. Wymaga klasyfikacji, resolution path i blocker projection, ale nie jest samodzielnym obiektem pracy projektu.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `exception-contracts.md`.
- CRUD: create przy authz/quality/runtime fail; update przez classify/handle/escalate; remove = `handled`, nigdy hard delete po audycie.

## Environment Controls

### EnvironmentTarget
- class: `environment-control`
- applies_when: `deployable-runtime`
- znaczenie: target srodowiska jest kontrola gotowosci runtime i capability dla delivery oraz walidacji. To nie jest samodzielny obiekt pracy projektu.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `environment-contracts.md`.
- CRUD: create dla local/ci/stage/prod; update przez readiness/recovery/decommission; remove = `retired`, nigdy hard delete po audycie.

## Authz Controls

### AccessGrant
- class: `authz-control`
- applies_when: `always`
- znaczenie: authz i ownership sa jawna polityka procesu, ale nie samodzielnym obiektem pracy projektu. Grant musi byc queryable po principal/scope/action.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `authz-contracts.md`.
- CRUD: create przy bootstrapie projektu albo nowym scope; update przez revise/reactivate; remove = `revoked`, nigdy hard delete po audycie.

## Glossary Controls

### GlossaryEntry
- class: `glossary-control`
- applies_when: `always`
- znaczenie: wpis slownika utrzymuje ubiquitous language dla copy, UX i scenariuszy, ale nie jest samodzielnym obiektem pracy projektu.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `glossary-contracts.md`.
- CRUD: create przy nowym pojeciu; update przez akceptacje, aliasy i replacement; remove = `deprecated`, nigdy hard delete po audycie.

## Recovery Controls

### RollbackAction
- class: `recovery-control`
- applies_when: `deployable-runtime` albo `persistent-data`, gdy revert jest legalna sciezka recovery
- znaczenie: rollback jest kontrola runtime cofajaca deployment lub migracje do poprzedniej stabilnej rewizji. To nie jest samodzielny obiekt pracy projektu.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `recovery-contracts.md`.
- CRUD: create po `DeploymentRun.failed` albo `MigrationAction.rollback-requested`; update przez `planned -> running -> completed|failed|cancelled`; remove = `completed` albo `cancelled`.

### CompensationAction
- class: `recovery-control`
- applies_when: `always` gdy failure_policy wymaga undo lub cleanup side effects
- znaczenie: kompensacja jest mechanizmem odzyskiwania dla ExceptionCase, RollbackAction, MigrationAction albo innych krokow z side effect. To runtime control, nie samodzielny obiekt pracy projektu.
- lifecycle: control nie ma pelnego FSM OP; ma mutowalny `status` opisany w `recovery-contracts.md`.
- CRUD: create przy awarii/reject/decyzji recovery; update przez `planned -> running -> completed|failed|cancelled`; remove = `completed` albo `cancelled`, nigdy hard delete po audycie.

## System Records

### GateDecisionRecord
- class: `system-record`
- applies_when: `always`
- znaczenie: jawny fakt decyzyjny po review package; autoryzuje transition, ale nie jest samodzielnym OP pracy.
- lifecycle: append-only, recorded once per decision outcome.
- CRUD: create przy gate; read dla audytu i guardow; update/remove = forbidden.

### ProcessEventRecord
- class: `system-record`
- applies_when: `always`
- znaczenie: niezmienny audit trail; sluzy replayowi, provenance i zgodnosci runtime.
- lifecycle: append-only, recorded per event.
- CRUD: create dla kazdego istotnego zdarzenia; read dla audytu; update/remove = forbidden.

### QualityEvidenceRecord
- class: `system-record`
- applies_when: `formal-validation`
- znaczenie: wynik konkretnej lane walidacyjnej albo quality check dla `Feature`, `ChangeSet`, `VerificationPolicy` lub `ReleaseBundle`.
- lifecycle: append-only per lane/run; nowe wykonanie tworzy nowy record, nie nadpisuje starego.
- CRUD: create po lane/check; read dla gate i rollout; update/remove = forbidden.

## Reguly klasyfikacyjne

- Jesli byt nie ma wlasnego lifecycle, relation impact i potrzeby invalidation, nie powinien byc nowym OP.
- Jesli byt jest tylko artefaktem technicznym jednego OP, powinien pozostac artifact_ref lub evidence.
- Jesli byt ma znaczenie zalezne od stacku lub runtime, jego stosowalnosc musi byc jawna i nie moze byc wymuszana bezwarunkowo dla kazdego projektu.
