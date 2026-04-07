# Verification Report

## Metadata
- date: 2026-04-07
- operator: codex
- playbook_version_ref: feat/test-gate-hardening@working-tree
- runtime_profile_set: stack=macos-swiftui, architecture=modular-monolith, language=pl, execution-style=iterative-tdd, storage=file-ai
- run_scope: chaos_process_tests_only

## Scope
- static_validation: pass (from previous report)
- deterministic_replay: pass (from previous report)
- e2e_reference_run: pass (from previous report)
- chaos_process_tests: pass

## Chaos Cases
1. timeout path:
- scenario: `playbook/verification/replay/scenario-chaos-timeout.csv`
- result: pass (3/3)

2. quality fail path:
- scenario: `playbook/verification/replay/scenario-chaos-quality.csv`
- result: pass (3/3)

3. deploy/rollback fail path:
- scenario: `playbook/verification/replay/scenario-chaos-deploy-rollback-fail.csv`
- result: pass (4/4)

4. gate reject path:
- scenario: `playbook/verification/replay/scenario-chaos-gate-reject.csv`
- result: pass (2/2)

5. authz denied path (trigger-level check):
- source: `playbook/layers/op/trigger-rules.md`
- result: pass (`authz.denied` rule exists and points to Exception(authz) + block)

## Findings
- none

## Final Decision
- overall_status: pass
- blocking_issues_count: 0
- approved_by: operator (pending)
- gate_decision_ref: pending
