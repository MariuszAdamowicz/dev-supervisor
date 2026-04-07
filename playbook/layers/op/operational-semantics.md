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

Linki:
- https://cpre.ireb.org/en/concept/requirements-management
- https://martinfowler.com/bliki/ArchitectureDecisionRecord.html
- https://martinfowler.com/bliki/UbiquitousLanguage.html
- https://cucumber.io/docs/gherkin/reference/
- https://git-scm.com/book/en/v2/Distributed-Git-Distributed-Workflows
- https://martinfowler.com/articles/practical-test-pyramid.html
- https://12factor.net/config
- https://learn.microsoft.com/en-us/azure/architecture/patterns/compensating-transaction

## Klasy OP i recordow systemowych

- `work-object`: obiekt pracy projektowej lub produktowej. Operator tworzy go, czyta, aktualizuje i deprecjonuje.
- `control-object`: obiekt sterujacy polityka, uprawnieniami, jakością albo decyzja.
- `execution-object`: obiekt wykonawczy zwiazany z uruchomieniem pracy, zmian lub wdrozen.
- `environment-object`: obiekt opisujacy repo, schemat danych lub srodowisko uruchomieniowe.
- `graph-relation`: mutowalna relacja w grafie OP, niebedaca osobnym OP.
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

### DecisionRecord
- class: `control-object`
- applies_when: `always`
- znaczenie: jeden rekord = jedna decyzja, z kontekstem i konsekwencjami; nowe decyzje supersedują stare zamiast je nadpisywac.
- lifecycle: drafted -> reviewed -> approved, a zmiana decyzji tworzy superseding path.
- CRUD: create dla pojedynczej decyzji; update tylko do chwili approval; remove = superseded, nie rewrite history.

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

### Term
- class: `work-object`
- applies_when: `always`
- znaczenie: terminy buduja wspolny jezyk domeny i UX; musza ewoluowac wraz ze zrozumieniem domeny.
- lifecycle: proposed -> approved -> deprecated, z mozliwoscia zastapienia nowszym terminem.
- CRUD: create gdy pojawia sie nowe pojecie; update przez redefinicje i aliasy; remove = deprecate z replacement_ref.

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

### PromptTask
- class: `execution-object`
- applies_when: `always`
- znaczenie: materializuje prace delegowana do AI lub operatora review; jest jednostka retry, timeout i walidacji.
- lifecycle: created -> ready -> executed -> validated -> closed lub cancelled.
- CRUD: create przy triggerze procesu; update przez retry/context changes; remove = cancel/close.

### ActorRolePermission
- class: `control-object`
- applies_when: `always`
- znaczenie: ownership i authz musza byc stanem projektu, a nie domyslem runtime.
- lifecycle: defined -> active -> revised -> revoked.
- CRUD: create przy onboarding/new scope; update przez revise; remove = revoke.

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

### Risk
- class: `control-object`
- applies_when: `formal-validation`
- znaczenie: ryzyka musza miec jawny status i resolution path; inaczej release jest slepy.
- lifecycle: identified -> assessed -> mitigated/accepted/escalated -> closed.
- CRUD: create przy identyfikacji ryzyka; update przy ocenie i rezolucji; remove = close, nie skasowanie.

### Release
- class: `execution-object`
- applies_when: `formal-validation`
- znaczenie: release grupuje gotowe zmiany do publikacji i gate delivery.
- lifecycle: planned -> candidate -> approved -> published -> closed.
- CRUD: create przy gotowosci delivery; update przy rework; remove = close/reject z audit trail.

### Deployment
- class: `execution-object`
- applies_when: `deployable-runtime`
- znaczenie: deployment jest osobnym przebiegiem wykonawczym wobec release.
- lifecycle: prepared -> running -> succeeded albo failed.
- CRUD: create po approval release; update podczas retry; remove = terminal success/fail.

### Rollback
- class: `execution-object`
- applies_when: `deployable-runtime`
- znaczenie: rollback nie jest tylko skryptem; to osobny stan procesu po awarii wdrozenia.
- lifecycle: prepared -> running -> succeeded albo failed.
- CRUD: create po deployment failure lub explicit operator action; update przy retry; remove = terminal success/fail.

