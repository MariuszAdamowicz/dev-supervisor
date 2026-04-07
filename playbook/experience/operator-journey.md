# Operator Journey (OP-aligned)

## Cel
Operator wykonuje jeden nastepny krok wskazany przez OP, nie przez reczny wybor etapu.

## Zasada glowna
Interfejs pokazuje:
- current_op i current_state,
- wymagane wejscia do next_transition,
- artefakty potrzebne do GateDecision.

Primary copy opisuje zadanie operatora:
- `utworz baseline`,
- `doprecyzuj feature`,
- `przygotuj release`.

Primary copy nie opisuje:
- `Project.configured -> Project.baseline-approved`,
- `Feature.specified -> Feature.ux-aligned`.

## Glowny przebieg (nowy projekt)
1. Project setup (Project + ActorRolePermission)
2. Product baseline (Requirement + Constraint + DecisionRecord + UseCase + PortContract + Component + UX contract)
3. Idea intake (Idea)
4. Idea scoping (Idea -> Feature)
5. Feature spec/test loop (Feature + Scenario + PromptTask + GateDecision)
6. UX alignment (Term + UIComponent + UIScreen)
7. Quality and hardening (QualitySignal + Risk + Dependency)
8. Delivery (Release -> Deployment -> Rollback)
9. Audit closure (ProcessEvent + final GateDecision)

## Decyzje operatora
Operator podejmuje decyzje:
- wybór aktywnej idei/feature,
- GateDecision (approve/request_changes/defer/reject),
- acceptance lub escalation dla Risk/Exception,
- publikacja release i ewentualny rollback.

## Cofanie i regeneracja
Zmiana upstream OP invaliduje downstream OP zgodnie z trigger rules.
UI pokazuje scope invalidation i wymagane kroki odtworzenia.

## Rozdzial trybow

Tryb operatora:
- wykonanie nastepnej pracy,
- zrozumialy status,
- jedna glowna akcja.

Tryb audit/debug:
- event history,
- payload hashes,
- ids,
- provenance,
- review package internals.
