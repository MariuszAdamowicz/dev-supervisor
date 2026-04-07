#!/usr/bin/env bash
set -euo pipefail

SPEC_FILE="${1:-playbook/runtime/playbook-exec.yaml}"

if [ ! -f "$SPEC_FILE" ]; then
  echo "ERROR missing exec spec: $SPEC_FILE" >&2
  exit 2
fi

required_patterns=(
  '^schema_version:'
  '^source_of_truth:'
  '^determinism_contract:'
  '^tool_contracts:'
  '^persistence_map:'
  '^entrypoints:'
  '^  new_project:'
  '^  add_idea:'
  '^failure_and_retry_policy:'
  '^git_ci_contract:'
)

for p in "${required_patterns[@]}"; do
  if ! rg -n "$p" "$SPEC_FILE" >/dev/null; then
    echo "FAIL missing_pattern=$p"
    exit 1
  fi
done

if rg -n 'tool: .*\\+' "$SPEC_FILE" >/dev/null; then
  echo "FAIL rule=one_tool_per_step reason=invalid_tool_union"
  exit 1
fi

step_count="$(rg -n '^[[:space:]]+- step_id:' "$SPEC_FILE" | wc -l | tr -d ' ')"
tool_count="$(rg -n '^[[:space:]]+tool:' "$SPEC_FILE" | wc -l | tr -d ' ')"
success_count="$(rg -n '^[[:space:]]+success_output:' "$SPEC_FILE" | wc -l | tr -d ' ')"

if [ "$step_count" -eq 0 ]; then
  echo "FAIL reason=no_steps_defined"
  exit 1
fi

if [ "$step_count" -ne "$tool_count" ]; then
  echo "FAIL reason=tool_count_mismatch steps=$step_count tools=$tool_count"
  exit 1
fi

if [ "$step_count" -ne "$success_count" ]; then
  echo "FAIL reason=success_output_count_mismatch steps=$step_count success_output=$success_count"
  exit 1
fi

echo "EXEC_SPEC_CHECK=pass"
echo "spec_file=$SPEC_FILE"
echo "steps=$step_count"
