# OP CRUD Contract

Cel:
ustalic jednoznaczny kontrakt tworzenia, odczytu, modyfikacji i usuwania OP oraz ich relacji.

## 1. Create

- kazdy entrypoint deklaruje jawnie, jakie OP moze utworzyc.
- create wymaga: `op_type`, parent linkage, owner, initial state, source artifact lub source event.
- create bez parent linkage jest nielegalne, z wyjatkiem `Project`.

## 2. Read

- runtime musi utrzymywac indeks aktywnych OP i ich relacji.
- projection operatora pokazuje task-first summary, a nie surowe ids jako primary UI.
- audit/debug moze czytac pelny graph, event log i gate log.

## 2a. Graph relation contract

- runtime musi utrzymywac mutowalne relacje grafu zgodnie z `layers/op/relation-contracts.md`.
- relacja grafu nie jest OP; nie ma osobnego parent linkage i nie bierze udzialu w OP coverage audit.
- relacja grafu musi byc queryable w przod i wstecz (`relation-index` + `reverse-relation-index`).
- `DependencyRelation` musi byc widoczna dla scope Feature/Component/Release/Deployment, gdy ma status `blocked` albo `waived`.

## 2b. Scheduler control contract

- runtime musi utrzymywac mutowalne timery zgodnie z `layers/op/scheduler-contracts.md`.
- `SchedulerTimer` nie jest OP i nie bierze udzialu w OP coverage audit.
- scheduler control musi byc queryable po `target_ref`, `status` i `due_at`.
- timer po `timeout.fired` musi zostac `consumed` albo `cancelled` w jawny sposob.

## 3. Update

- update OP zachodzi tylko przez legal transition albo audytowalny update artefaktu niezmieniajacy state.
- update musi zapisac:
  - actor,
  - change reason,
  - trace do review package lub prompt task,
  - invalidation scope dla downstream OP.
- kazda zmiana guardow lub linkow wymaga ponownej walidacji invariantow grafu.

### 3a. Update semantics by OP class

- `work-object`: update moze zmieniac payload, linki i stan, ale tylko w legalnych oknach lifecycle.
- `control-object`: update wymaga jawnego reason i ponownej walidacji guardow OP zaleznych.
- `execution-object`: update jest zwiazany z postepem wykonania, retry, timeout lub compensation; nie wolno nadpisywac wyniku bez nowego ProcessEventRecord.
- `environment-object`: update wymaga sprawdzenia skutkow dla ChangeSet, Release, Deployment lub Feature zaleznych od danego srodowiska/kontraktu.

### 3b. Propagation contract

- update upstream OP musi byc materializowany jako jawny graph walk po relacjach.
- runtime musi potrafic odpowiedziec:
  - ktore OP sa downstream od zmienionego OP,
  - czy downstream ma byc `invalidated`, `blocked-by-upstream`, `superseded` albo pozostaje `unchanged`.
- propagation effect musi byc zapisany jako ProcessEventRecord i byc widoczny w projection operatora.
- brak propagacji przy zmianie linkow, policy, schematu danych, verification policy albo UI projection = zapis nielegalny.

### 3c. System record semantics

- `GateDecisionRecord`, `ProcessEventRecord` i `QualityEvidenceRecord` nie sa OP.
- records systemowe sa append-only; poprawka lub reinterpretacja oznacza nowy record z jawna relacja do poprzedniego.
- record systemowy musi wskazywac co najmniej `op_id`, `actor`, `ts` i kontekst przyczynowy.
- records systemowe nie podlegaja klasycznemu CRUD; dozwolone jest tylko create i read.

## 4. Remove

- hard delete OP po utworzeniu ProcessEventRecord jest zabronione.
- usuniecie semantyczne zachodzi przez stany terminalne: deprecated, revoked, dropped, cancelled, archived, closed.
- remove wymaga tombstone metadata:
  - who,
  - why,
  - replacement_ref lub brak replacement z reason,
  - impacted_children.

### 4a. Remove semantics by OP class

- `work-object`: remove = deprecate, supersede, archive albo obsolete.
- `control-object`: remove = retire, revoke, close albo supersede z jawna polityka skutkow.
- `execution-object`: remove = close, cancel, fail, rolled-back albo supersede; usuniecie nie moze wymazac historii wykonania.
- `environment-object`: remove = archive, retire albo decommission; runtime musi zachowac reference integrity dla historycznych ChangeSet/Release/Migration.

## 5. Graph integrity

- brak osieroconych OP poza `Project`.
- brak dangling links.
- kazdy child zna parent, a parent ma mozliwosc projekcji child summary.
- `Component` i `DependencyRelation` wymagaja kontroli kierunku zaleznosci i no-cycle.
- `UseCase` / `PortContract` / `Component` musza byc wyszukiwalne z `Feature`.
- `Repository` i `ChangeSet` musza byc wyszukiwalne z `Feature`, `Requirement` i `Scenario`, gdy istnieje traceability.
- `VerificationPlan` musi byc wyszukiwalny z `Feature`, `ChangeSet` i `Release`, gdy `formal-validation` jest aktywne.
- `DataSchema` / `Migration` / `RuntimeEnvironment` musza miec reverse lookup do OP, ktore zalezne sa od danych lub deploymentu.
- `DependencyRelation` musi miec reverse lookup do impacted OP i jawny `status`.

## 6. Runtime artefakty

Minimalny runtime po bootstrapie musi miec:
- `op-index.json` lub rownowazny indeks OP,
- jawny parent linkage,
- jawny relation index i reverse relation index,
- indeks terminal/deprecated OP,
- indeks propagation effects i impacted OP,
- audyt create/update/remove.

## 7. Zrodla praktyk

Punkty odniesienia:
- PostgreSQL constraints: integralnosc i twarde blokowanie nielegalnych zapisow.
- Neo4j constraints: jawne ograniczenia dla grafu i identyfikatorow.
- OWASP logging guidance: audyt create/update/delete bez cichych zmian.

Linki:
- https://www.postgresql.org/docs/current/ddl-constraints.html
- https://neo4j.com/docs/cypher-manual/current/schema/constraints/create-constraints/
- https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html
