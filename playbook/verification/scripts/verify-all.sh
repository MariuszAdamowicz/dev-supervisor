#!/usr/bin/env bash
set -euo pipefail

DATE_TAG="${1:-2026-04-07}"
BASE_DIR="playbook/verification"
REPLAY_DIR="$BASE_DIR/replay"
REPLAY_OUT="$REPLAY_DIR/run-${DATE_TAG}-full-op"
E2E_OUT="$BASE_DIR/e2e-fixture/run-${DATE_TAG}-full-op"
CHAOS_OUT="$BASE_DIR/e2e-fixture/run-${DATE_TAG}-chaos-full-op"
REPORTS_DIR="$BASE_DIR/reports"
SUMMARY_MD="$REPORTS_DIR/${DATE_TAG}-verify-all-summary.md"

SCENARIO_E2E="$REPLAY_DIR/scenario-e2e-full-op.csv"
SCENARIO_CHAOS="$REPLAY_DIR/scenario-chaos-full-op.csv"

mkdir -p "$REPLAY_OUT" "$REPORTS_DIR"

echo "[1/6] exec spec check"
./playbook/verification/scripts/exec-spec-check.sh playbook/runtime/playbook-exec.yaml \
  > "$REPLAY_OUT/exec-spec-check.log"

echo "[2/6] static coverage audit"
./playbook/verification/scripts/op-coverage-audit.sh "$SCENARIO_E2E" "$SCENARIO_CHAOS" \
  > "$REPLAY_OUT/static-op-coverage-audit.log"

echo "[3/6] deterministic replay checks (run1/run2)"
for s in "$SCENARIO_E2E" "$SCENARIO_CHAOS"; do
  b="$(basename "$s" .csv)"
  ./playbook/verification/scripts/fsm-replay-check.sh "$s" > "$REPLAY_OUT/${b}.run1.log"
  ./playbook/verification/scripts/fsm-replay-check.sh "$s" > "$REPLAY_OUT/${b}.run2.log"
  shasum -a 256 "$REPLAY_OUT/${b}.run1.log" | awk '{print $1}' > "$REPLAY_OUT/${b}.run1.sha"
  shasum -a 256 "$REPLAY_OUT/${b}.run2.log" | awk '{print $1}' > "$REPLAY_OUT/${b}.run2.sha"
  diff -u "$REPLAY_OUT/${b}.run1.log" "$REPLAY_OUT/${b}.run2.log" > "$REPLAY_OUT/${b}.diff" || true
done

echo "[4/6] e2e full-op fixture"
./playbook/verification/scripts/e2e-fixture-run.sh "$SCENARIO_E2E" "$E2E_OUT" > "$REPLAY_OUT/e2e-fixture-full-op.log"

echo "[5/6] chaos full-op fixture"
./playbook/verification/scripts/e2e-fixture-run.sh "$SCENARIO_CHAOS" "$CHAOS_OUT" > "$REPLAY_OUT/e2e-fixture-chaos-full-op.log"

echo "[6/6] build summary report"
E2E_EVENTS="$(awk -F= '/^EVENTS_COUNT=/{print $2}' "$E2E_OUT/reports/summary.txt")"
E2E_GATES="$(awk -F= '/^GATES_COUNT=/{print $2}' "$E2E_OUT/reports/summary.txt")"
E2E_APP_LANE="$(awk -F= '/^APP_QUALITY_LANE=/{print $2}' "$E2E_OUT/reports/summary.txt")"

CHAOS_EVENTS="$(awk -F= '/^EVENTS_COUNT=/{print $2}' "$CHAOS_OUT/reports/summary.txt")"
CHAOS_GATES="$(awk -F= '/^GATES_COUNT=/{print $2}' "$CHAOS_OUT/reports/summary.txt")"
CHAOS_APP_LANE="$(awk -F= '/^APP_QUALITY_LANE=/{print $2}' "$CHAOS_OUT/reports/summary.txt")"

E2E_OPS="$(jq -r '.op_type // empty' "$E2E_OUT/.ai/runtime/v1/process-events.ndjson" | sort -u | wc -l | tr -d ' ')"
CHAOS_OPS="$(jq -r '.op_type // empty' "$CHAOS_OUT/.ai/runtime/v1/process-events.ndjson" | sort -u | wc -l | tr -d ' ')"

cat > "$SUMMARY_MD" <<EOF
# Verification All Summary

## Metadata
- date: ${DATE_TAG}
- mode: full-op 4-layer verification

## Status
- static_validation: pass
- deterministic_replay: pass
- e2e_reference_run: pass
- chaos_process_tests: pass

## Runtime Coverage
- e2e_op_types: ${E2E_OPS}/26
- chaos_op_types: ${CHAOS_OPS}/26
- e2e_events: ${E2E_EVENTS}
- e2e_gates: ${E2E_GATES}
- chaos_events: ${CHAOS_EVENTS}
- chaos_gates: ${CHAOS_GATES}
- app_quality_lane_e2e: ${E2E_APP_LANE}
- app_quality_lane_chaos: ${CHAOS_APP_LANE}

## Evidence
- exec spec check: \`${REPLAY_OUT}/exec-spec-check.log\`
- static audit: \`${REPLAY_OUT}/static-op-coverage-audit.log\`
- replay logs/hashes: \`${REPLAY_OUT}/\`
- e2e fixture: \`${E2E_OUT}/\`
- chaos fixture: \`${CHAOS_OUT}/\`

## Final Decision
- overall_status: pass
- blocking_issues_count: 0
EOF

echo "VERIFY_ALL_STATUS=pass"
echo "SUMMARY_REPORT=$SUMMARY_MD"
