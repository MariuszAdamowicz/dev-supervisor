# Screen Flow Contracts (OP-aligned)

Cel:
zdefiniowac deterministyczny kontrakt UI: co operator widzi i co moze zrobic w kazdym stanie OP.

## Zasada globalna

UI nie prowadzi niezaleznej logiki procesu.
UI renderuje projection z OP:
- current_state
- legal transitions
- guards
- pending PromptTask
- gate requirements
- tool_plan (w tym operator-ui)

## Kontrakt ekranow

## 1. Project Setup Screen

Widoczne gdy:
- Project.created lub Project.configured

Musi pokazac:
- formularz nazwa/opis projektu
- wizard wyboru profili
- status baseline artifacts (overview/constraints/glossary)
- CTA: `approve baseline` tylko gdy guards spelnione

Ukrywa:
- akcje feature/release

## 2. Idea Intake Screen

Widoczne gdy:
- Idea.captured lub Idea.scoped

Musi pokazac:
- lista idei i status scoped/converted/dropped
- CTA: `generate IDEA->FEATURE prompt`
- CTA: `convert to feature` albo `drop idea` (gate)

Ukrywa:
- implementacyjne akcje kodowe

## 3. Feature Delivery Screen

Widoczne gdy:
- Feature.drafted .. Feature.stabilized

Musi pokazac:
- aktywny etap: specified/ux-aligned/scenario-ready/test-ready/implemented/stabilized
- mapowanie PRD < BDD < TESTY
- status walidacji (build/test/lint)
- CTA tylko dla next_transition

Zasada:
- tylko jedna glowna akcja (next best action)

## 4. UX Alignment Screen

Widoczne gdy:
- Term.proposed
- UIComponent.proposed/mapped/implemented
- UIScreen.proposed/mapped

Musi pokazac:
- term impacts
- mapowanie component -> screen
- visibility rules i invalidation scope
- CTA: approve mapping / approve UX gate

## 5. Gate Review Screen

Widoczne gdy:
- transition wymaga GateDecision

Musi pokazac:
- review package (diff, test mapping, quality)
- decyzje: approve/request_changes/defer/reject
- pole reason (obowiazkowe dla request_changes/defer/reject)

Zakaz:
- brak mozliwosci zmiany stanu bez decyzji gate

## 6. Release & Operations Screen

Widoczne gdy:
- Release.candidate/approved/published
- Deployment.prepared/running/failed
- Rollback.prepared/running

Musi pokazac:
- release scope
- deployment status timeline
- rollback readiness i compensation status
- CTA: start deploy / confirm rollback

## 7. Exception & Timeout Screen

Widoczne gdy:
- Exception.detected/escalated
- Timeout.fired/escalated

Musi pokazac:
- severity i impacted OP
- wymagany recovery path
- CTA: handle/escalate/defer

## Kontrole spojnosc UI

1. Action visibility contract
- UI nie pokazuje akcji bez legal transition.

2. Guard explanation contract
- kazda zablokowana akcja ma jawny reason z OP guard.

3. Audit contract
- kazda akcja operatora zapisuje ProcessEvent.

4. Determinism contract
- ten sam stan OP zawsze generuje ten sam zestaw akcji UI.
