## Setup (OP-driven)

Cel:
setup przygotowuje runtime projektu, ale nie definiuje semantyki procesu.
Semantyka procesu jest kanoniczna w OP Layer.

Kanoniczne definicje OP:
- layers/op/object-catalog.md
- layers/op/relation-contracts.md
- layers/op/recovery-contracts.md
- layers/op/scheduler-contracts.md
- layers/op/state-machines.md
- layers/op/trigger-rules.md

## 1. Bootstrap projektu

- utworz repo i .gitignore
- zarejestruj Repository OP dla lokalnego repo
- skonfiguruj scripts: build/test/lint
- wybierz storage profile:
  - profiles/storage/file-ai.md
  - profiles/storage/sqlbase.md
- przygotuj runtime storage (.ai/* lub SQLBase)

## 2. Product baseline

- utworz overview.md
- utworz constraints.md
- utworz glossary.md
- utworz `.ai/adr/0001-project-baseline.md`
- utworz `.ai/architecture/use-cases.md`
- utworz `.ai/architecture/port-contracts.md`
- utworz `.ai/architecture/component-map.md`
- utworz `.ai/ux/new-project.md`
- utworz `.ai/verification/plan.md`
- utworz Requirement/Constraint/DecisionRecord/Repository/VerificationPlan OP dla baseline
- zdefiniuj poczatkowe UseCase i granice PortContract dla kluczowych przeplywow
- zdefiniuj poczatkowa mape Component dla krytycznych modulow
- utworz ActorRolePermission dla operatora inicjujacego projekt
- jesli profil jest `deployable-runtime`, utworz RuntimeEnvironment dla local i docelowych lane
- jesli profil jest `persistent-data`, utworz DataSchema dla baseline danych
- zbuduj indeks OP i parent linkage dla baseline

Product Gate przechodzi tylko gdy:
- baseline jest kompletny,
- baseline jest niesprzeczny,
- baseline ma komplet UX/architecture artifacts,
- baseline ma Repository i VerificationPlan zgodne z profilem projektu,
- authz i provenance sa zapisane,
- operator zapisal jawna decyzje gate.

## 3. Konfiguracja profili

Wybierz profile:
- stack
- architecture
- language
- execution-style
- storage

Zasada:
wybor profili powinien byc prowadzony przez wizard/decision flow,
a nie przez reczne przegladanie listy plikow.

## 4. Runtime contract

- .ai/prd/* i .ai/features/* to artefakty runtime (Project Instance Layer)
- .ai/ux/* to projekcja UX dla operatora (nie kanoniczna semantyka)
- .ai/architecture/* i .ai/adr/* to artefakty baseline wymagane przy setup
- state/trigger/gate sa kanoniczne tylko w OP Layer
- create/read/update/remove OP podlega `workflow/op-crud-contract.md`

Zasada rozstrzygania konfliktu:
- jesli .ai/* koliduje z OP Layer, nadrzedna jest definicja OP.

## 5. Start pracy

Po setup operator:
1. wybiera entrypoint OP,
2. odczytuje current_state,
3. wyznacza next_transition z OP,
4. uruchamia projection OP -> UI/Prompt/Checklist.

Szczegoly codziennej pracy:
- workflow/daily-workflow.md

## Tooling bootstrap

Podczas setup aktywuj wykonawcza warstwe playbooka:
- tooling/tool-registry.md
- tooling/action-catalog.md
- tooling/bindings.md

Wymaganie:
- dla kazdego krytycznego transition OP musi istniec binding transition -> action -> tool.
- kazdy state-changing flow musi miec `policy-engine` precheck.

## AI bootstrap

Wymaganie nadrzedne:
- AI jest uruchamiane jako ai-runner (job model) sterowany przez DS.
- decyzje retry/timeout/cancel/reset_context podejmuje DS.
- MCP moze byc uzyte tylko jako adapter transportowy.

## Validation bootstrap

Podczas setup aktywuj walidacje kontraktow playbooka:
- validation/playbook-contracts.md

Wymaganie:
- kazda zmiana warstwy playbooka (workflow/core/experience/tooling/profiles) przechodzi przez validation contracts przed zatwierdzeniem.
- walidacja obejmuje workflow<->exec alignment, CRUD integrity, semantic guards i evidence provenance.

## Verification bootstrap

Podczas setup aktywuj modul praktycznej weryfikacji:
- verification/index.md
- verification/static-validation.md
- verification/semantic-validation.md
- verification/deterministic-replay.md
- verification/e2e-reference-run.md
- verification/evidence-provenance.md
- verification/chaos-tests.md
- verification/report-template.md

Wymaganie:
- przed uznaniem wersji playbooka za operacyjna powstaje raport PASS/FAIL wg verification/report-template.md.
