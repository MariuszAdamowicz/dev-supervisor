# Version Control Contracts (kanoniczne)

Cel:
opisac mutowalne controls VCS,
ktore nie sa OP, ale maja wlasne pola, statusy, propagation i audit.

Version-control control nie jest:
- OP produktowym,
- samym folderem `.git`,
- system recordem append-only.

Version-control control jest:
- mutowalnym handle stanu repozytorium i polityki pracy w VCS,
- bytem queryable po `local_root`, `remote_origin`, `default_branch` i `status`,
- nosnikiem blokad dla `ChangeSet`, gdy repo nie jest gotowe albo policy jest niespojna.

## Kontrakt wspolny version-control control

Kazdy control VCS ma pola:
- `repo_id`
- `vcs`
- `status`
- `owner`
- `created_at`
- `updated_at`
- `local_root`
- `branch_policy`
- `cleanliness`

Pola opcjonalne:
- `remote_origin`
- `default_branch`
- `divergence_state`
- `evidence_refs`
- `replacement_ref`

Reguly:
- control VCS musi byc zapisany w runtime index i reverse lookup po `local_root`,
- mutacja control wymaga `ProcessEventRecord`,
- brak reverse lookup do `ChangeSet` uniewaznia traceability contract,
- control VCS nie moze byc primary UI; operator widzi go jako readiness albo blocker dla pracy w kodzie.

## Repository

Rola:
opisuje stan lokalnego repo, powiazania remote i aktywnej polityki VCS
dla projektu zarzadzanego przez DS.

### Statusy

- `detected`: DS rozpoznal root repozytorium, ale repo nie jest jeszcze zainicjalizowane lub nie ma potwierdzonego scope.
- `initialized`: lokalne repo istnieje i ma minimalna konfiguracje.
- `remote-attached`: repo ma jawnie przypiety remote.
- `policy-aligned`: repo spelnia polityke branch/commit i jest gotowe do pracy.
- `active`: repo jest aktywne dla biezacego scope projektu.
- `archived`: repo nie bierze juz udzialu w aktywnym workflow.

### CRUD semantics

Create:
- tworz `Repository`, gdy projekt pracuje w `version-controlled`,
- create wymaga `local_root`, `vcs` i minimalnej polityki branch/commit.

Read:
- runtime musi umiec pytac:
  - `czy projekt ma aktywne repo`,
  - `czy repo ma przypiety remote i policy-aligned`,
  - `czy jakis ChangeSet jest zablokowany przez stan repo`.

Update:
- dozwolone sa tylko status changes:
  - `detected -> initialized`
  - `initialized -> remote-attached`
  - `remote-attached -> policy-aligned | archived`
  - `policy-aligned -> active`
  - `active -> archived`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia blocker projection dla powiazanych `ChangeSet`.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `archived`,
- `archived` wymaga jawnego reason i zachowania historii commit scope.

### Propagation

- `detected`:
  - odblokowuje bootstrap review repo.
- `initialized`:
  - odblokowuje attach remote.
- `remote-attached`:
  - odblokowuje policy review.
- `policy-aligned`:
  - odblokowuje `ChangeSet.staged` i commit workflow.
- `active`:
  - oznacza repo gotowe dla biezacej pracy.
- `archived`:
  - blokuje nowe `ChangeSet`, ale nie usuwa historii.

## Invariants

- `ChangeSet.staged|validated|committed` bez `Repository.status in {policy-aligned, active}` jest invalid.
- `Repository.remote-attached` bez jawnego `remote_origin` jest invalid.
- `Repository.policy-aligned` bez zapisanej polityki branch/commit jest invalid.
- `Repository` nie moze zniknac z indeksu po pojawieniu sie audytu.

## Zrodla praktyk

Punkty odniesienia:
- Git SCM book: repozytorium i workflow branch/remote sa jawnym stanem pracy.
- Trunk-Based Development: polityka branch i integracji musi byc jawna i lekka.
- Conventional Commits: polityka commit message jest elementem kontraktu zespolu/toolingu.

Linki:
- https://git-scm.com/book/en/v2
- https://trunkbaseddevelopment.com/
- https://www.conventionalcommits.org/en/v1.0.0/
