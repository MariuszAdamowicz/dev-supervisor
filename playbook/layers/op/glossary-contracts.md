# Glossary Contracts (kanoniczne)

Cel:
opisac mutowalne wpisy slownika domenowego,
ktore nie sa samodzielnymi OP, ale maja jawny status,
impact na copy/UX/scenariusze i audit.

Glossary control nie jest:
- OP z pelnym lifecycle produktu,
- system recordem append-only,
- zwyklym akapitem w `glossary.md` bez sledzalnego statusu.

Glossary control jest:
- mutowalnym wpisem slownika domenowego i UX,
- bytem queryable po terminie, aliasach i impacted scope,
- nosnikiem decyzji akceptacji, deprecjacji i replacement.

## Kontrakt wspolny glossary control

Kazdy glossary control ma pola:
- `entry_id`
- `term`
- `definition`
- `status`
- `owner`
- `created_at`
- `updated_at`
- `reason`

Pola opcjonalne:
- `aliases`
- `source_ref`
- `replacement_ref`
- `impacted_scope_refs`
- `evidence_refs`

Reguly:
- glossary control musi byc zapisany w runtime index i reverse lookup po `term` oraz `impacted_scope_refs`,
- mutacja glossary control wymaga `ProcessEventRecord`,
- brak reverse lookup uniewaznia projection copy impacts dla UI/scenario scope,
- glossary control nie moze byc schowany, gdy blokuje UX alignment albo wymaga deprecjacji copy.

## GlossaryEntry

Rola:
opisuje pojedynczy wpis slownika domenowego
uzywany w copy, UX i scenariuszach.

Punkty odniesienia:
- Martin Fowler Ubiquitous Language: jezyk domeny musi byc wspolny dla kodu, rozmowy i artefaktow.
- Microsoft Writing Style Guide: terminologia powinna byc konsekwentna i zarzadzana centralnie.

### Statusy

- `proposed`: wpis zostal odkryty albo zaproponowany, ale nie jest jeszcze kanoniczny.
- `approved`: wpis jest kanoniczny i moze byc uzywany w copy/UX/scenario.
- `deprecated`: wpis nie powinien byc juz uzywany i wymaga replacement albo cleanup.

### CRUD semantics

Create:
- tworz `GlossaryEntry`, gdy pojawia sie nowe pojecie domenowe, nowy label UX albo nowy termin scenariusza,
- create wymaga `term`, `definition` i co najmniej jednego `impacted_scope_ref`.

Read:
- runtime musi umiec pytac:
  - `jakie wpisy glossary sa aktywne dla danego feature`,
  - `jakie wpisy sa deprecated i wymagaja cleanup copy`,
  - `jakie aliasy albo replacement refs dotycza danego scope`.

Update:
- dozwolone sa tylko status changes:
  - `proposed -> approved | proposed | deprecated`
  - `approved -> deprecated | approved`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia projection copy impacts dla impacted scope.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `deprecated`,
- `deprecated` wymaga jawnego reason i wskazania `replacement_ref`, gdy nowy termin zastapil stary.

### Propagation

- `proposed`:
  - wymaga review impactu na UI/scenario/copy,
  - moze blokowac `Feature.ux-aligned`, jesli nowy termin nie zostal jeszcze jawnie rozstrzygniety.
- `approved`:
  - odblokowuje copy i projekcje UX dla impacted scope.
- `deprecated`:
  - wymaga cleanup copy, scenariuszy albo replacement w impacted scope,
  - nie znika z audytu i musi pozostac queryable.

## Invariants

- `GlossaryEntry` musi wskazywac `term`, `definition` i `impacted_scope_refs`,
- `approved` bez jawnego `definition` jest invalid,
- `deprecated` bez `ProcessEventRecord` i jawnego reason jest invalid,
- `deprecated` z replacement, ale bez `replacement_ref`, jest invalid,
- glossary control nie moze zniknac z indeksu po pojawieniu sie audytu.

## Zrodla praktyk

Linki:
- https://martinfowler.com/bliki/UbiquitousLanguage.html
- https://learn.microsoft.com/en-us/style-guide/a-z-word-list-term-collections/term-collections
