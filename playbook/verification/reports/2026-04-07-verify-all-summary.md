# Verification All Summary

## Metadata
- date: 2026-04-07
- mode: full-op 4-layer verification

## Status
- static_validation: pass
- deterministic_replay: pass
- e2e_reference_run: pass
- chaos_process_tests: pass

## Runtime Coverage
- e2e_op_types: 26/26
- chaos_op_types: 26/26
- e2e_events: 158
- e2e_gates: 22
- chaos_events: 89
- chaos_gates: 23
- app_quality_lane_e2e: pass
- app_quality_lane_chaos: pass

## Evidence
- static audit: `playbook/verification/replay/run-2026-04-07-full-op/static-op-coverage-audit.log`
- replay logs/hashes: `playbook/verification/replay/run-2026-04-07-full-op/`
- e2e fixture: `playbook/verification/e2e-fixture/run-2026-04-07-full-op/`
- chaos fixture: `playbook/verification/e2e-fixture/run-2026-04-07-chaos-full-op/`

## Final Decision
- overall_status: pass
- blocking_issues_count: 0
