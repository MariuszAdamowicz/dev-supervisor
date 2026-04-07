# Verification Report

## Metadata
- date: 2026-04-07
- operator: codex
- playbook_version_ref: feat/test-gate-hardening@working-tree
- runtime_profile_set: stack=macos-swiftui, architecture=modular-monolith, language=pl, execution-style=iterative-tdd, storage=file-ai
- run_scope: chaos_full_op

## Method
- fixture runner: `playbook/verification/scripts/e2e-fixture-run.sh`
- scenario: `playbook/verification/replay/scenario-chaos-full-op.csv`
- chaos injections: gate reject, request_changes/defer loops, timeout, deployment/rollback fail, quality fail, escalation.

## Results
- chaos_fixture_run: pass
- events_count: 89
- gates_count: 23
- app_quality_lane: pass
- runtime_op_types_count: 26
- legal_transition_failures: 0

## Evidence
- summary: `playbook/verification/e2e-fixture/run-2026-04-07-chaos-full-op/reports/summary.txt`
- fsm check log: `playbook/verification/e2e-fixture/run-2026-04-07-chaos-full-op/reports/fsm-check.log`
- process events: `playbook/verification/e2e-fixture/run-2026-04-07-chaos-full-op/.ai/runtime/v1/process-events.ndjson`
- gate decisions: `playbook/verification/e2e-fixture/run-2026-04-07-chaos-full-op/.ai/runtime/v1/gate-decisions.ndjson`
- runtime snapshots:
  - `playbook/verification/e2e-fixture/run-2026-04-07-chaos-full-op/reports/runtime-snapshot-before.md`
  - `playbook/verification/e2e-fixture/run-2026-04-07-chaos-full-op/reports/runtime-snapshot-after.md`
- app quality lane log: `playbook/verification/e2e-fixture/run-2026-04-07-chaos-full-op/reports/app-quality-lane.log`

## Findings
- none

## Final Decision
- overall_status: pass
- blocking_issues_count: 0
- approved_by: operator
- gate_decision_ref: approved
