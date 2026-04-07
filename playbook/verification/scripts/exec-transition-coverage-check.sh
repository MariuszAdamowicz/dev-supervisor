#!/usr/bin/env bash
set -euo pipefail

SPEC_FILE="${1:-playbook/runtime/playbook-exec.yaml}"
FSM_FILE="${2:-playbook/layers/op/state-machines.md}"

if [ ! -f "$SPEC_FILE" ]; then
  echo "ERROR missing spec file: $SPEC_FILE" >&2
  exit 2
fi
if [ ! -f "$FSM_FILE" ]; then
  echo "ERROR missing fsm file: $FSM_FILE" >&2
  exit 2
fi

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

rg -n '^[0-9]+\..*--.*-->' "$FSM_FILE" | sed -E 's/^[0-9]+://' > "$tmp"

total="$(wc -l < "$tmp" | tr -d ' ')"
gate_count="$(rg -c '\(gate=' "$tmp" || true)"
retry_count="$(rg -c 'timeout\.fired|retry-requested|recover-requested' "$tmp" || true)"
non_gate_count="$(( total - gate_count ))"

if [ "$total" -eq 0 ]; then
  echo "FAIL reason=no_fsm_transitions_detected"
  exit 1
fi

required_patterns=(
  '^transition_execution:'
  '^  compiler_mode: template_compiled'
  '^  coverage_policy:'
  '^    all_fsm_transitions_must_bind: true'
  '^    explicit_override_or_template_required: true'
  '^  templates:'
  '^    gate_required:'
  '^    non_gate:'
  '^    retry_escalation:'
)

for p in "${required_patterns[@]}"; do
  if ! rg -n "$p" "$SPEC_FILE" >/dev/null; then
    echo "FAIL reason=missing_exec_transition_section pattern=$p"
    exit 1
  fi
done

echo "EXEC_TRANSITION_COVERAGE=pass"
echo "fsm_total_transitions=$total"
echo "fsm_gate_transitions=$gate_count"
echo "fsm_non_gate_transitions=$non_gate_count"
echo "fsm_retry_escalation_like_transitions=$retry_count"
echo "coverage_mode=template_compiled"
