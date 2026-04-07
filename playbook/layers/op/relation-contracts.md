# Relation Contracts (kanoniczne)

Cel:
opisac mutowalne relacje grafu OP, ktore nie sa samodzielnymi OP,
ale maja wlasne pola, statusy, propagation i wymagania CRUD.

Relacja grafu nie jest:
- OP z pelnym lifecycle i osobnym entrypointem operatora,
- system recordem append-only.

Relacja grafu jest:
- krawedzia miedzy OP lub miedzy OP a `external_ref`,
- bytem mutowalnym przechowywanym w relation index i reverse relation index,
- nosnikiem propagation, impacted scope i rule enforcement.

## Kontrakt wspolny relacji

Kazda relacja grafu ma pola:
- `relation_id`
- `relation_type`
- `source_ref`
- `target_ref` albo `external_ref`
- `status`
- `owner`
- `created_at`
- `updated_at`
- `reason`
- `criticality`
- `tags`

Pola opcjonalne:
- `scope` (`code | build | runtime | delivery | organizational`)
- `blocking_scope`
- `evidence_refs`
- `waiver_ref`
- `replacement_ref`

Reguly:
- relacja ma zawsze jeden source i jeden target albo `external_ref`,
- relacja musi byc zapisana w `relation-index` i `reverse-relation-index`,
- mutacja relacji wymaga `ProcessEventRecord`,
- brak reverse lookup uniewaznia propagation contract.

## DependencyRelation

Rola:
opisuje, ze `source_ref` zalezy od `target_ref` albo `external_ref`
i ze ta zaleznosc moze blokowac lub zmieniac downstream runtime.

Przyklady:
- `Feature` zalezy od zewnetrznego API,
- `Release` zalezy od gotowosci `RuntimeEnvironment`,
- `Component` zalezy od innego `Component`,
- `ChangeSet` zalezy od migracji danych lub approval policy.

### Statusy

- `active`: zaleznosc istnieje i jest obserwowana, ale nie blokuje.
- `blocked`: zaleznosc aktywnie blokuje source i downstream.
- `satisfied`: zaleznosc zostala domknieta dla danego scope.
- `waived`: zaleznosc jest swiadomie pozostawiona, ale nie blokuje; wymaga jawnego uzasadnienia.
- `retired`: historyczna relacja zachowana dla audytu; nie bierze udzialu w biezacej propagacji.

### CRUD semantics

Create:
- tworz `DependencyRelation`, gdy source nie moze byc poprawnie oceniony lub wykonany bez target/external capability,
- create wymaga `source_ref`, `target_ref|external_ref`, `criticality`, `scope` i `reason`.

Read:
- runtime musi umiec pytac:
  - `od czego zalezy X`,
  - `co zalezy od X`,
  - `jakie blokujace zaleznosci ma scope release/feature/component`.

Update:
- dozwolone sa tylko status changes:
  - `active -> blocked | satisfied | waived | retired`
  - `blocked -> active | satisfied | waived | retired`
  - `waived -> active | retired`
  - `satisfied -> retired`
- update wymaga `reason`, `actor`, `ProcessEventRecord` i propagation downstream.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `retired`,
- `retired` musi zachowac `replacement_ref` albo reason braku replacement.

### Propagation

- `blocked`:
  - blokuje `source_ref`,
  - moze blokowac downstream OP zalezne od `source_ref`,
  - musi pojawic sie w projection operatora jako blocker.
- `satisfied`:
  - usuwa blokade tylko wtedy, gdy brak innych `blocked` dependency relations dla tego samego scope.
- `waived`:
  - nie blokuje,
  - wymaga `GateDecisionRecord` albo `DecisionRecord` jako uzasadnienia.
- `retired`:
  - nie bierze udzialu w biezacej walidacji,
  - pozostaje w audycie i reverse lookup historii.

## Invariants

- brak duplikatow `active|blocked` dla tego samego `(source_ref, target_ref|external_ref, scope)`,
- dependency relations komponentow nie moga obchodzic `dependency direction` i `no-cycle`,
- `blocked` relation o `criticality=high|critical` musi byc widoczna w guardach Release/Deployment,
- relacja `waived` bez `waiver_ref` jest invalid.

## Zrodla praktyk

Punkty odniesienia:
- Neo4j graph concepts: relacje sa skierowane, typowane i moga miec wlasne properties.
- Bazel query language: dependency graph jest podstawowym modelem do analizy zaleznosci i DAG.
- Nx affected: reverse dependency lookup jest potrzebny do wyliczania impacted scope po zmianie upstream.

Linki:
- https://neo4j.com/docs/getting-started/appendix/graphdb-concepts/
- https://bazel.build/versions/8.0.0/query/language
- https://nx.dev/docs/features/ci-features/affected
