## Setup (OP-driven)

Cel:
setup przygotowuje runtime projektu, ale nie definiuje semantyki procesu.
Semantyka procesu jest kanoniczna w OP Layer.

Kanoniczne definicje OP:
- layers/op/object-catalog.md
- layers/op/state-machines.md
- layers/op/trigger-rules.md

## 1. Bootstrap projektu

- utworz repo i .gitignore
- skonfiguruj scripts: build/test/lint
- wybierz storage profile:
  - profiles/storage/file-ai.md
  - profiles/storage/sqlbase.md
- przygotuj runtime storage (.ai/* lub SQLBase)

## 2. Product baseline

- utworz overview.md
- utworz constraints.md
- utworz glossary.md
- utworz Requirement/Constraint/DecisionRecord OP dla baseline

Product Gate przechodzi tylko gdy:
- baseline jest kompletny,
- baseline jest niesprzeczny,
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
- state/trigger/gate sa kanoniczne tylko w OP Layer

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
