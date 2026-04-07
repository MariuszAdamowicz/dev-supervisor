# SQLBase Migration Plan

## Cel

Przeniesc source-of-truth stanu projektu z rozproszonych plikow `.ai/*` do lokalnej bazy SQL, przy zachowaniu:
- deterministycznego runtime,
- jawnego audit trail,
- mozliwosci eksportu `.ai/*` jako projection/evidence,
- bezpiecznego bootstrapu mimo problemu "jajko i kury".

## 1. Stan obecny

Obecnie repo ma trzy poziomy dojrzalosci storage:

1. `file-ai`
- realny runtime jest utrzymywany w `.ai/runtime/v1/*`
- OP snapshots, events, gates i evidence sa trzymane w plikach
- relacje sa zapisane lokalnie w `links`, ale brak pelnego graph index i reverse dependency queries

2. `sqlbase`
- profil istnieje logicznie
- bootstrap tworzy pusty `State/supervisor.sqlite3`
- sync kopiuje tylko wybrane artefakty `.ai <-> State/sqlbase/*`
- brak rzeczywistego storage adaptera dla runtime OP

3. aplikacja
- UI i runtime summary czytaja de facto z `file-ai`
- zmiana upstream OP nie ma silnika propagacji downstream impact

Wniosek:
`sqlbase` musi stac sie source-of-truth dla runtime, a `.ai/*` musi zostac zdegradowane do roli projection/export/evidence.

## 2. Zasada architektoniczna

Docelowy model:

- SQLBase:
  - source-of-truth dla instancji OP
  - source-of-truth dla relacji OP
  - source-of-truth dla eventow, gate decisions i propagation effects

- `.ai/*`:
  - projection dla operatora i AI
  - artefakty eksportowe
  - evidence i review packages
  - format interoperacyjny, ale nie primary storage

## 3. Obejscie problemu bootstrapu

Nie budujemy od razu "pelnego DevSupervisor tworzacego samego siebie".

Zamiast tego wprowadzamy dwa poziomy:

### 3.1 Bootstrap kernel

Minimalny, recznie utrzymywany rdzen infrastrukturalny.

Zakres:
- otwarcie bazy SQLite
- migracje schematu
- podstawowy storage adapter
- importer `.ai -> sqlbase`
- exporter `sqlbase -> .ai`
- podstawowe query relacji i impacted OP

To nie jest jeszcze "samonadzorujacy sie supervisor".
To jest warstwa umozliwiajaca jego powstanie.

### 3.2 Managed supervisor

Wlasciwy DevSupervisor budowany juz na SQLBase:
- runtime czyta i zapisuje stan procesu do DB
- UI jest projection z DB
- `.ai/*` jest generowane wtornie
- propagacja zmian dziala na bazie relacji zapisanych w DB

### 3.3 Regula przejsciowa

Przez przynajmniej jedna faze przejsciowa utrzymujemy:
- import z `.ai` do DB,
- dual-write,
- kontrolowany eksport z DB do `.ai`.

To redukuje ryzyko i pozwala walidowac zgodnosc obydwu reprezentacji.

## 4. Docelowy model danych SQLBase v1

Profil: SQLite lokalnie.

### 4.1 `projects`

Cel:
- identyfikacja projektu i aktywnej instancji playbooka

Pola:
- `project_id TEXT PRIMARY KEY`
- `name TEXT NOT NULL`
- `root_path TEXT NOT NULL UNIQUE`
- `playbook_instance_path TEXT`
- `storage_profile TEXT NOT NULL CHECK(storage_profile IN ('file-ai', 'sqlbase'))`
- `stack_profile TEXT NOT NULL`
- `architecture_profile TEXT NOT NULL`
- `language_profile TEXT NOT NULL`
- `execution_style_profile TEXT NOT NULL`
- `remote_url TEXT`
- `created_at TEXT NOT NULL`
- `updated_at TEXT NOT NULL`

### 4.2 `op_instances`

Cel:
- aktualny stan kazdej instancji OP

