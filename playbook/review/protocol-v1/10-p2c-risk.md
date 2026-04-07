# Playbook Review Protocol v1 — Krok 10: P2-C Risk

Data UTC: 2026-04-04T00:22:00Z

## Cel kroku
Wdrozyc lifecycle OP `Risk` oraz podpiac ryzyka do guardow delivery/release.

## Zmiany wykonane

### 1) Trigger rules (`playbook/layers/op/trigger-rules.md`)
Dodano sekcje `Risk baseline`:
- `Risk.identified` -> assessment review
- `Risk.assessed` -> resolution review
- `Risk.escalated` -> GateDecisionRecord candidate blokujacy delivery
- `Risk.mitigated` / `Risk.accepted` -> close/acceptance audit

### 2) Bindings (`playbook/tooling/bindings.md`)
Dodano transitions:
- `Risk.identified -> Risk.assessed`
- `Risk.assessed -> Risk.mitigated`
- `Risk.assessed -> Risk.accepted`
- `Risk.assessed -> Risk.escalated`
- `Risk.mitigated -> Risk.closed`
- `Risk.accepted -> Risk.closed`
- `Risk.escalated -> Risk.closed`

### 3) Delivery guards
Rozszerzono guardy:
- `Feature.stabilized -> Release.candidate`
- `Release.candidate -> Release.approved`

Nowy warunek:
- brak otwartych `Risk.escalated` o `criticality=high`.

### 4) Decision Envelope (`playbook/workflow/decision-envelope.md`)
Dodano gate-required transitions dla `Risk`:
- `Risk.assessed -> Risk.mitigated`
- `Risk.assessed -> Risk.accepted`
- `Risk.assessed -> Risk.escalated`
- `Risk.escalated -> Risk.closed`

## Mini-audit coverage (before/after)

| OP | Before | After |
|---|---|---|
| Risk | missing | covered |

## Analiza kroku: czy to byl wlasciwy krok?
Tak. Ryzyka zaczely realnie interferowac z delivery zamiast byc tylko opisem pomocniczym.

## Analiza alternatywy: co moglo byc inne?
Mozna bylo zostawic guard tylko na `Release.approved`, ale to opoznialoby sygnal o blokadzie i zwiekszalo koszt poznych rollbackow.

## Dowod kroku
- zmiany w `trigger-rules.md`, `bindings.md`, `decision-envelope.md`
- ten artefakt mini-audytu

## Nastepny krok
Krok 11: P2-D (`ActorRolePermission`) + operacyjne wymuszenie permission contract.
