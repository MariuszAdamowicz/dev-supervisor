# Playbook Review Protocol v1 — Krok 6: Patche P1

Data UTC: 2026-04-03T22:40:00Z

## Cel kroku
Domknac luki P1:
1. `PromptTask.executed -> validated -> closed`
2. `QualitySignal.evaluated -> pass`
3. `Project.active -> archived`
4. twarda, deterministyczna klasyfikacja `gate_required`.

## Zmiany wykonane

### 1) Trigger rules (`playbook/layers/op/trigger-rules.md`)
Dodano reguly:
- `PromptTask.executed` -> `validation-review` (warunek do stanu validated),
- `PromptTask.validated` -> zamkniecie tasku,
- `QualitySignal.pass` -> odblokowanie kolejnych legalnych transition,
- `project.archive-requested` -> review package archiwizacji + GateDecision candidate.

### 2) Bindings (`playbook/tooling/bindings.md`)
Dodano transitions:
- `Project.active -> Project.archived`
- `PromptTask.executed -> PromptTask.validated`
- `PromptTask.validated -> PromptTask.closed`
- `QualitySignal.evaluated -> QualitySignal.pass`

### 3) Gate classifier (`playbook/workflow/decision-envelope.md`)
Dodano deterministyczny classifier `gate_required` oparty o:
- `decide_gate` w `action_plan` oraz
- decyzyjne `operator-ui` w `tool_plan`.

Rozszerzono liste baseline gate-required o:
- `Project.active -> Project.archived`
- `PromptTask.executed -> PromptTask.validated`
- `Feature.released -> Feature.done`
- `Release.published -> Release.closed`

### 4) Walidacja kontraktowa (`playbook/validation/playbook-contracts.md`)
Dodano wymog:
- gate-required musi byc klasyfikowany przez classifier envelope,
- nowy safety contract: spojnosc klasyfikacji gate-required miedzy UI/CLI/service.

## Analiza kroku: czy to byl wlasciwy krok?
Tak. To minimalny zestaw zmian, ktory redukuje ad-hoc decyzje i uszczelnia lifecycle housekeepingu bez zmiany architektury warstw.

## Analiza alternatywy: co moglo byc inne?
Mozna bylo pominac `Project.archived`, ale wtedy `Project` nadal mialby otwarty lifecycle i audit coverage pozostawalby niepelny.

## Dowod kroku
- zmiany w `trigger-rules.md`, `bindings.md`, `decision-envelope.md`, `playbook-contracts.md`
- ten artefakt review

## Nastepny krok
Krok 7: P2 backlog decomposition (Requirement/Constraint/DecisionRecord/Risk/ActorRolePermission + deprecations) i plan etapowej implementacji bindingow.