Pola:
- `op_id TEXT PRIMARY KEY`
- `project_id TEXT NOT NULL REFERENCES projects(project_id)`
- `op_type TEXT NOT NULL`
- `current_state TEXT NOT NULL`
- `owner TEXT NOT NULL`
- `created_at TEXT NOT NULL`
- `updated_at TEXT NOT NULL`
- `current_version INTEGER NOT NULL`
- `terminal INTEGER NOT NULL DEFAULT 0`
- `deprecated INTEGER NOT NULL DEFAULT 0`
- `replacement_op_id TEXT NULL REFERENCES op_instances(op_id)`
- `last_event_id TEXT`

Indeksy:
- `(project_id, op_type)`
- `(project_id, current_state)`
- `(project_id, terminal)`

### 4.3 `op_versions`

Cel:
- pelna historia snapshotow OP

Pola:
- `op_id TEXT NOT NULL REFERENCES op_instances(op_id)`
- `version INTEGER NOT NULL`
- `payload_json TEXT`
- `properties_json TEXT`
- `links_json TEXT`
- `tags_json TEXT`
- `created_at TEXT NOT NULL`
- `created_by TEXT NOT NULL`
- PRIMARY KEY (`op_id`, `version`)

Uwagi:
- `payload_json` przechowuje wlasciwosci domenowe
- `links_json` moze istniec przejsciowo, ale relacje kanoniczne beda tez znormalizowane w `op_relations`

### 4.4 `op_relations`

Cel:
- kanoniczny graph OP -> OP

Pola:
- `relation_id TEXT PRIMARY KEY`
- `project_id TEXT NOT NULL REFERENCES projects(project_id)`
- `source_op_id TEXT NOT NULL REFERENCES op_instances(op_id)`
- `target_op_id TEXT NOT NULL REFERENCES op_instances(op_id)`
- `relation_type TEXT NOT NULL`
- `direction TEXT NOT NULL DEFAULT 'forward'`
- `active INTEGER NOT NULL DEFAULT 1`
- `criticality TEXT NOT NULL DEFAULT 'normal'`
- `created_at TEXT NOT NULL`
- `updated_at TEXT NOT NULL`
- `created_by_event_id TEXT`
- `replaced_by_relation_id TEXT NULL`

Minimalne `relation_type`:
- `parent`
- `depends_on`
- `implements`
- `derived_from`
- `uses_term`
- `uses_component`
- `belongs_to_screen`
- `owner_use_case`
- `replacement`
- `trace`

Indeksy:
- `(project_id, source_op_id)`
- `(project_id, target_op_id)`
- `(project_id, relation_type)`

### 4.5 `process_events`

Cel:
- append-only audit trail dla runtime

Pola:
- `event_id TEXT PRIMARY KEY`
- `project_id TEXT NOT NULL REFERENCES projects(project_id)`
- `op_id TEXT NOT NULL REFERENCES op_instances(op_id)`
- `op_type TEXT`
- `event_type TEXT NOT NULL`
- `from_state TEXT`
- `to_state TEXT`
- `actor TEXT NOT NULL`
- `payload_hash TEXT NOT NULL`
- `idempotency_key TEXT NOT NULL UNIQUE`
- `gate_decision_id TEXT NULL`
- `causation_event_id TEXT NULL`
- `correlation_id TEXT NULL`
- `ts TEXT NOT NULL`

Indeksy:
- `(project_id, op_id, ts)`
- `(project_id, event_type, ts)`

### 4.6 `gate_decisions`

Cel:
- jawne decyzje operatora

Pola:
- `decision_id TEXT PRIMARY KEY`
- `project_id TEXT NOT NULL REFERENCES projects(project_id)`
- `op_id TEXT NOT NULL REFERENCES op_instances(op_id)`
- `gate_type TEXT NOT NULL`
- `decision TEXT NOT NULL`
- `reason TEXT NOT NULL`
- `actor TEXT NOT NULL`
- `based_on_event_id TEXT`
- `context_hash TEXT`
- `ts TEXT NOT NULL`
- `idempotency_key TEXT NOT NULL UNIQUE`

### 4.7 `evidence_records`

Cel:
- provenance walidacji i runtime capture

