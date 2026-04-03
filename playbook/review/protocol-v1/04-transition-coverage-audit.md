# Playbook Review Protocol v1 — Krok 4: Transition Coverage Audit

Data UTC: 2026-04-03T22:28:00Z

## Cel kroku
Sprawdzic pokrycie legalnych transition z `state-machines.md` przez `tooling/bindings.md`.

## Metoda
- zrodlo lifecycle: `playbook/layers/op/state-machines.md`
- zrodlo wykonania: `playbook/tooling/bindings.md`
- klasyfikacja: `covered | partial | missing`

## Wynik audytu (high-level)

| OP | Coverage | Uwagi |
|---|---|---|
| Project | partial | brak `active -> archived` |
| Requirement | missing | brak bindingow |
| Constraint | missing | brak bindingow |
| DecisionRecord | missing | brak bindingow |
| Idea | covered | podstawowe przejscia pokryte |
| Feature | partial | brak `stabilized -> released -> done` |
| Scenario | partial | brak `test-linked`, `passing`, `obsolete` |
| Term | partial | brak `approved -> deprecated` |
| UIComponent | partial | brak `verified -> deprecated` |
| UIScreen | partial | brak `verified -> deprecated` |
| PromptTask | partial | brak `executed -> validated -> closed` |
| GateDecision | partial | brak formalnego bindingu `recorded` jako standalone OP |
| ActorRolePermission | missing | brak lifecycle egzekucji uprawnien |
| Dependency | partial | brak `satisfied/waived` transitions |
| Risk | missing | brak lifecycle `assessed/mitigated/accepted/escalated/closed` |
| Release | partial | brak `approved -> published -> closed` |
| Deployment | partial | binding sklejony (`prepared->running->succeeded`) |
| Rollback | partial | brak jawnego `prepared->running` i `running->failed` |
| QualitySignal | partial | brak jawnego `evaluated -> pass` |
| Exception | partial | brak `classified` i `escalated` |
| Timeout | partial | brak `scheduled -> fired -> handled/escalated` end-to-end |
| Compensation | partial | brak `running -> failed` |
| ProcessEvent | partial | brak globalnego kontraktu wersjonowania poza file-ai v1 |

## Priorytety naprawy (deterministyczne)

P0 (blokuje domkniecie flow release):
1. `Release.approved -> Release.published -> Release.closed`
2. `Feature.stabilized -> Feature.released -> Feature.done`
3. rozdzielenie `Deployment.prepared -> running` i `running -> succeeded` na osobne bindingi

P1 (blokuje pelna audytowalnosc runtime):
4. `PromptTask.executed -> validated -> closed`
5. `QualitySignal.evaluated -> pass` (obecnie tylko fail)
6. `Project.active -> archived`

P2 (kompletnosc katalogu OP):
7. lifecycle bindingi dla `Requirement/Constraint/DecisionRecord/Risk/ActorRolePermission`
8. lifecycle utrzymaniowe (`deprecated/obsolete/retired`) dla OP domenowych

## Analiza kroku: czy to byl wlasciwy krok?
Tak. To pierwszy jednoznaczny dowod, ze problem nie lezy w pojedynczym projekcie, tylko w niepelnym pokryciu kontraktowym playbooka.

## Analiza alternatywy: co moglo byc inne?
Mozna bylo od razu dopisywac bindingi ad-hoc, ale bez audytu coverage moglibysmy pominac luki o wyzszym priorytecie.

## Dowod kroku
Artefakt: `playbook/review/protocol-v1/04-transition-coverage-audit.md`

## Nastepny krok
Krok 5: przygotowac plan patchy P0 (minimalny zestaw zmian w `bindings.md` + `trigger-rules.md` + `checklists.md`).
