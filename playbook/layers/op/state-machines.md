## State Machines (kanoniczne)

Cel: kazdy OP ma jednoznaczny lifecycle. Przejscie stanu wymaga eventu i guard condition.

## Semantyka przejsc

Kazde przejscie zapisujemy jako:
- from_state
- event
- guards
- actions
- to_state
- failure_policy (retry/compensation/escalation)

## Maszyny stanow per OP

### Project
created -> configured -> baseline-approved -> active -> archived

### Requirement
proposed -> clarified -> approved -> linked -> deprecated

### Constraint
proposed -> validated -> enforced -> revised -> retired

### DecisionRecord
drafted -> reviewed -> approved -> superseded

### Idea
captured -> scoped -> converted | dropped

### Feature
drafted -> specified -> ux-aligned -> scenario-ready -> test-ready -> implemented -> stabilized -> released -> done

### Scenario
drafted -> approved -> test-linked -> passing -> obsolete

### Term
proposed -> approved -> deprecated

### UIComponent
proposed -> mapped -> implemented -> verified -> deprecated

### UIScreen
proposed -> mapped -> verified -> deprecated

### PromptTask
created -> ready -> executed -> validated -> closed | cancelled

### GateDecision
recorded (value: approve | request_changes | defer | reject)

### ActorRolePermission
defined -> active -> revised -> revoked

### Dependency
identified -> validated -> satisfied | blocked | waived

### Risk
identified -> assessed -> mitigated | accepted | escalated -> closed

### Release
planned -> candidate -> approved -> published -> closed

### Deployment
prepared -> running -> succeeded | failed

### Rollback
prepared -> running -> succeeded | failed

### QualitySignal
collected -> evaluated -> pass | fail

### Exception
detected -> classified -> handled | escalated

### Timeout
scheduled -> fired -> handled | escalated

### Compensation
planned -> running -> completed | failed

### ProcessEvent
recorded (immutable)

## Guard conditions (obowiazkowe)

Przyklady guardow:
- Feature.test-ready wymaga: wszystkie scenariusze kluczowe maja testy.
- Feature.released wymaga: GateDecision=approve i QualitySignal=pass.
- Deployment.running wymaga: Release.approved.
- Rollback.running wymaga: Deployment.failed lub QualitySignal=fail.

## Hierarchia i zakazy

- OP nizszego poziomu nie moze wyprzedzac OP nadrzednego.
- Feature nie przejdzie do done, jesli istnieje Exception o severity=critical bez Compensation.completed.
- GateDecision bez review package jest niewazna.