Pola:
- `evidence_id TEXT PRIMARY KEY`
- `project_id TEXT NOT NULL REFERENCES projects(project_id)`
- `op_id TEXT`
- `evidence_class TEXT NOT NULL`
- `source_ref TEXT NOT NULL`
- `executor_ref TEXT NOT NULL`
- `actor_or_system TEXT NOT NULL`
- `subject_hash TEXT NOT NULL`
- `started_at TEXT NOT NULL`
- `finished_at TEXT NOT NULL`
- `environment TEXT NOT NULL`
- `replayable_input_ref TEXT`
- `attestation_ref TEXT`
- `idempotency_key TEXT NOT NULL UNIQUE`

### 4.8 `propagation_effects`

Cel:
- zapisywac skutki zmiany upstream OP dla downstream OP

Pola:
- `effect_id TEXT PRIMARY KEY`
- `project_id TEXT NOT NULL REFERENCES projects(project_id)`
- `cause_event_id TEXT NOT NULL REFERENCES process_events(event_id)`
- `source_op_id TEXT NOT NULL REFERENCES op_instances(op_id)`
- `affected_op_id TEXT NOT NULL REFERENCES op_instances(op_id)`
- `effect_type TEXT NOT NULL`
- `status TEXT NOT NULL`
- `reason TEXT NOT NULL`
- `created_at TEXT NOT NULL`
- `resolved_at TEXT`
- `resolution_event_id TEXT`

Minimalne `effect_type`:
- `invalidated`
- `blocked_by_upstream`
- `requires_rework`
- `superseded`
- `replacement_required`

### 4.9 `artifacts`

Cel:
- mapowac artefakty `.ai/*` do OP i wersji runtime

Pola:
- `artifact_id TEXT PRIMARY KEY`
- `project_id TEXT NOT NULL REFERENCES projects(project_id)`
- `artifact_path TEXT NOT NULL`
- `artifact_type TEXT NOT NULL`
- `source_op_id TEXT`
- `source_event_id TEXT`
- `hash TEXT NOT NULL`
- `generated_at TEXT NOT NULL`
- `generator TEXT NOT NULL`

## 5. Kluczowe zapytania, ktore DB musi obslugiwac

1. Jakie OP istnieja dla projektu?
2. Jaki jest aktualny stan kazdego OP?
3. Jakie OP zalezne od `X` musza byc invalidated?
4. Jakie `UIComponent` naleza do `UIScreen Y`?
5. Jakie `UseCase`, `PortContract`, `Component` sa powiazane z `Feature Z`?
6. Jakie relacje sa dangling lub niespojne?
7. Jakie propagation effects sa otwarte?
8. Jakie OP sa `deprecated`, ale nadal maja aktywne dzieci?
9. Jakie artefakty `.ai/*` sa niezsynchronizowane z DB?

## 6. Kolejnosc migracji

### Faza 0. Przygotowanie

Cel:
- nie zmieniac jeszcze zachowania produktu
- zbudowac podstawy techniczne

Kroki:
1. dodac katalog `App/Core/SQLBase`
2. dodac `SQLiteRuntimeStore`
3. dodac migrator schematu v1
4. dodac testy integracyjne dla migracji DB

Definition of Done:
- aplikacja potrafi utworzyc i otworzyc DB
- migracje sa idempotentne
- nie zmienia sie jeszcze runtime produkcyjny

### Faza 1. Import `.ai -> sqlbase`

Cel:
- umiec odbudowac stan projektu z obecnych plikow

Kroki:
1. czytac `.ai/project-profile.json`
2. czytac runtime snapshots, events, gates, evidence
3. zapisac `op_instances`, `op_versions`, `process_events`, `gate_decisions`, `evidence_records`
4. z `links` budowac `op_relations`
5. raportowac:
   - missing parent
   - dangling target
   - duplicate idempotency keys
   - nielegalne state transitions

Definition of Done:
- dowolny projekt `file-ai` moze zostac zaimportowany do DB
- importer generuje raport integralnosci

### Faza 2. Dual-write

Cel:
- runtime zapisuje jednoczesnie do DB i do `.ai`

Kroki:
1. storage adapter zapisuje najpierw do SQL transaction
2. po commicie SQL eksportuje projection do `.ai/runtime/v1/*`
3. testy porownuja summary DB vs summary file-ai
4. kazdy mismatch jest FAIL

