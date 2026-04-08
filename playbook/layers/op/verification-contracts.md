# Verification Contracts (kanoniczne)

Cel:
opisac mutowalna polityke lane testowych, evidence i provenance
dla scope formalnej walidacji, bez sztucznego modelowania jej jako OP pracy.

Verification control nie jest:
- OP z pelnym lifecycle produktu,
- system recordem append-only,
- jednorazowym raportem quality lane.

Verification control jest:
- jawna polityka walidacji dla `Feature`, `ChangeSet` albo `ReleaseBundle`,
- queryable kontrola mapowania lane -> target scope,
- nosnikiem zmian polityki testowej, evidence provenance i pass criteria.

## Kontrakt wspolny verification control

Kazda `VerificationPolicy` ma pola:
- `policy_id`
- `target_scope`
- `required_lanes`
- `pass_criteria`
- `evidence_rules`
- `status`
- `created_at`
- `updated_at`
- `owner`

Pola opcjonalne:
- `capability_map`
- `not_applicable_lanes`
- `replacement_ref`
- `reason`
- `context_refs`

Reguly:
- `VerificationPolicy` musi byc zapisany w runtime index i reverse lookup po `target_scope`,
- mutacja `VerificationPolicy` wymaga `ProcessEventRecord`,
- brak reverse lookup uniewaznia projection quality scope,
- `VerificationPolicy` nie moze byc jedynym dowodem quality; definiuje wymagania, nie zastepuje evidence.

## VerificationPolicy

Rola:
opisuje, jakie lane testowe i jakie evidence sa wymagane
dla danego scope formalnej walidacji.

Punkty odniesienia:
- Practical Test Pyramid: rozne warstwy testow maja rozna role i koszt.
- Continuous Delivery / evidence-based gating: policy lane musi byc jawna i powtarzalna.

### Statusy

- `drafted`: polityka zostala utworzona, ale nie przeszla review.
- `reviewed`: lane i evidence zostaly przygotowane do decyzji gate.
- `approved`: polityka jest zaakceptowana i gotowa do aktywacji.
- `active`: polityka obowiazuje dla biezacego scope.
- `revised`: polityka wymaga ponownej akceptacji po zmianie ryzyka, stacku lub delivery lane.
- `retired`: polityka zostala zastapiona albo scope zostal zamkniety.

### CRUD semantics

Create:
- tworz `VerificationPolicy`, gdy projekt ma `formal-validation`,
  przy baseline albo przy nowym scope wymagajacym odrebnych lane/evidence,
- create wymaga `target_scope`, `required_lanes`, `pass_criteria` i `evidence_rules`.

Read:
- runtime musi umiec pytac:
  - `jaka polityka walidacji obowiazuje dla X`,
  - `jakie lane sa wymagane albo oznaczone jako not_applicable`,
  - `czy scope ma aktywna polityke formalnej walidacji`.

Update:
- dozwolone sa tylko status changes:
  - `drafted -> reviewed`
  - `reviewed -> approved | drafted | reviewed | retired`
  - `approved -> active`
  - `active -> revised`
  - `revised -> approved | revised | retired`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia projection quality scope dla target.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `retired`,
- `retired` wymaga jawnego `replacement_ref` albo powodu zamkniecia scope.

### Propagation

- `drafted`:
  - pokazuje pending review dla quality scope,
  - nie odblokowuje jeszcze lane-required transition.
- `reviewed`:
  - odblokowuje gate approval polityki,
  - wymaga jawnego review package dla lane matrix i evidence rules.
- `approved`:
  - pozwala aktywowac polityke dla scope.
- `active`:
  - ustala legalny zestaw lane i provenance dla `Feature`, `ChangeSet` albo `ReleaseBundle`,
  - blokuje quality-sensitive transition, jesli wymagane lane nie sa zgodne z polityka.
- `revised`:
  - sygnalizuje invalidation downstream i wymaga ponownej akceptacji przed dalszym uzyciem.
- `retired`:
  - nie odblokowuje nowych transition dla scope,
  - pozostaje w audycie i traceability historycznej.

## Invariants

- `VerificationPolicy` musi wskazywac `target_scope`, `required_lanes`, `pass_criteria` i `evidence_rules`,
- `approved` albo `active` bez mapowania lane -> capability albo `not_applicable` jest invalid,
- `active` bez reverse lookup z `Feature`, `ChangeSet` albo `ReleaseBundle` jest invalid,
- `retired` bez `replacement_ref` albo jawnego `reason` jest invalid,
- polityka nie moze zniknac z indeksu po pojawieniu sie audytu.

## Zrodla praktyk

Linki:
- https://martinfowler.com/articles/practical-test-pyramid.html
- https://minimumcd.org/minimumcd/