### Exception
- class: `execution-object`
- applies_when: `always`
- znaczenie: blad procesu lub biznesu musi miec classification i resolution path.
- lifecycle: detected -> classified -> handled albo escalated.
- CRUD: create przy authz/quality/runtime fail; update przez classify/handle; remove = handled/closed by lifecycle, nie delete.

### Timeout
- class: `execution-object`
- applies_when: `always`
- znaczenie: timeout jest stanem procesu, nie tylko timestampem w logu.
- lifecycle: scheduled -> fired -> handled albo escalated.
- CRUD: create przy defer/retry waiting; update przy recover; remove = handled.

### Compensation
- class: `execution-object`
- applies_when: `always` gdy failure_policy wymaga undo
- znaczenie: kompensacja musi miec plan, wykonanie i wynik; undo nie zawsze jest prostym odwróceniem krokow.
- lifecycle: planned -> running -> completed albo failed.
- CRUD: create po krytycznej awarii/reject; update przy retry; remove = completed.

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

### VerificationPlan
- class: `control-object`
- applies_when: `formal-validation`
- znaczenie: opisuje, jakie warstwy testow i evidence sa wymagane dla Feature, ChangeSet lub Release.
- lifecycle: drafted -> reviewed -> approved -> active -> revised -> retired.
- CRUD: create przy baseline i dla nowych klas zmian; update przy zmianie ryzyka/stacku; remove = retire po supersede.

### DataSchema
- class: `environment-object`
- applies_when: `persistent-data`
- znaczenie: schema i compatibility policy to stan projektu, nie tylko plik SQL lub ORM migration.
- lifecycle: drafted -> reviewed -> approved -> applied -> superseded -> deprecated.
- CRUD: create dla nowego obszaru danych; update przez kolejne rewizje; remove = deprecate po migracji off path.

### Migration
- class: `execution-object`
- applies_when: `persistent-data`
- znaczenie: migracja jest wykonaniem zmiany schematu/danych z wlasnym review, retry i rollback planem.
- lifecycle: drafted -> reviewed -> approved -> ready -> applied -> rolled-back albo superseded.
- CRUD: create przy kazdej niekompatybilnej lub operacyjnie istotnej zmianie schematu; update przy rehearsal/rework; remove = supersede po zastosowaniu.

### RuntimeEnvironment
- class: `environment-object`
- applies_when: `deployable-runtime`
- znaczenie: srodowisko lokalne, CI, staging, prod ma wlasne capability, config i readiness. Nie powinno byc ukryte w wiki.
- lifecycle: defined -> validated -> ready -> active -> degraded -> retired.
- CRUD: create dla kazdego srodowiska operacyjnego; update przy zmianie config/capabilities; remove = retire po decommission.

## Graph Relations

### DependencyRelation
- class: `graph-relation`
- applies_when: `always`
- znaczenie: zaleznosc jest krawedzia grafu z wlasnosciami, nie obiektem pracy. To pozwala pytac o downstream/upstream bez sztucznego tworzenia OP.
- lifecycle: relacja nie ma pelnego FSM OP; ma mutowalny `status` opisany w `relation-contracts.md`.
- CRUD: create przy odkryciu blokera lub warunku zewnetrznego; update przez zmiane `status` i propagation; remove = `retired`, nigdy hard delete po audycie.

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
- znaczenie: wynik konkretnej lane walidacyjnej albo quality check dla `Feature`, `ChangeSet`, `VerificationPlan` lub `Release`.
- lifecycle: append-only per lane/run; nowe wykonanie tworzy nowy record, nie nadpisuje starego.
- CRUD: create po lane/check; read dla gate i rollout; update/remove = forbidden.

## Reguly klasyfikacyjne

- Jesli byt nie ma wlasnego lifecycle, relation impact i potrzeby invalidation, nie powinien byc nowym OP.
- Jesli byt jest tylko artefaktem technicznym jednego OP, powinien pozostac artifact_ref lub evidence.
- Jesli byt ma znaczenie zalezne od stacku lub runtime, jego stosowalnosc musi byc jawna i nie moze byc wymuszana bezwarunkowo dla kazdego projektu.
