# Recovery Contracts (kanoniczne)

Cel:
opisac mutowalne mechanizmy odzyskiwania i undo,
ktore nie sa samodzielnymi OP, ale maja wlasne pola, statusy i audit.

Recovery control nie jest:
- OP z pelnym lifecycle i osobnym entrypointem operatora,
- system recordem append-only,
- zwyklym artefaktem tekstowym.

Recovery control jest:
- mutowalnym runtime handle po awarii, rollbacku albo nieudanym kroku z side effect,
- bytem queryable po target scope i statusie,
- nosnikiem decyzji undo/cleanup i downstream unblock.

## Kontrakt wspolny recovery control

Kazdy recovery control ma pola:
- `recovery_id`
- `recovery_type`
- `target_ref`
- `status`
- `owner`
- `created_at`
- `updated_at`
- `reason`
- `action_plan`

Pola opcjonalne:
- `source_exception_ref`
- `source_deployment_ref`
- `source_migration_ref`
- `retry_budget`
- `evidence_refs`
- `replacement_ref`

Reguly:
- recovery control musi byc zapisany w runtime index i reverse lookup po `target_ref`,
- mutacja recovery control wymaga `ProcessEventRecord`,
- brak reverse lookup uniewaznia propagation contract,
- recovery control nie moze byc primary UI; operator widzi go jako blocker albo recovery status.

## CompensationAction

Rola:
opisuje aplikacyjnie specyficzny krok undo albo cleanup po awarii,
gdy zwykly retry albo rollback nie wystarcza.

Przyklady:
- wycofanie czesciowo utworzonych artefaktow projektu,
- cleanup side effects po przerwanym wdrozeniu,
- przywrocenie spojnosc po nieudanej migracji danych,
- domkniecie compensating transaction po bledzie procesu.

### Statusy

- `planned`: recovery zostalo zaplanowane, ale jeszcze sie nie wykonuje.
- `running`: recovery jest wykonywane.
- `completed`: recovery zakonczone i target scope moze byc odblokowany.
- `failed`: recovery nie domknelo target scope; wymaga eskalacji albo retry.
- `cancelled`: recovery zostalo przerwane legalna alternatywna sciezka i ma jawny reason.

### CRUD semantics

Create:
- tworz `CompensationAction`, gdy `Exception.compensation_required=true`
  albo failure policy wskazuje jawne undo/cleanup,
- create wymaga `target_ref`, `reason`, `action_plan`
  i przynajmniej jednego `source_*_ref` albo jawnego `external_ref` w evidence.

Read:
- runtime musi umiec pytac:
  - `jakie recovery controls sa aktywne dla X`,
  - `czy Exception lub RollbackAction maja otwarte compensation`,
  - `jakie failed compensation blokuja closure target scope`.

Update:
- dozwolone sa tylko status changes:
  - `planned -> running | cancelled`
  - `running -> completed | failed | cancelled`
  - `failed -> planned | cancelled`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia blocker projection dla target scope.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `completed` albo `cancelled`,
- `cancelled` wymaga jawnego reason i decyzji, dlaczego recovery nie jest dalej potrzebne.

### Propagation

- `planned`:
  - oznacza otwarty recovery requirement,
  - utrzymuje target scope jako `needs-recovery` albo rownowazny blocker.
- `running`:
  - utrzymuje blocker do czasu `completed` albo `failed`.
- `completed`:
  - odblokowuje closure `Exception`, `RollbackAction`, `Migration` albo innego target scope,
  - nie usuwa audytu ani dowodu przyczyny.
- `failed`:
  - wymaga eskalacji operatora albo nowej decyzji gate,
  - moze utrzymac Exception w stanie `escalated`.
- `cancelled`:
  - nie odblokowuje scope automatycznie; wymaga osobnej legalnej sciezki closure.

## Dodatkowe invarianty RollbackAction

- `RollbackAction` musi wskazywac `target_ref`, `reason` i `target_revision`,
- `Deployment.failed` albo `Migration.rollback-requested` bez aktywnego lub completed `RollbackAction` jest invalid,
- `failed` albo `cancelled` bez `ProcessEventRecord` i jawnego reason jest invalid,
- rollback control nie moze zniknac z indeksu po pojawieniu sie audytu.

## Invariants

- `CompensationAction` musi wskazywac `target_ref` i `reason`,
- `Exception.compensation_required=true` bez aktywnego lub completed `CompensationAction` jest invalid,
- `failed` albo `cancelled` bez `ProcessEventRecord` i jawnego reason jest invalid,
- recovery control nie moze zniknac z indeksu po pojawieniu sie audytu.

## RollbackAction

Rola:
opisuje kontrolowane cofniecie deploymentu albo migracji
do poprzedniej stabilnej rewizji lub kompatybilnego stanu.

Przyklady:
- rollout undo po nieudanym deploymentcie,
- wycofanie zmiany danych do poprzedniego okna kompatybilnosci,
- revert runtime po przekroczeniu deployment deadline albo awarii rollout controller.

### Statusy

- `planned`: rollback zostal zaplanowany, ale jeszcze sie nie wykonuje.
- `running`: rollback jest wykonywany.
- `completed`: rollback zakonczony i target scope zostal przywrocony.
- `failed`: rollback nie przywrocil stabilnego stanu; wymaga eskalacji albo retry.
- `cancelled`: rollback nie jest dalej potrzebny, bo target scope zostal zamkniety inna legalna sciezka.

### CRUD semantics

Create:
- tworz `RollbackAction`, gdy `Deployment.failed`
  albo migration policy wymaga revert,
- create wymaga `target_ref`, `reason`, `target_revision`
  i `source_deployment_ref` albo `source_migration_ref`.

Read:
- runtime musi umiec pytac:
  - `czy Deployment lub Migration ma otwarty rollback`,
  - `jaki jest target revision i status rollback`,
  - `jakie failed rollbacki blokuja release closure`.

Update:
- dozwolone sa tylko status changes:
  - `planned -> running | cancelled`
  - `running -> completed | failed | cancelled`
  - `failed -> planned | cancelled`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia blocker projection dla target scope.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `completed` albo `cancelled`,
- `cancelled` wymaga jawnego reason i wskazania, jaka inna sciezka recovery zamknela target.

### Propagation

- `planned`:
  - utrzymuje target scope jako `rollback-pending`,
  - blokuje closure Release/Deployment/Migration, jesli policy tego wymaga.
- `running`:
  - utrzymuje blocker do czasu `completed` albo `failed`.
- `completed`:
  - odblokowuje closure `Deployment` albo `Migration`,
  - zachowuje trace do target revision i eventow wykonania.
- `failed`:
  - wymaga eskalacji operatora albo nowej decyzji gate,
  - moze utrzymac `Deployment` lub `Migration` w stanie zablokowanym.
- `cancelled`:
  - nie odblokowuje scope automatycznie; wymaga osobnej legalnej sciezki closure.

## Zrodla praktyk

Punkty odniesienia:
- Azure Compensating Transaction: kompensacja jest jawna, aplikacyjnie specyficzna i nie jest automatycznym rollbackiem.
- Microservices.io Saga: tylko kroki, po ktorych moze nastapic biznesowa porazka, potrzebuja compensation.
- Kubernetes Deployment rollout undo: rollback jest operacja kontrolera odnoszaca sie do rewizji deploymentu i eventow rollout, nie samodzielnym artefaktem produktu.

Linki:
- https://learn.microsoft.com/en-us/azure/architecture/patterns/compensating-transaction
- https://microservices.io/post/microservices/2019/07/09/developing-sagas-part-1.html
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