Definition of Done:
- `new_project` i `add_idea` dzialaja na dual-write
- audit i summary sa zgodne w obu reprezentacjach

### Faza 3. Read path z DB

Cel:
- UI i runtime summary czytaja z SQL

Kroki:
1. `summarizeRuntime` przepiac na DB
2. graph view i impacted children liczyc z `op_relations`
3. `.ai` traktowac jako projection tylko do inspekcji/exportu

Definition of Done:
- primary read path nie zalezy od parsowania `.ai/runtime/v1/*`

### Faza 4. Propagation engine

Cel:
- aktualizacja jednego OP wpływa jawnie na powiazane OP

Kroki:
1. zdefiniowac relacyjne reguly skutkow:
   - `parent`
   - `depends_on`
   - `belongs_to_screen`
   - `owner_use_case`
   - `replacement`
2. zbudowac `PropagationService`
3. przy `update/deprecate/replace`:
   - znalezc impacted OP
   - zapisac `propagation_effects`
   - zapisac ProcessEvent dla skutku
   - ustawic statusy blokady/invalidation
4. pokazac impacted OP w UI

Definition of Done:
- upstream change ma deterministyczne skutki downstream
- skutki sa widoczne i audytowalne

### Faza 5. File-ai jako projection only

Cel:
- odwrócenie zaleznosci storage

Kroki:
1. usunac runtime writes bezposrednio do `.ai/runtime/v1/*`
2. zostawic exporter DB -> `.ai`
3. importer `.ai -> DB` zostawic jako narzedzie migracyjne i recovery

Definition of Done:
- SQLBase jest jedynym source-of-truth runtime

## 7. Zmiany w playbooku

### 7.1 `playbook/profiles/storage/sqlbase.md`

Dopisac:
- kanoniczny model tabel runtime
- source-of-truth = DB
- `.ai/*` jako projection/export
- wymagana obsluga `op_relations` i `propagation_effects`
- wymagane transakcje dla state-changing operations

### 7.2 `playbook/workflow/op-crud-contract.md`

Rozszerzyc o:
- obowiazkowy `relation graph contract`
- reverse dependency query contract
- propagation contract dla `update`, `replace`, `deprecate`
- jawne skutki downstream

### 7.3 `playbook/validation/playbook-contracts.md`

Dopisac:
- `Relation propagation contract`
- `SQL integrity contract`
- `Projection export contract`

Nowe minimalne reguly:
- zmiana upstream OP bez zapisania impacted downstream = invalid
- aktywne dangling relations = invalid
- deprecacja bez tombstone + replacement/impact report = invalid

### 7.4 `playbook/runtime/playbook-exec.yaml`

Dodac/zmienic:
- `storage-adapter` contracts dla SQLBase
- jawne kroki `query_impacted_ops`
- jawne kroki `persist_propagation_effects`
- jawne kroki `export_projection`
- branch dla migration/import flow

### 7.5 `playbook/verification/semantic-validation.md`

Dopisac semantycznie:
- runtime evidence musi dowodzic propagacji downstream
- negative tests dla broken relations
- testy replacement map

### 7.6 `playbook/experience/*`

Uscislic:
- UI musi pokazywac impacted downstream OP przy zmianie upstream
- UI musi rozrozniac `blocked`, `invalidated`, `superseded`

## 8. Zmiany w kodzie DevSupervisor

### 8.1 Nowe moduły

Dodac:
- `App/Core/SQLBase/SQLiteDatabase.swift`
- `App/Core/SQLBase/RuntimeMigrations.swift`
- `App/Core/SQLBase/SQLRuntimeStore.swift`
- `App/Core/SQLBase/RuntimeImporterFromAI.swift`
- `App/Core/SQLBase/RuntimeProjectionExporter.swift`
- `App/Core/SQLBase/PropagationService.swift`
- `App/Core/SQLBase/RelationQueryService.swift`

### 8.2 Runtime adapter

Zmodyfikowac:
- `PlaybookRuntimeFileSystem`

