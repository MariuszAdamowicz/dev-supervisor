# Verification All Summary

## Metadata
- date: 2026-04-08
- mode: full-op enhanced verification

## Status
- static_validation: pass
- semantic_validation: pass
- deterministic_replay: pass
- e2e_reference_run: fixture-pass
- chaos_process_tests: pass
- real_runtime_capture: no

## Runtime Coverage
- e2e_op_types: 25/25
- chaos_op_types: 25/25
- e2e_events: 181
- e2e_gates: 27
- chaos_events: 87
- chaos_gates: 27
- e2e_evidence_class: fixture-simulation
- chaos_evidence_class: fixture-simulation
- app_quality_lane_e2e: pass
- app_quality_lane_chaos: pass

## Evidence
- exec spec check: `playbook/verification/replay/run-2026-04-08-full-op/exec-spec-check.log`
- exec transition coverage: `playbook/verification/replay/run-2026-04-08-full-op/exec-transition-coverage-check.log`
- static audit: `playbook/verification/replay/run-2026-04-08-full-op/static-op-coverage-audit.log`
- semantic audit: `playbook/verification/replay/run-2026-04-08-full-op/semantic-contract-audit.log`
- replay logs/hashes: `playbook/verification/replay/run-2026-04-08-full-op/`
- e2e fixture: `playbook/verification/e2e-fixture/run-2026-04-08-full-op/`
- chaos fixture: `playbook/verification/e2e-fixture/run-2026-04-08-chaos-full-op/`

## Final Decision
- overall_status: partial
- blocking_issues_count: 1
- blocking_issue_1: brak real runtime capture, fixture evidence nie wystarcza do globalnego PASS
