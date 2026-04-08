# Authz Contracts (kanoniczne)

Cel:
opisac mutowalne zasady autoryzacji i ownership,
ktore nie sa samodzielnymi OP, ale maja jawny status,
scope, audit i wplyw na legalnosc transition.

Authz control nie jest:
- OP z pelnym lifecycle produktu,
- system recordem append-only,
- ukryta konfiguracja zaszyta w kodzie lub UI.

Authz control jest:
- mutowalnym grantem/polityka autoryzacji dla operatora albo roli,
- bytem queryable po principal, scope, action i statusie,
- nosnikiem zasad `deny-by-default`, least privilege i explicit allow.

## Kontrakt wspolny authz control

Kazdy authz control ma pola:
- `grant_id`
- `principal_ref`
- `role_ref`
- `scope_ref`
- `allowed_actions`
- `status`
- `owner`
- `created_at`
- `updated_at`
- `reason`

Pola opcjonalne:
- `constraint_refs`
- `replacement_ref`
- `evidence_refs`

Reguly:
- authz control musi byc zapisany w runtime index i reverse lookup po `principal_ref` oraz `scope_ref`,
- mutacja authz control wymaga `ProcessEventRecord`,
- brak reverse lookup uniewaznia authz precheck coverage,
- authz control nie moze byc ukryty w UI; operator widzi co najmniej reason blokady i scope decyzji.

## AccessGrant

Rola:
opisuje jawny grant autoryzacyjny dla operatora albo roli
w konkretnym scope procesu, projektu albo runtime.

Punkty odniesienia:
- OWASP Authorization Cheat Sheet: `deny-by-default`, least privilege i walidacja autoryzacji przy kazdym zadaniu.
- NIST RBAC: role i uprawnienia powinny byc jawnie przypisane oraz podlegac przegladowi i zmianie.

### Statusy

- `defined`: grant zostal zdefiniowany, ale jeszcze nie jest aktywny.
- `active`: grant jest skuteczny i moze byc uzyty przez authz precheck.
- `revised`: grant ma przygotowana zmiane i czeka na reaktywacje albo revoke.
- `revoked`: grant nie daje juz uprawnien, ale pozostaje w audycie.

### CRUD semantics

Create:
- tworz `AccessGrant`, gdy projekt powstaje albo pojawia sie nowy scope/rola wymagajaca jawnego allow,
- create wymaga `principal_ref`, `role_ref`, `scope_ref` i `allowed_actions`.

Read:
- runtime musi umiec pytac:
  - `czy principal ma aktywny grant dla scope i action`,
  - `jakie granty sa aktywne dla projektu`,
  - `jakie revised albo revoked granty zmienily legalnosc transition`.

Update:
- dozwolone sa tylko status changes:
  - `defined -> active | revoked`
  - `active -> revised`
  - `revised -> active | revoked`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia authz projection dla impacted scope.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `revoked`,
- `revoked` wymaga jawnego reason i zachowania trace do uprzednio autoryzowanych akcji.

### Propagation

- `defined`:
  - nie daje jeszcze uprawnienia do transition,
  - moze blokowac bootstrap lub activation flow do czasu gate.
- `active`:
  - odblokowuje legalne akcje w authz precheck dla zadanego scope.
- `revised`:
  - wymaga ponownej oceny impacted transitions i moze chwilowo blokowac scope zalezne od nowej polityki.
- `revoked`:
  - blokuje dalsze akcje w danym scope,
  - moze tworzyc `ExceptionCase(authz)` dla prob dalszych transition.

## Invariants

- `AccessGrant` musi wskazywac `principal_ref`, `scope_ref` i `allowed_actions`,
- brak aktywnego `AccessGrant` dla action objetej authz = invalid transition,
- `revoked` bez `ProcessEventRecord` i jawnego reason jest invalid,
- authz control nie moze zniknac z indeksu po pojawieniu sie audytu,
- authz jest `deny-by-default`: brak jawnego allow oznacza blokade.

## Zrodla praktyk

Linki:
- https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html
- https://csrc.nist.gov/projects/role-based-access-control/rbac-library
