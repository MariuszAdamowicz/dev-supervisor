# Playbook Review Protocol v1 — Krok 7: P2 Backlog Decomposition

Data UTC: 2026-04-03T22:48:00Z

## Cel kroku
Rozbic P2 na sekwencje malych, deterministycznych pakietow zmian, ktore mozna wdrazac i walidowac niezaleznie.

## Wejscie (P2 z audytu coverage)
Braki:
1. Lifecycle bindingi dla `Requirement`, `Constraint`, `DecisionRecord`, `Risk`, `ActorRolePermission`.
2. Lifecycle utrzymaniowe (`deprecated/obsolete/retired`) dla OP domenowych.

## Zasady dekompozycji
- kazdy pakiet ma minimalny scope,
- kazdy pakiet konczy sie aktualizacja: `trigger-rules.md`, `bindings.md`, `checklists.md`, `playbook-contracts.md` (jesli dotyczy),
- kazdy pakiet ma niezalezny commit i evidence note,
- po kazdym pakiecie wykonywany jest mini-audit coverage.

## Pakiety P2 (kolejnosc rekomendowana)

### P2-A: Requirement + Constraint baseline
Zakres:
- `Requirement`: proposed -> clarified -> approved -> linked -> deprecated
- `Constraint`: proposed -> validated -> enforced -> revised -> retired

Binding intent:
- operator-driven review + gate,
- linkowanie Requirement/Constraint do Feature,
- explicit audit trail dla zmian enforce/revise/retire.

Definition of done:
- wszystkie przejscia lifecycle maja binding,
- istnieje Decision Envelope dla gate-required,
- checklista feature runtime wymusza linkage Requirement/Constraint.

### P2-B: DecisionRecord lifecycle
Zakres:
- `DecisionRecord`: drafted -> reviewed -> approved -> superseded

Binding intent:
- decyzje architektoniczne jako jawny gate,
- supersede wymaga linku do nowego DecisionRecord.

Definition of done:
- brak mozliwosci `Feature.done` bez powiazanego DecisionRecord dla zmian architektonicznych oznaczonych jako required.

### P2-C: Risk lifecycle + gate interaction
Zakres:
- `Risk`: identified -> assessed -> mitigated|accepted|escalated -> closed

Binding intent:
- `Risk.escalated` wymusza gate (defer/request_changes) na transitionach release,
- `Risk.accepted` wymaga jawnej decyzji operatora.

Definition of done:
- release guard uwzglednia otwarte ryzyka krytyczne,
- istnieje jednolity review package ryzyka.

### P2-D: ActorRolePermission execution
Zakres:
- `ActorRolePermission`: defined -> active -> revised -> revoked

Binding intent:
- kazdy action execution sprawdza aktywne uprawnienia,
- brak uprawnienia generuje `Exception(authz)` przez binding, nie ad-hoc.

Definition of done:
- Permission contract ma pokrycie operacyjne,
- co najmniej jeden binding testowy pokazuje blokade transition bez uprawnien.

### P2-E: Deprecation/Obsolete/Retired housekeeping
Zakres:
- `Term.approved -> deprecated`
- `UIComponent.verified -> deprecated`
- `UIScreen.verified -> deprecated`
- `Scenario.passing -> obsolete`
- `Constraint.revised -> retired`

Binding intent:
- przejscia utrzymaniowe sa jawne i audytowalne,
- zaleznosci (np. deprecacja UI) aktualizuja linki i traceability.

Definition of done:
- lifecycle maintenance nie zostaje jako "manual note", tylko ma binding i audit.

## Zaleznosci miedzy pakietami
- P2-A przed P2-B (DecisionRecord powinien odnosic sie do zatwierdzonych constraints).
- P2-B przed P2-C (ryzyko czesto zalezy od decyzji).
- P2-D moze byc rownolegle do P2-A/P2-B, ale musi byc domkniete przed finalnym hardeningiem.
- P2-E na koncu (housekeeping po stabilizacji semantyki podstawowej).

## Kryterium akceptacji calego P2
- dla kazdego OP z katalogu istnieje przynajmniej jednoznaczna sciezka lifecycle z bindingami,
- brak statusu `missing` w audycie coverage dla OP objetych P2,
- evidence package zawiera before/after coverage map.

## Analiza kroku: czy to byl wlasciwy krok?
Tak. Dekompozycja zmniejsza ryzyko "jednego wielkiego patcha" i pozwala iteracyjnie walidowac zaleznosci miedzy OP.

## Analiza alternatywy: co moglo byc inne?
Mozna bylo od razu wdrazac P2-A w tym kroku, ale bez uzgodnionej sekwencji latwo o rozjazd semantyki miedzy OP i bindings.

## Nastepny krok
Krok 8: wdrozenie P2-A (Requirement + Constraint baseline) z mini-audytem coverage po zmianach.
