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
  '^  policy-engine:'
  '^  github-adapter:'
  '^persistence_map:'
  '^baseline_contract:'
  '^authz_contract:'
  '^crud_contract:'
  '^evidence_contract:'
  '^entrypoint_contracts:'
  '^entrypoints:'
  '^  new_project:'
  '^  add_idea:'
  '^entrypoint_catalog:'
  '^transition_execution:'
  '^  compiler_mode: template_compiled'
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

github_bootstrap_steps="$(rg -n 'step_id: NP-02A|step_id: NP-02B|step_id: NP-02C' "$SPEC_FILE" | wc -l | tr -d ' ')"
if [ "$github_bootstrap_steps" -lt 3 ]; then
  echo "FAIL reason=missing_github_bootstrap_steps expected=3 got=$github_bootstrap_steps"
  exit 1
fi

if ! rg -n 'step_id: NP-03A|step_id: AI-01A' "$SPEC_FILE" >/dev/null; then
  echo "FAIL reason=missing_policy_precheck_steps"
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
