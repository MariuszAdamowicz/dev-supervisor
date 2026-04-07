# Verification Report

> Status: scoped report (legacy subset).
> Finalna decyzja globalna: `playbook/verification/reports/2026-04-07-full-op-verification-report.md`.

## Metadata
- date: 2026-04-07
- operator: codex
- playbook_version_ref: feat/test-gate-hardening@working-tree
- runtime_profile_set: stack=macos-swiftui, architecture=modular-monolith, language=pl, execution-style=iterative-tdd, storage=file-ai
- run_scope: deterministic_replay_only

## Scope
- static_validation: pass (from previous report)
- deterministic_replay: pass
- e2e_reference_run: fail (not_run_in_this_step)
- chaos_process_tests: fail (not_run_in_this_step)

## Replay Method
- checker: `playbook/verification/scripts/fsm-replay-check.sh`
- scenarios:
  - `playbook/verification/replay/scenario-feature-happy.csv`
  - `playbook/verification/replay/scenario-feature-rework.csv`
  - `playbook/verification/replay/scenario-release-rollback.csv`
- strategy: uruchomienie checker'a 2x dla tego samego scenariusza + porownanie hash outputu.

## Results
1. scenario-feature-happy.csv
- run1_sha256: bcccfc0b04909f48769d4632595a8c6643d49bf175325563b3f67d7554545b4c
- run2_sha256: bcccfc0b04909f48769d4632595a8c6643d49bf175325563b3f67d7554545b4c
- diff: none
- status: pass

2. scenario-feature-rework.csv
- run1_sha256: 85b1834b040600829ce8ed831578aa1a6f05ec50ba05a414a5578c63659c782f
- run2_sha256: 85b1834b040600829ce8ed831578aa1a6f05ec50ba05a414a5578c63659c782f
- diff: none
- status: pass

3. scenario-release-rollback.csv
- run1_sha256: 3c211911accdd438a6407dc867b7c3115236b6b3393bda4882f7b2dbe7be7f9a
- run2_sha256: 3c211911accdd438a6407dc867b7c3115236b6b3393bda4882f7b2dbe7be7f9a
- diff: none
- status: pass

## Findings
1. finding_id: DTR-2026-04-07-001
- severity: low
- contract_ref: Deterministic Replay
- evidence_ref: output hash run1/run2
- impact: replay obecnie waliduje determinism na poziomie kontraktu FSM (nie runtime engine DS).
- proposed_fix: w kroku E2E podpiac replay pod realny event log runtime `.ai/runtime/v1`.

## Final Decision
- overall_status: pass
- blocking_issues_count: 0
- approved_by: operator (pending)
- gate_decision_ref: pending
