# Delivery Contracts (kanoniczne)

Cel:
opisac mutowalne bundle delivery oraz wykonania rolloutu i wdrozenia,
ktore nie sa samodzielnymi OP, ale maja wlasny lifecycle,
powiazanie z ReleaseBundle i EnvironmentTarget oraz wymagania audytowe.

Delivery control nie jest:
- OP z pelnym lifecycle produktu,
- system recordem append-only,
- zwyklym artefaktem deploymentowym.

Delivery control jest:
- mutowalnym bundle delivery albo runtime handle dla konkretnego rolloutu/wdrozenia,
- bytem queryable po release scope, environment i statusie,
- nosnikiem statusu publish/fail/retry.

## Kontrakt wspolny delivery control

Kazdy delivery control ma pola:
- `run_id`
- `release_ref`
- `environment_ref`
- `status`
- `owner`
- `created_at`
- `updated_at`
- `reason`
- `strategy`

Pola opcjonalne:
- `target_revision`
- `retry_budget`
- `retry_count`
- `evidence_refs`
- `rollback_action_ref`

Reguly:
- delivery control musi byc zapisany w runtime index i reverse lookup po `release_ref` oraz `environment_ref`,
- mutacja delivery control wymaga `ProcessEventRecord`,
- brak reverse lookup uniewaznia projection delivery status,
- delivery control nie moze byc primary artefaktem produktu; operator widzi go jako status rolloutu.

## ReleaseBundle

Rola:
opisuje mutowalny bundle delivery grupujacy scope wydania,
gate approval i publish/closure status dla Feature oraz ChangeSet.

Punkty odniesienia:
- GitHub Releases: release jest pakietem zmian i metadanych wydania, a nie bytem produktu.
- Azure release pipelines: release jest jednostka delivery scope przechodzaca przez approval i deployment stages.

### Statusy

- `planned`: bundle istnieje jako kandydat scope, ale nie jest jeszcze gotowy do approval.
- `candidate`: bundle jest przygotowany do gate review i moze wejsc do approval.
- `approved`: bundle przeszedl gate i moze utworzyc `DeploymentRun`.
- `published`: bundle zostal skutecznie opublikowany po sukcesie rollout.
- `closed`: bundle jest domkniety i pozostaje w audycie.

### CRUD semantics

Create:
- tworz `ReleaseBundle`, gdy `Feature.stabilized` i scope delivery jest jawnie wyznaczony,
- create wymaga `release_ref`, `reason`, `environment_ref` albo jawnego `delivery_scope_ref`.

Read:
- runtime musi umiec pytac:
  - `jaki bundle delivery jest aktywny dla feature lub changeset`,
  - `czy bundle jest approved/published/closed`,
  - `jakie bundle waiting na rollout albo closure`.

Update:
- dozwolone sa tylko status changes:
  - `planned -> candidate`
  - `candidate -> approved | planned | closed`
  - `approved -> published | candidate`
  - `published -> closed | published`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia projection delivery status dla powiazanych Feature.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `closed`,
- `closed` wymaga jawnego reason i wskazania closure path.

### Propagation

- `planned`:
  - utrzymuje bundle poza gate delivery.
- `candidate`:
  - otwiera gate approval dla delivery scope.
- `approved`:
  - odblokowuje `DeploymentRun.planned`.
- `published`:
  - odblokowuje `Feature.released`.
- `closed`:
  - domyka delivery scope i pozostaje w audycie.

## DeploymentRun

Rola:
opisuje pojedyncze wykonanie rolloutu albo wdrozenia
dla konkretnego `ReleaseBundle` i `EnvironmentTarget`.

Punkty odniesienia:
- Kubernetes Deployment controller: rollout ma wlasny status, rewizje i warunki postepu.
- Deployment run jest wykonaniem runtime, a nie bytem produktowym.

### Statusy

- `planned`: rollout zostal zaplanowany, ale jeszcze sie nie wykonuje.
- `running`: rollout jest wykonywany.
- `succeeded`: rollout zakonczyl sie sukcesem i moze odblokowac `ReleaseBundle.published`.
- `failed`: rollout nie zakonczyl sie sukcesem; wymaga retry albo recovery path.
- `cancelled`: rollout zostal przerwany legalna decyzja i ma jawny reason.

### CRUD semantics

Create:
- tworz `DeploymentRun`, gdy `ReleaseBundle.approved`
  i runtime ma rozpoczac rollout dla okreslonego `EnvironmentTarget`,
- create wymaga `release_ref`, `environment_ref`, `strategy`
  oraz `target_revision` albo rownowaznego deployment payload ref.

Read:
- runtime musi umiec pytac:
  - `jaki deployment run jest aktywny dla release`,
  - `jaki jest status rolloutu dla srodowiska`,
  - `jakie failed deployment runs blokuja publikacje`.

Update:
- dozwolone sa tylko status changes:
  - `planned -> running | cancelled`
  - `running -> succeeded | failed | cancelled`
  - `failed -> planned | cancelled`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia projection delivery status dla release.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `succeeded` albo `cancelled`,
- `cancelled` wymaga jawnego reason i wskazania, jaka decyzja przerwala rollout.

### Propagation

- `planned`:
  - pokazuje oczekujacy rollout dla release bundle,
  - blokuje `ReleaseBundle.published` do czasu startu i wyniku.
- `running`:
  - pokazuje aktywny rollout,
  - blokuje closure release do czasu wyniku.
- `succeeded`:
  - odblokowuje `ReleaseBundle.published`,
  - zachowuje trace do `target_revision` i evidence.
- `failed`:
  - cofa bundle do `candidate` albo uruchamia recovery path,
  - moze tworzyc `RollbackAction`.
- `cancelled`:
  - nie publikuje release i wymaga osobnej legalnej sciezki closure.

## Invariants

- `DeploymentRun` musi wskazywac `release_ref`, `environment_ref` i `strategy`,
- `ReleaseBundle.approved` bez aktywnego lub succeeded `DeploymentRun` jest invalid,
- `deployment.started|completed|failed` bez aktywnego `DeploymentRun` jest invalid,
- `failed` albo `cancelled` bez `ProcessEventRecord` i jawnego reason jest invalid,
- delivery control nie moze zniknac z indeksu po pojawieniu sie audytu.

## Zrodla praktyk

Linki:
- https://kubernetes.io/docs/concepts/workloads/controllers/deployment/
- https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository
- https://learn.microsoft.com/en-us/azure/devops/pipelines/release/what-is-release-management
