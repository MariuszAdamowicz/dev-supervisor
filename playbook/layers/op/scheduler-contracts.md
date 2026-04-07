# Scheduler Contracts (kanoniczne)

Cel:
opisac timery i kontrakty czasowe runtime, ktore nie sa OP,
ale sa wymagane do retry, defer, timeout firing i eskalacji.

Timer schedulera nie jest:
- OP z wlasnym entrypointem operatora,
- grafowa relacja miedzy dwoma OP,
- system recordem append-only.

Timer schedulera jest:
- mutowalnym runtime handle zarzadzanym przez scheduler DS,
- powiazaniem miedzy `target_ref` a polityka czasu/retry,
- zrodlem eventu `timeout.fired`.

## Kontrakt wspolny

Kazdy `SchedulerTimer` ma pola:
- `timer_id`
- `target_ref`
- `status`
- `created_at`
- `updated_at`
- `due_at`
- `reason`
- `fire_policy`

Pola opcjonalne:
- `retry_budget`
- `backoff_policy`
- `scope`
- `cancel_reason`
- `consumed_by_event_id`

## Statusy

- `scheduled`: timer oczekuje na odpalenie.
- `fired`: scheduler wyemitowal `timeout.fired`.
- `consumed`: skutki timeoutu zostaly zmaterializowane przez retry, cancel albo escalation.
- `cancelled`: timer zostal wycofany, bo target przeszedl innym legalnym torem.

## CRUD semantics

Create:
- tworz `SchedulerTimer`, gdy defer, retry policy albo SLA wymaga przyszlego zdarzenia czasowego,
- create wymaga `target_ref`, `due_at` albo `backoff_policy`, `reason` i `fire_policy`.

Read:
- runtime musi umiec odpowiedziec:
  - jakie aktywne timery ma `target_ref`,
  - ktory timer wygenerowal `timeout.fired`,
  - czy istnieje aktywny timer blokujacy zamkniecie scope.

Update:
- dozwolone sa tylko:
  - `scheduled -> fired`
  - `scheduled -> cancelled`
  - `fired -> consumed`
- update wymaga `ProcessEventRecord`.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `cancelled` albo `consumed`.

## Invariants

- jeden aktywny (`scheduled`) timer dla tego samego `(target_ref, reason, scope)`,
- `timeout.fired` bez odpowiadajacego `SchedulerTimer(status=fired|consumed)` jest invalid,
- `SchedulerTimer` musi byc cancellowany albo konsumowany po domknieciu target scope,
- timer nie moze sam zmienic stanu OP; moze tylko wyemitowac event do trigger rules.

## Zrodla praktyk

Punkty odniesienia:
- AWS Step Functions Wait state: timeout i wait sa kontrola orkiestracji, nie obiektem biznesowym.
- Azure Durable Functions timers: timery sa trwałymi handle'ami orkiestratora i wymagaja cancel/consume.
- Temporal durable timers: czas i retry musza byc deterministyczne i replayable.

Linki:
- https://docs.aws.amazon.com/step-functions/latest/dg/state-wait.html
- https://learn.microsoft.com/en-us/azure/azure-functions/durable/durable-functions-timers
- https://docs.temporal.io/workflow-definition
