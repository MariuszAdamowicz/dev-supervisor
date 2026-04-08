# Environment Contracts (kanoniczne)

Cel:
opisac mutowalne cele srodowiskowe i kontrole gotowosci,
ktore nie sa samodzielnymi OP, ale maja jawny status,
capability set, config policy i wplyw na delivery oraz walidacje.

Environment control nie jest:
- OP z pelnym lifecycle produktu,
- ukryta konfiguracja rozsiana po plikach i skryptach,
- jednorazowa notatka deploymentowa bez mozliwosci odpytywania.

Environment control jest:
- mutowalnym celem uruchomieniowym dla local/ci/stage/prod,
- bytem queryable po lane, capability i statusie,
- nosnikiem decyzji readiness, aktywacji i decommission.

## Kontrakt wspolny environment control

Kazdy environment control ma pola:
- `environment_id`
- `environment_name`
- `environment_class`
- `capabilities`
- `config_policy`
- `status`
- `owner`
- `created_at`
- `updated_at`
- `reason`

Pola opcjonalne:
- `secret_policy`
- `deploy_constraints`
- `release_refs`
- `replacement_ref`
- `evidence_refs`

Reguly:
- environment control musi byc zapisany w runtime index i reverse lookup po `environment_name` oraz `environment_class`,
- mutacja environment control wymaga `ProcessEventRecord`,
- brak reverse lookup uniewaznia readiness i delivery guard coverage,
- environment control nie moze byc ukryty przed operatorem, gdy blokuje release, deployment albo schema apply.

## EnvironmentTarget

Rola:
opisuje named runtime target dla lokalnej walidacji, CI albo wdrozenia,
z jawna gotowoscia, capability i config separation.

Punkty odniesienia:
- Twelve-Factor App: konfiguracja zależna od środowiska powinna byc odseparowana od kodu i latwa do zarzadzania.
- Kubernetes ConfigMap: konfiguracja srodowiskowa powinna byc dostarczana jako osobny obiekt, niezalezny od obrazu aplikacji.
- Azure Developer CLI environments: srodowiska powinny byc izolowane, nazwane i powtarzalne dla dev/test/prod.

### Statusy

- `defined`: target jest zdefiniowany, ale jeszcze nieprzetestowany.
- `validated`: capability i config zostaly sprawdzone technicznie.
- `ready`: target jest gotowy do walidacji lane albo delivery.
- `active`: target jest aktualnie uzywany jako biezace srodowisko wykonania.
- `degraded`: target utracil gotowosc i wymaga recovery albo revalidation.
- `retired`: target zostal wycofany i pozostaje tylko w audycie.

### CRUD semantics

Create:
- tworz `EnvironmentTarget`, gdy projekt ma lane runtime albo deployment target,
- create wymaga `environment_name`, `environment_class`, `capabilities` i `config_policy`.

Read:
- runtime musi umiec pytac:
  - `jakie EnvironmentTarget sa gotowe dla release albo verification lane`,
  - `czy target ma capability wymagane przez deploy lub migration`,
  - `ktore targety sa degraded albo retired`.

Update:
- dozwolone sa tylko status changes:
  - `defined -> validated`
  - `validated -> ready | retired`
  - `ready -> active | retired`
  - `active -> degraded | retired`
  - `degraded -> ready`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia blocker projection dla delivery/data scope.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `retired`,
- `retired` wymaga jawnego reason i wskazania replacement target albo closure plan.

### Propagation

- `defined`:
  - nie odblokowuje jeszcze release ani migration apply.
- `validated`:
  - potwierdza zgodnosc capability/config, ale nie odblokowuje jeszcze delivery gate.
- `ready`:
  - odblokowuje `ReleaseBundle.approved`, `DeploymentRun.planned` i `DataSchema.applied` dla powiazanego lane.
- `active`:
  - oznacza target aktualnie uzywany przez runtime albo rollout.
- `degraded`:
  - blokuje release closure, rollout albo schema apply do czasu recovery.
- `retired`:
  - nie moze byc dalej wybierany do delivery; pozostaje w audycie i relacjach historycznych.

## Invariants

- `EnvironmentTarget` musi wskazywac `environment_name`, `environment_class`, `capabilities` i `config_policy`,
- `ready` bez jawnej walidacji capability/config jest invalid,
- `degraded` bez blocker projection dla delivery albo verification lane jest invalid,
- `retired` bez `ProcessEventRecord` i jawnego reason jest invalid,
- environment control nie moze zniknac z indeksu po pojawieniu sie audytu.

## Zrodla praktyk

Linki:
- https://www.12factor.net/config
- https://kubernetes.io/docs/concepts/configuration/configmap/
- https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/environments-overview
