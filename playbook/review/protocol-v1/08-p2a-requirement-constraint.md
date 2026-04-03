# Playbook Review Protocol v1 — Krok 8: P2-A Requirement + Constraint

Data UTC: 2026-04-04T00:02:00Z

## Cel kroku
Wdrozyc pelny baseline lifecycle bindingow dla OP `Requirement` i `Constraint`.

## Zmiany wykonane

### 1) Trigger rules (`playbook/layers/op/trigger-rules.md`)
Dodano sekcje `Requirement i Constraint baseline` z eventami:
- Requirement: `proposed`, `clarified`, `approved`
- Constraint: `proposed`, `validated`, `enforced`, `revised`

### 2) Bindings (`playbook/tooling/bindings.md`)
Dodano transitions:
- Requirement:
  - `proposed -> clarified`
  - `clarified -> approved`
  - `approved -> linked`
  - `linked -> deprecated`
- Constraint:
  - `proposed -> validated`
  - `validated -> enforced`
  - `enforced -> revised`
  - `revised -> retired`

Dodatkowo:
- `Feature.released -> Feature.done` ma guardy wymagajace:
  - krytyczne `Requirement.linked`
  - krytyczne `Constraint.enforced|revised`

### 3) Decision Envelope (`playbook/workflow/decision-envelope.md`)
Rozszerzono baseline gate-required o transition Requirement/Constraint wymagajace decyzji operatora.

### 4) Checklist (`playbook/workflow/checklists.md`)
Rozszerzono checkliste feature runtime o warunki Requirement/Constraint przed `Feature.done`.

## Mini-audit coverage (before/after)

| OP | Before | After |
|---|---|---|
| Requirement | missing | covered |
| Constraint | missing | covered |

## Analiza kroku: czy to byl wlasciwy krok?
Tak. P2-A zamyka pierwsza czesc brakow semantycznych i laczy lifecycle Requirement/Constraint z domknieciem Feature.

## Analiza alternatywy: co moglo byc inne?
Mozna bylo dodac od razu `DecisionRecord`, ale to zwiekszyloby scope i utrudnilo jednoznaczna walidacje efektu P2-A.

## Dowod kroku
- zmiany w `trigger-rules.md`, `bindings.md`, `decision-envelope.md`, `checklists.md`
- ten artefakt mini-audytu

## Nastepny krok
Krok 9: P2-B (`DecisionRecord`) + reguly zaleznosci Feature.done od DecisionRecord dla zmian architektonicznych oznaczonych jako required.
