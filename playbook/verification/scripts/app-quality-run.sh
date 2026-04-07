#!/usr/bin/env bash
set -euo pipefail

OUT_BASE="${1:-playbook/verification/app-quality/run-2026-04-07}"
mkdir -p "$OUT_BASE"

BUILD_LOG="$OUT_BASE/build.log"
TEST_LOG="$OUT_BASE/test.log"
LINT_LOG="$OUT_BASE/lint.log"
SUMMARY="$OUT_BASE/summary.txt"

run_cmd() {
  local name="$1"
  local logfile="$2"
  shift 2

  set +e
  "$@" >"$logfile" 2>&1
  local code=$?
  set -e

  echo "$code"
}

BUILD_STATUS=$(run_cmd build "$BUILD_LOG" ./Scripts/build.sh)
TEST_STATUS=$(run_cmd test "$TEST_LOG" ./Scripts/test.sh)

# Non-mutating lint lane:
# - swiftlint (if installed)
# - swiftformat in lint mode (if installed)
LINT_STATUS=0
{
  echo "[lint] swiftlint"
  if command -v swiftlint >/dev/null 2>&1; then
    swiftlint
    SWIFTLINT_STATUS=$?
  else
    echo "swiftlint: command not found"
    SWIFTLINT_STATUS=127
  fi

  echo "[lint] swiftformat --lint ."
  if command -v swiftformat >/dev/null 2>&1; then
    swiftformat --lint .
    SWIFTFORMAT_STATUS=$?
  else
    echo "swiftformat: command not found"
    SWIFTFORMAT_STATUS=127
  fi

  echo "SWIFTLINT_STATUS=$SWIFTLINT_STATUS"
  echo "SWIFTFORMAT_STATUS=$SWIFTFORMAT_STATUS"

  if [ "$SWIFTLINT_STATUS" -ne 0 ] || [ "$SWIFTFORMAT_STATUS" -ne 0 ]; then
    LINT_STATUS=1
  fi
} >"$LINT_LOG" 2>&1 || LINT_STATUS=1

OVERALL_STATUS="pass"
if [ "$BUILD_STATUS" -ne 0 ] || [ "$TEST_STATUS" -ne 0 ] || [ "$LINT_STATUS" -ne 0 ]; then
  OVERALL_STATUS="fail"
fi

{
  echo "APP_QUALITY_LANE=$OVERALL_STATUS"
  echo "timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "build_exit_code=$BUILD_STATUS"
  echo "test_exit_code=$TEST_STATUS"
  echo "lint_exit_code=$LINT_STATUS"
  echo "build_log=$BUILD_LOG"
  echo "test_log=$TEST_LOG"
  echo "lint_log=$LINT_LOG"
} > "$SUMMARY"

cat "$SUMMARY"

if [ "$OVERALL_STATUS" != "pass" ]; then
  exit 1
fi