Kierunek:
- przemianowac odpowiedzialnosc na storage-neutral runtime facade
- rozdzielic `FileAIRuntimeStore` i `SQLRuntimeStore`
- wybrac store po `StorageProfile`

### 8.3 Modele runtime

Rozszerzyc modele domenowe o:
- relation snapshots
- propagation summaries
- blocked/invalidation reasons
- replacement refs

### 8.4 UI

Zmodyfikowac:
- starter i ekrany operatora czytaja stan z DB summary
- pokazuja impacted downstream OP
- nie renderuja "na slepo" lokalnych sekcji bez oparcia o runtime graph

### 8.5 Testy

Dodac:
- migracje DB
- importer `.ai -> db`
- dual-write consistency
- relation propagation
- invalidation previews
- replacement/deprecation paths

## 9. Minimalny kontrakt storage adaptera dla SQLBase

Interfejs v1:

1. `initializeProjectRuntime(project)`
2. `createOp(request)`
3. `applyTransition(request)`
4. `recordGateDecision(decision)`
5. `appendProcessEvent(event)`
6. `appendEvidence(evidence)`
7. `upsertRelations(relations)`
8. `getRuntimeSummary(project_id)`
9. `getRelatedOps(op_id, relation_filter)`
10. `getImpactedOps(op_id, action_type)`
11. `recordPropagationEffects(effects)`
12. `exportProjection(project_id)`
13. `importFromAI(project_root)`

## 10. Jak nie wpasc znowu w pulapke bootstrapu

### Zasada 1

Nie wymagac, zeby pelny DS najpierw istnial, zeby mogl stworzyc podstawy swojego storage.

### Zasada 2

Utrzymywac "bootstrap kernel" poza zakresem samo-hostingu.

To normalne i akceptowalne.
Tak samo kompilator nie zawsze jest od pierwszego dnia skompilowany sam soba.

### Zasada 3

Mierzyc dojrzalosc w krokach:
- najpierw DB istnieje,
- potem importuje stan,
- potem runtime pisze dual-write,
- potem czyta z DB,
- dopiero potem zarzadza propagacja i self-hostingiem.

### Zasada 4

Nie probowac od razu migrowac wszystkiego.

Start od najwazniejszego pionowego slice:
- `Project`
- `Idea`
- baseline OP
- `ProcessEvent`
- `GateDecision`
- relacje parent/downstream

## 11. Proponowana pierwsza iteracja wdrozenia

Jesli mamy zrobic to pragmatycznie, pierwsza iteracja powinna obejmowac tylko:

1. SQLite schema v1
2. importer `.ai/runtime/v1 -> SQLBase`
3. dual-write dla:
- `Project`
- `Idea`
- baseline OP
- `ProcessEvent`
- `GateDecision`
- `Evidence`
4. `op_relations` dla:
- `parent`
- `owner_use_case`
- `derived_from`
5. runtime summary z DB
6. test integralnosci: `file-ai summary == sqlbase summary`

To juz da:
- sensowny model stanu projektu
- mozliwosc query relacji
- sensowna baze pod kolejne iteracje

## 12. Definition of Done dla migracji na SQLBase

Migracje uznajemy za gotowa dopiero wtedy, gdy:

1. SQLBase jest source-of-truth dla runtime OP
2. `.ai/*` jest projection/export, a nie primary storage
3. relacje OP sa jawnie zapisywane i queryable w obie strony
4. zmiana upstream OP generuje propagation effects dla downstream OP
5. build/test/lint przechodza dla zakresu storage
6. istnieje importer starego `file-ai`
7. istnieje exporter `sqlbase -> .ai`
8. playbook waliduje relation propagation i SQL integrity

## 13. Rekomendacja koncowa

Nie wracac do pomyslu "albo wszystko self-hosted od poczatku, albo nic".

Najrozsadniejsza droga:
- uznac `file-ai` za etap bootstrapowy,
- zbudowac maly kernel SQLBase recznie,
- przeniesc runtime slice po slice,
- dopiero potem oczekiwac, ze DevSupervisor bedzie wiarygodnie zarzadzal swoim wlasnym projektem.

To obchodzi problem jajka i kury bez udawania, ze on nie istnieje.
