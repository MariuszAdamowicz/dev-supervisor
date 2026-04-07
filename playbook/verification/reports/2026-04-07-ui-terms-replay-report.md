# Verification Report

> Status: scoped report (coverage extension subset).
> Finalna decyzja globalna: `playbook/verification/reports/2026-04-07-full-op-verification-report.md`.

## Metadata
- date: 2026-04-07
- operator: codex
- playbook_version_ref: feat/test-gate-hardening@working-tree
- runtime_profile_set: stack=macos-swiftui, architecture=modular-monolith, language=pl, execution-style=iterative-tdd, storage=file-ai
- run_scope: ui_terms_replay_coverage

## Scope
- deterministic_replay: pass
- op_scope: Term, UIComponent, UIScreen

## Replay Method
- checker: `playbook/verification/scripts/fsm-replay-check.sh`
- scenarios:
  - `playbook/verification/replay/scenario-term-coverage.csv`
  - `playbook/verification/replay/scenario-ui-component-coverage.csv`
  - `playbook/verification/replay/scenario-ui-screen-coverage.csv`
- strategy: uruchomienie checker'a 2x dla kazdego scenariusza + porownanie hash outputu.

## Results
1. scenario-term-coverage.csv
- run1_sha256: e428992a34bdfbf573e669c7bd901d920511d763aac9de8c67aa46a4d855e675
- run2_sha256: e428992a34bdfbf573e669c7bd901d920511d763aac9de8c67aa46a4d855e675
- diff: none
- status: pass

2. scenario-ui-component-coverage.csv
- run1_sha256: 5e1e1cafe333574ea0c9e409780a5f59747bd6e0e53af9d79d9b9f8793837058
- run2_sha256: 5e1e1cafe333574ea0c9e409780a5f59747bd6e0e53af9d79d9b9f8793837058
- diff: none
- status: pass

3. scenario-ui-screen-coverage.csv
- run1_sha256: da18bdcbe542a2d4e5b1b00dcb5dd4aa65599f4f7872ffa95a2934c1a62c5fa1
- run2_sha256: da18bdcbe542a2d4e5b1b00dcb5dd4aa65599f4f7872ffa95a2934c1a62c5fa1
- diff: none
- status: pass

## Evidence
- run logs and hashes: `playbook/verification/replay/run-2026-04-07-ui-terms/`
- scenarios:
  - `playbook/verification/replay/scenario-term-coverage.csv`
  - `playbook/verification/replay/scenario-ui-component-coverage.csv`
  - `playbook/verification/replay/scenario-ui-screen-coverage.csv`

## Findings
- none

## Final Decision
- overall_status: pass
- blocking_issues_count: 0
- approved_by: operator (pending)
- gate_decision_ref: pending
