# Data Contracts (kanoniczne)

Cel:
opisac mutowalne data controls,
ktore nie sa OP, ale maja wlasne pola, statusy, propagation i audit.

Data control nie jest:
- OP z pelnym lifecycle produktowym,
- zwyklym artefaktem SQL albo notatka migracyjna,
- system recordem append-only.

Data control jest:
- mutowalnym handle review/apply/rollback zmiany danych,
- bytem queryable po `schema_ref`, `status` i `execution_lane`,
- nosnikiem gotowosci operacyjnej, kompatybilnosci i rollback planu.

## Kontrakt wspolny data control

Kazdy data control ma pola:
- `migration_id`
- `schema_ref`
- `status`
- `owner`
- `created_at`
- `updated_at`
- `direction`
- `execution_lane`
- `compatibility_window`
- `reason`

Pola opcjonalne:
- `rollback_action_ref`
- `environment_ref`
- `evidence_refs`
- `replacement_ref`
- `no_op_note_ref`

Reguly:
- data control musi byc zapisany w runtime index i reverse lookup po `schema_ref`,
- mutacja data control wymaga `ProcessEventRecord`,
- brak reverse lookup uniewaznia propagation contract dla danych,
- data control nie moze byc primary UI; operator widzi go jako blocker, readiness albo apply task.

## MigrationAction

Rola:
opisuje review, approval, readiness, apply i rollback request
dla konkretnej zmiany danych powiazanej z `DataSchema`.

### Statusy

- `drafted`: migracja opisana, ale jeszcze bez review package.
- `reviewed`: gotowy review package kompatybilnosci i apply window.
- `approved`: zatwierdzony plan migracji.
- `ready`: potwierdzona gotowosc lane i rollback plan.
- `applied`: migracja wykonana.
- `rolled-back`: migracja zostala cofnięta legalna sciezka recovery.
- `superseded`: migracja nie jest juz aktywna, bo zastapila ja inna.

### CRUD semantics

Create:
- tworz `MigrationAction`, gdy zmiana danych jest niekompatybilna
  albo operacyjnie istotna,
- create wymaga `schema_ref`, `direction`, `execution_lane`,
  `compatibility_window` i jawnego planu rollback lub compatibility note.

Read:
- runtime musi umiec pytac:
  - `jaka migracja jest aktywna dla DataSchema`,
  - `czy apply jest gotowy dla danego environment/lane`,
  - `czy otwarty rollback blokuje closure danych`.

Update:
- dozwolone sa tylko status changes:
  - `drafted -> reviewed`
  - `reviewed -> approved | drafted | superseded`
  - `approved -> ready`
  - `ready -> applied`
  - `applied -> rolled-back | superseded`
  - `rolled-back -> superseded`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia blocker projection dla `DataSchema` i downstream scope.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `superseded` albo `rolled-back`,
- `superseded` wymaga `replacement_ref` albo jawnego reason.

### Propagation

- `drafted`:
  - oznacza otwarta zmiane danych bez review,
  - moze blokowac `DataSchema.applied`.
- `reviewed`:
  - odblokowuje gate review dla apply planu.
- `approved`:
  - potwierdza legalnosc planu, ale nie apply window.
- `ready`:
  - oznacza gotowosc wykonania i rollback readiness.
- `applied`:
  - aktualizuje stan danych downstream i moze wymagac closed-loop verification.
- `rolled-back`:
  - utrzymuje trace do rollbacku i moze odblokowac closure recovery.
- `superseded`:
  - wygasza stary plan bez wymazywania historii.

## Invariants

- `DataSchema.applied` bez `MigrationAction.approved` albo jawnego no-op note jest invalid.
- `MigrationAction.ready` wymaga jawnego rollback albo compatibility planu.
- `MigrationAction.applied` bez `ProcessEventRecord` i evidence refs jest invalid.
- `MigrationAction` nie moze zniknac z indeksu po pojawieniu sie audytu.
- `MigrationAction` z `rolled-back` musi miec powiazany `RollbackAction.completed` albo rownowazny recovery evidence.

## Zrodla praktyk

Punkty odniesienia:
- Flyway: migracja jest wersjonowanym krokiem operacyjnym, nie modelem domenowym.
- Liquibase: review/apply/rollback musza byc jawne i sledzalne.
- Martin Fowler Evolutionary Database Design: stan schematu i migracja powinny byc rozroznione.

Linki:
- https://documentation.red-gate.com/fd
- https://www.liquibase.com/blog/database-deployments-and-rollbacks-designing-a-robust-strategy
- https://martinfowler.com/articles/evodb.html
