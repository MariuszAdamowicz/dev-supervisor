# Project Registry — Consistency Check

Date: 2026-03-29
Scope:
- `.ai/features/project-registry/prd.md`
- `.ai/features/project-registry/bdd.md`
- `Tests/ProjectRegistry/ProjectRegistryBDDTests.swift`
- `App/Core/Domain/ProjectRegistryContract.swift`
- `App/Core/ProjectRegistry/ProjectRegistryInMemory.swift`

## Overall result
Core alignment is good: PRD rules are broadly reflected in BDD and executable tests, and current implementation passes build+test.

Main inconsistency: tests contain behavior not yet modeled in BDD.

## Confirmed alignment
- Registration validation, unique identity, and duplicate active path rejection are covered.
- Metadata update, archive/reactivate, and non-existent project failures are covered.
- Active working project selection semantics are covered.
- "No selected project" blocking behavior is covered.
- Project-scoped isolation behavior is covered.
- Empty registry list behavior is covered.
- Path-unavailable explicit failure behavior is covered.
- Explicit failure reason pattern is enforced in tests.

## Missing or inconsistent items
1. Tests include scenarios that are not present in BDD:
- Test Scenario 21: update local path to a new unique path succeeds.
- Test Scenario 22: listing includes archived and active projects together.

2. Rule-level gap in BDD/tests for reactivation conflict:
- PRD rule says two active projects must not share the same local path/reference.
- Register and update conflict paths are covered.
- Reactivation conflict path is implemented in code (`reactivateProject`) but not explicitly covered by BDD/test.

## Obsolete items
- No clearly obsolete PRD rules found.
- No clearly obsolete BDD scenarios found.
- No clearly obsolete tests found.

## Recommended next single step
Update `bdd.md` to include missing behavior currently enforced by tests (scenario 21 and 22) and add one scenario for reactivation conflict on duplicate active path/reference. Then run test generation/update only if needed.

---

## Closure Update

Date: 2026-03-29

Status:
- Completed: BDD updated with scenarios 21, 22, 23.
- Completed: test for Scenario 23 added and passing.
- Completed: traceability synchronized with current PRD/BDD.
- Completed: validation scripts passing in current setup (`build`, `test`, `lint` with style warnings).

Feature decision:
- `project-registry` is considered functionally closed for current scope.
- Further work moves to next feature, unless a defect/regression is discovered.
