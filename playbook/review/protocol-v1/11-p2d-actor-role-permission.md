# Playbook Review Protocol v1 — Krok 11: P2-D ActorRolePermission

Data UTC: 2026-04-04T00:31:00Z

## Cel kroku
Wdrozyc lifecycle `ActorRolePermission` i operacyjnie wymusic permission contract na poziomie bindingow transition.

## Zmiany wykonane

### 1) Trigger rules (`playbook/layers/op/trigger-rules.md`)
Dodano sekcje `ActorRolePermission baseline`:
- `defined -> active -> revised -> revoked`
- event `authz.denied` mapowany na `Exception(authz)` i blokade transition.

### 2) Bindings (`playbook/tooling/bindings.md`)
Dodano transitions:
- `ActorRolePermission.defined -> ActorRolePermission.active`
- `ActorRolePermission.active -> ActorRolePermission.revised`
- `ActorRolePermission.revised -> ActorRolePermission.revoked`

Dodano globalna regule bindingow:
- kazdy transition MUSI wykonac `authz precheck` na `ActorRolePermission`.
- fail precheck -> `Exception(authz)` + blocked transition + ProcessEvent.

### 3) Decision Envelope (`playbook/workflow/decision-envelope.md`)
Rozszerzono gate-required o transition `ActorRolePermission`.

### 4) Checklist i kontrakty walidacji
- `playbook/workflow/checklists.md`:
  - audyt OP: wynik authz precheck per transition,
  - audyt tooling: jawny authz precheck w kazdym bindingu.
- `playbook/validation/playbook-contracts.md`:
  - Permission contract wymaga operacyjnego authz precheck i sciezki `Exception(authz)`.

## Mini-audit coverage (before/after)

| OP | Before | After |
|---|---|---|
| ActorRolePermission | missing | covered |

## Analiza kroku: czy to byl wlasciwy krok?
Tak. Permission contract przestal byc tylko deklaracja i zostal zwiazany z wykonaniem transition.

## Analiza alternatywy: co moglo byc inne?
Mozna bylo wdrozyc authz tylko dla gate-required, ale to zostawialoby niekontrolowane transitiony bez ochrony.

## Dowod kroku
- zmiany w `trigger-rules.md`, `bindings.md`, `decision-envelope.md`, `checklists.md`, `playbook-contracts.md`
- ten artefakt mini-audytu

## Nastepny krok
Krok 12: P2-E (deprecation/obsolete/retired housekeeping) + finalny coverage audit P2.
