# Job Contracts (kanoniczne)

Cel:
opisac mutowalne zadania runtime uruchamiane przez ai-runner
albo operatora review, ktore nie sa samodzielnymi OP,
ale maja wlasny lifecycle, retry i audit.

Job control nie jest:
- OP z pelnym lifecycle produktu,
- system recordem append-only,
- artefaktem dokumentacyjnym.

Job control jest:
- runtime handle dla pracy delegowanej do AI lub operatora,
- bytem queryable po target scope, statusie i task type,
- nosnikiem retry, timeout i acceptance output.

## Kontrakt wspolny job control

Kazdy job control ma pola:
- `task_id`
- `task_type`
- `target_ref`
- `status`
- `owner`
- `created_at`
- `updated_at`
- `reason`
- `context_refs`

Pola opcjonalne:
- `assignee_mode`
- `retry_budget`
- `retry_count`
- `prompt_template`
- `evidence_refs`
- `replacement_ref`

Reguly:
- job control musi byc zapisany w runtime index i reverse lookup po `target_ref`,
- mutacja job control wymaga `ProcessEventRecord`,
- brak reverse lookup uniewaznia projection pending work,
- job control moze byc primary UI tylko jako next work item, nie jako artefakt produktu.

## PromptTask

Rola:
opisuje runtime work item AI albo review task operatora,
ktory ma jawny kontekst, retry i acceptance path.

Punkty odniesienia:
- Camunda service task: po wejsciu do taska proces czeka na wykonanie joba.
- Camunda user task: instancja taska reprezentuje prace czlowieka wspierana przez workflow engine.

### Statusy

- `created`: task zostal utworzony, ale kontekst nie jest jeszcze gotowy.
- `ready`: task ma gotowy kontekst i moze byc uruchomiony.
- `executed`: job zwrocil wynik albo operator dostarczyl material do review.
- `validated`: wynik zostal zaakceptowany po review/gate.
- `closed`: task zostal jawnie domkniety.
- `cancelled`: task zakonczono bez dalszego wykonania, z jawna przyczyna.

### CRUD semantics

Create:
- tworz `PromptTask`, gdy trigger rules wymagaja AI promptu,
  review package albo jawnego rework/debug taska,
- create wymaga `target_ref`, `task_type`, `context_refs`
  i `assignee_mode` (`ai-runner` albo `operator-review`).

Read:
- runtime musi umiec pytac:
  - `jakie job controls sa otwarte dla X`,
  - `czy target scope ma krytyczne pending PromptTask`,
  - `jakie PromptTask sa po timeout/retry`.

Update:
- dozwolone sa tylko status changes:
  - `created -> ready`
  - `ready -> executed | cancelled | ready`
  - `executed -> validated | ready | executed | cancelled`
  - `validated -> closed`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia projection pending work dla target scope.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `closed` albo `cancelled`,
- `cancelled` wymaga jawnego reason i ewentualnego replacement taska.

### Propagation

- `created|ready`:
  - pokazuje pending work dla target scope,
  - moze blokowac closure target OP, jesli task jest krytyczny.
- `executed`:
  - oczekuje walidacji albo decyzji gate,
  - moze tworzyc review package i dalsze retry/rework.
- `validated`:
  - odblokowuje wynik taska jako legalny input downstream.
- `closed`:
  - usuwa pending work blocker, ale zachowuje audit.
- `cancelled`:
  - wymaga jawnego reason i nie odblokowuje downstream automatycznie,
    jesli trigger rules oczekuja replacement taska albo ExceptionCase.

## Invariants

- `PromptTask` musi wskazywac `target_ref`, `task_type` i `assignee_mode`,
- `prompt.sent` albo `prompt.validation-requested` bez aktywnego `PromptTask` jest invalid,
- `cancelled` albo `closed` bez `ProcessEventRecord` i jawnego reason jest invalid,
- job control nie moze zniknac z indeksu po pojawieniu sie audytu.

## Zrodla praktyk

Linki:
- https://docs.camunda.io/docs/components/modeler/bpmn/service-tasks/
- https://docs.camunda.io/docs/components/modeler/bpmn/user-tasks/
