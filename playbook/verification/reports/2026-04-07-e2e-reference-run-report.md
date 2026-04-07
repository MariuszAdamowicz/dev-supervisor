# Verification Report

> Status: scoped report (legacy subset).
> Finalna decyzja globalna: `playbook/verification/reports/2026-04-07-full-op-verification-report.md`.

## Metadata
- date: 2026-04-07
- operator: codex
- playbook_version_ref: feat/test-gate-hardening@working-tree
- runtime_profile_set: stack=macos-swiftui, architecture=modular-monolith, language=pl, execution-style=iterative-tdd, storage=file-ai
- run_scope: e2e_reference_run_only

## Scope
- static_validation: pass (from previous report)
- deterministic_replay: pass (from previous report)
- e2e_reference_run: pass
- chaos_process_tests: pass (from previous report; not_run_in_this_step)

## E2E Method
- scenario: `playbook/verification/replay/scenario-e2e-reference.csv`
- checker: `playbook/verification/scripts/fsm-replay-check.sh`
- fixture runner: `playbook/verification/scripts/e2e-fixture-run.sh`
- generated fixture: `playbook/verification/e2e-fixture/run-2026-04-07/`

## Evidence
- fsm legality log: `playbook/verification/e2e-fixture/run-2026-04-07/reports/fsm-check.log`
- process events: `playbook/verification/e2e-fixture/run-2026-04-07/.ai/runtime/v1/process-events.ndjson`
- gate decisions: `playbook/verification/e2e-fixture/run-2026-04-07/.ai/runtime/v1/gate-decisions.ndjson`
- summary: `playbook/verification/e2e-fixture/run-2026-04-07/reports/summary.txt`
- app quality lane: `playbook/verification/e2e-fixture/run-2026-04-07/reports/app-quality-lane.log`

## Results
- transitions_checked: 46
- transition_failures: 0
- events_count: 108
- gates_count: 16
- non_happy_path_present: yes (Feature stabilize request_changes)
- operational_incident_present: yes (deployment.failed + rollback)
- app_quality_lane: pass

## Findings
- none

## Final Decision
- overall_status: pass
- blocking_issues_count: 0
- approved_by: operator
- gate_decision_ref: approved
