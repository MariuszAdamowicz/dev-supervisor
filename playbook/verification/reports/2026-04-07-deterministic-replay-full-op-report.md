# Verification Report

## Metadata
- date: 2026-04-07
- operator: codex
- playbook_version_ref: feat/test-gate-hardening@working-tree
- runtime_profile_set: stack=macos-swiftui, architecture=modular-monolith, language=pl, execution-style=iterative-tdd, storage=file-ai
- run_scope: deterministic_replay_full_op

## Method
- checker: `playbook/verification/scripts/fsm-replay-check.sh`
- strategy: run1/run2 + sha256 comparison + diff
- scenarios:
  - `playbook/verification/replay/scenario-e2e-full-op.csv`
  - `playbook/verification/replay/scenario-chaos-full-op.csv`

## Results
1. scenario-e2e-full-op.csv
- run1_sha256: 5adb1ad180fca8795947e6772ab86bc170b3e6d6d3dd70e4ae5c19d648e6d68a
- run2_sha256: 5adb1ad180fca8795947e6772ab86bc170b3e6d6d3dd70e4ae5c19d648e6d68a
- diff: none
- transitions_checked: 68
- status: pass

2. scenario-chaos-full-op.csv
- run1_sha256: fff0844c369cfd82c449b9f08ac4640cfa7a70b15c5016e04f4f2bc0ae8289c6
- run2_sha256: fff0844c369cfd82c449b9f08ac4640cfa7a70b15c5016e04f4f2bc0ae8289c6
- diff: none
- transitions_checked: 33
- status: pass

## Evidence
- replay logs/hashes: `playbook/verification/replay/run-2026-04-07-full-op/`

## Findings
- none

## Final Decision
- overall_status: pass
- blocking_issues_count: 0
- approved_by: operator
- gate_decision_ref: approved
