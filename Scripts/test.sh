#!/bin/bash
set -euo pipefail

SCHEME=${1:-DevSupervisor}
DESTINATION=${DESTINATION:-platform=macOS}
ONLY_TESTING=${ONLY_TESTING:-DevSupervisorTests}
TEST_TIMEOUT_SECONDS=${TEST_TIMEOUT_SECONDS:-900}

LOG_DIR=${LOG_DIR:-"$(pwd)/.artifacts"}
mkdir -p "$LOG_DIR"
LOG_PATH="$LOG_DIR/xcodebuild-test.log"

xcodebuild \
  clean test \
  -scheme "$SCHEME" \
  -destination "$DESTINATION" \
  -only-testing:"$ONLY_TESTING" \
  > >(tee "$LOG_PATH") 2>&1 &
xcodebuild_pid=$!

(
  sleep "$TEST_TIMEOUT_SECONDS"
  if kill -0 "$xcodebuild_pid" 2>/dev/null; then
    echo "ERROR: test.sh timeout after ${TEST_TIMEOUT_SECONDS}s. Terminating xcodebuild." >&2
    kill "$xcodebuild_pid" 2>/dev/null || true
  fi
) &
watchdog_pid=$!

set +e
wait "$xcodebuild_pid"
xcodebuild_status=$?
set -e
kill "$watchdog_pid" 2>/dev/null || true
wait "$watchdog_pid" 2>/dev/null || true

if [[ "$xcodebuild_status" -ne 0 ]]; then
  echo "ERROR: xcodebuild test failed with code $xcodebuild_status." >&2
  exit "$xcodebuild_status"
fi

executed_tests=$(grep -Eo 'Executed [0-9]+ tests?' "$LOG_PATH" | tail -n 1 | awk '{print $2}' || true)

if [[ -z "$executed_tests" ]]; then
  # Fallback for xcodebuild formats that omit "Executed N tests" summary lines.
  executed_tests=$(grep -Ec "Test case '.*' (passed|failed)" "$LOG_PATH" || true)
fi

if [[ "$executed_tests" -le 0 ]]; then
  echo "ERROR: xcodebuild reported 0 executed tests. Failing deterministic test gate." >&2
  exit 1
fi

echo "Deterministic test gate passed: executed tests count = $executed_tests"
