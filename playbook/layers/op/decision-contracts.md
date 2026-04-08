# Decision Contracts (kanoniczne)

Cel:
opisac mutowalny rekord decyzji architektonicznej albo produktowej,
bez sztucznego utrzymywania go jako OP pracy.

Decision control nie jest:
- OP z pelnym lifecycle produktu,
- system recordem append-only,
- jednorazowa notatka bez skutkow downstream.

Decision control jest:
- jawna decyzja z kontekstem, opcjami i konsekwencjami,
- queryable kontrola dla baseline, architektury i delivery scope,
- bytem supersedowanym, a nie nadpisywanym.

## Kontrakt wspolny decision control

Kazdy `DecisionRecord` ma pola:
- `decision_id`
- `title`
- `context`
- `options_considered`
- `selected_option`
- `consequence`
- `status`
- `created_at`
- `updated_at`
- `owner`

Pola opcjonalne:
- `supersedes_ref`
- `replacement_ref`
- `scope_refs`
- `reason`
- `evidence_refs`

Reguly:
- `DecisionRecord` musi byc zapisany w runtime index i reverse lookup po `scope_refs`,
- mutacja `DecisionRecord` wymaga `ProcessEventRecord`,
- supersede musi zachowac trace do poprzedniej decyzji,
- decyzja nie moze byc cicho edytowana po approval.

## DecisionRecord

Rola:
opisuje pojedyncza decyzje architektoniczna albo produktowa
z jawna sciezka review i supersede.

Punkty odniesienia:
- Martin Fowler ADR: jedna decyzja na rekord, supersede zamiast rewrite history.
- adr.github.io: ADR powinien byc lekki, jawny i powiazany z kontekstem decyzji.

### Statusy

- `drafted`: decyzja jest przygotowywana.
- `reviewed`: material do decyzji jest gotowy do gate.
- `approved`: decyzja obowiazuje downstream.
- `superseded`: decyzja zostala zastapiona albo jawnie odrzucona.

### CRUD semantics

Create:
- tworz `DecisionRecord`, gdy baseline albo zmiana architektury wymaga jawnego wyboru,
- create wymaga `context`, `options_considered` i `selected_option`.

Read:
- runtime musi umiec pytac:
  - `jakie decyzje obowiazuja dla danego scope`,
  - `ktora decyzja superseduje poprzednia`,
  - `czy scope ma decyzje wymagane przed dalszym transition`.

Update:
- dozwolone sa tylko status changes:
  - `drafted -> reviewed`
  - `reviewed -> approved | drafted | reviewed | superseded`
  - `approved -> superseded | approved`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia traceability dla impacted scope.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `superseded`,
- `superseded` wymaga `replacement_ref` albo jawnego powodu odrzucenia.

### Propagation

- `drafted`:
  - pokazuje pending review dla decision scope,
  - nie odblokowuje jeszcze guardow downstream.
- `reviewed`:
  - odblokowuje gate approval decyzji,
  - wymaga review package z opcjami i konsekwencjami.
- `approved`:
  - staje sie aktywna podstawa dla Requirement/Feature/Component/ReleaseBundle zaleznych od scope.
- `superseded`:
  - uniewaznia stare uzasadnienie downstream,
  - wymaga jawnej propagacji do impacted scope.

## Invariants

- `DecisionRecord` musi wskazywac `context`, `options_considered`, `selected_option` i `consequence`,
- `approved` bez review package albo bez `selected_option` jest invalid,
- `superseded` bez `replacement_ref` albo jawnego `reason` jest invalid,
- decyzja nie moze zniknac z indeksu po pojawieniu sie audytu.

## Zrodla praktyk

Linki:
- https://martinfowler.com/bliki/ArchitectureDecisionRecord.html
- https://adr.github.io/
