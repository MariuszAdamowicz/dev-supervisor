# Playbook Review Protocol v1 — Krok 9: P2-B DecisionRecord

Data UTC: 2026-04-04T00:12:00Z

## Cel kroku
Wdrozyc lifecycle bindingow dla OP `DecisionRecord` i powiazac go z warunkiem domkniecia `Feature.done` dla zmian architektonicznych wymagajacych decyzji.

## Zmiany wykonane

### 1) Trigger rules (`playbook/layers/op/trigger-rules.md`)
Dodano eventy dla lifecycle `DecisionRecord`:
- `DecisionRecord.drafted`
- `DecisionRecord.reviewed` (gate effect: odblokowanie approved)
- `DecisionRecord.approved` (przygotowanie supersede review)

### 2) Bindings (`playbook/tooling/bindings.md`)
Dodano transitions:
- `DecisionRecord.drafted -> DecisionRecord.reviewed`
- `DecisionRecord.reviewed -> DecisionRecord.approved`
- `DecisionRecord.approved -> DecisionRecord.superseded`

Wszystkie transition gate-required maja `decide_gate + operator-ui` (tam gdzie dotyczy) oraz zapis stanu przez storage-adapter.

### 3) Interferencja z Feature closeout
W `Feature.released -> Feature.done` dopisano guard:
- `wszystkie wymagane decyzje architektoniczne sa DecisionRecord.approved`

### 4) Decision Envelope (`playbook/workflow/decision-envelope.md`)
Rozszerzono baseline gate-required o:
- `DecisionRecord.reviewed -> DecisionRecord.approved`
- `DecisionRecord.approved -> DecisionRecord.superseded`

### 5) Checklist (`playbook/workflow/checklists.md`)
Utrzymana i doprecyzowana zaleznosc:
- `Requirement/Constraint/DecisionRecord` powiazane z Feature
- przed `Feature.done` wymagane `DecisionRecord.approved` (dla required changes)

## Mini-audit coverage (before/after)

| OP | Before | After |
|---|---|---|
| DecisionRecord | missing | covered |

## Analiza kroku: czy to byl wlasciwy krok?
Tak. `DecisionRecord` przestal byc artefaktem "opisowym" i stal sie egzekwowalnym elementem procesu, ktory realnie blokuje/odblokowuje domkniecie Feature.

## Analiza alternatywy: co moglo byc inne?
Mozna bylo od razu laczyc to z `Risk`, ale to mieszaloby dwa rozne typy decyzji (architektura vs ryzyko) i zaciemnialo audit.

## Dowod kroku
- zmiany w `trigger-rules.md`, `bindings.md`, `decision-envelope.md`, `checklists.md`
- ten artefakt mini-audytu

## Nastepny krok
Krok 10: P2-C (`Risk`) z podpieciem do gate release i guardow delivery.
