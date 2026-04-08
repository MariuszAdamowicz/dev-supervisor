# Runtime Scheduling Contract

Cel:
opisac, jak DS ma postepowac, gdy jeden event materializuje wiele OP,
controls albo recordow, oraz jak z tego wybrac jeden nastepny krok
bez niekontrolowanej wspolbieznosci.

## 1. Zasady nadrzedne

1. Materialization is mandatory
- jesli trigger rule albo exec spec mowi `utworz`, create jest obowiazkowe.
- brak materializacji wymaganego bytu = runtime invalid.

2. Create != auto-progress
- powstanie OP/control nie uruchamia automatycznie jego kolejnego transition.
- create daje status gotowosci do schedulera, a nie prawo do samoczynnego lancucha przejsc.

3. One state commit per event
- jeden event moze materializowac wiele bytow,
  ale wynik musi byc zapisany jako jeden atomowy commit stanu runtime.
- po commicie scheduler przelicza candidate set od nowa.

4. One primary active step
- dla jednego scope operator otrzymuje dokladnie jeden `primary active step`.
- pozostale byty sa secondary: `pending`, `blocked`, `waiting` albo `running-background`.

5. Deterministic scheduling
- dla tego samego stanu runtime scheduler musi zawsze wybrac ten sam `primary active step`.

6. Concurrency is explicit and limited
- wspolbieznosc techniczna jest dozwolona tylko dla bytow bez konfliktu scope.
- wspolbieznosc nie moze zmieniac kolejnosci decyzji operatora dla tego samego scope.

## 2. Model kandydatow

Po kazdym commicie runtime buduje zbior kandydatow.

Kazdy kandydat ma:
- `subject_ref`
- `subject_kind`
- `current_state`
- `next_transition_ref`
- `scheduling_status`
- `scope_lock`
- `priority_class`
- `blocked_by`
- `created_at`

Dozwolone `scheduling_status`:
- `eligible`
- `blocked`
- `pending-input`
- `waiting`
- `running-background`

Candidate set moze byc:
- wyliczany dynamicznie z runtime graph,
- albo materializowany jako cache/projection.

Cache nie moze byc source of truth.

## 3. Priorytety wyboru

Scheduler nie dziala jako czyste FIFO.

Porzadek priorytetow:
1. safety-integrity
2. blocker-removal
3. primary-journey
4. secondary-maintenance

Tie-breakers:
1. `priority_class`
2. `scope_lock`
3. `created_at`
4. porzadek leksykalny `subject_ref + next_transition_ref`

## 4. Kontrakt projection operatora

UI musi opierac sie na schedulerze.

Wymagania:
- UI pokazuje jeden `primary active step`,
- secondary work moze byc pokazane jako `pending items`,
- audit/debug moze pokazac pelny candidate set, ale nie jako primary task list.

`primary active step` moze byc wybrany tylko z kandydatow:
- `eligible`,
- albo `pending-input`, jesli wymaga danych operatora i nie ma wyzej uplasowanego `eligible`.

## 5. Kontrakt wspolbieznosci

Dozwolone:
- rownolegle AI jobs dla roznych `scope_lock`,
- rownolegle quality lane runs, jesli nie wykonuja konfliktowego write state,
- rownolegle odczyty i projection cache refresh.

Niedozwolone:
- dwa state-changing transitions na tym samym `scope_lock`,
- transition operatora i background write na tym samym `subject_ref`,
- rownolegla aktywacja kilku `primary active step` dla jednego scope operatora.

Kolizja scope zachodzi, gdy dwa kroki dotykaja:
- tego samego `subject_ref`,
- parent/child scope tego samego chain,
- tego samego `Project`, `Feature`, `ChangeSet` albo `ReleaseBundle`.

## 6. Kontrakt materializacji po triggerze

Jesli jeden event tworzy wiele bytow, runtime musi:
1. zapisac wszystkie wymagane create,
2. dopisac `ProcessEventRecord`,
3. zaktualizowac relation graph i reverse lookup,
4. przeliczyc candidate set,
5. wybrac jeden `primary active step`,
6. ujawnic pozostale jako `pending|blocked|waiting`.

Nie wolno:
- tworzyc tylko "najwazniejszego" bytu i pomijac reszty,
- wykonywac automatycznie kolejnych transition tylko dlatego, ze byt powstal,
- pokazywac operatorowi wielu rownorzednych primary step jednoczesnie.

## 7. Automatyka runtime

Automatycznie moga biec tylko kroki, ktore:
- nie wymagaja decyzji operatora,
- nie naruszaja `scope_lock`,
- sa jawnie opisane w exec spec jako background execution,
- zostawiaja audit i deterministic replay.

## 8. Invariants

- create wymagany przez trigger rule jest obowiazkowy,
- `primary active step` ma kardynalnosc `1` per aktywny scope operatora,
- background concurrency z konfliktem scope jest invalid,
- kazdy wybor primary step musi byc odtwarzalny z runtime state,
- scheduler nie moze ukrywac `blocked` scope,
- brak scheduler recompute po state write = invalid.

## 9. Zrodla praktyk

Punkty odniesienia:
- Temporal: workflow jest deterministyczny i replayable.
- Camunda job executor: wiele jobow moze byc gotowych, ale engine kontroluje ich pobieranie i blokady.
- Kubernetes controller pattern: po kazdej zmianie stan jest przeliczany do kolejnego kroku.

Linki:
- https://docs.temporal.io/workflow-definition
- https://docs.camunda.io/docs/components/concepts/job-workers/
- https://kubernetes.io/docs/concepts/architecture/controller/
