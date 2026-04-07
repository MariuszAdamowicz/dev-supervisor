#!/usr/bin/env bash
set -euo pipefail

SPEC_FILE="${1:-playbook/runtime/playbook-exec.yaml}"
FSM_FILE="${2:-playbook/layers/op/state-machines.md}"
LIMIT="${3:-40}"

if [ ! -f "$SPEC_FILE" ]; then
  echo "ERROR missing spec file: $SPEC_FILE" >&2
  exit 2
fi
if [ ! -f "$FSM_FILE" ]; then
  echo "ERROR missing fsm file: $FSM_FILE" >&2
  exit 2
fi

if ! [[ "$LIMIT" =~ ^[0-9]+$ ]]; then
  echo "ERROR limit must be integer" >&2
  exit 2
fi

extract_chain() {
  local key="$1"
  awk -v key="$key" '
    $0 ~ "^    " key ":" {in_block=1; in_chain=0; next}
    in_block==1 && /^    [a-z_]+:/ && $0 !~ /^      / {in_block=0; in_chain=0}
    in_block==1 && /^      step_chain:/ {in_chain=1; next}
    in_block==1 && /^      required_tools:/ {in_chain=0}
    in_chain==1 && /^        - /{
      line=$0
      sub(/^        - /,"",line)
      print line
    }
  ' "$SPEC_FILE" | tr '\n' ',' | sed 's/,$//'
}

gate_chain="$(extract_chain gate_required)"
nongate_chain="$(extract_chain non_gate)"
retry_chain="$(extract_chain retry_escalation)"

echo "SIMULATION_MODE=transition-preview"
echo "SOURCE_FSM=$FSM_FILE"
echo "SOURCE_EXEC_SPEC=$SPEC_FILE"
echo "LIMIT=$LIMIT"
echo "---"

awk '
  BEGIN{n=0; op=""}
  /^### /{op=substr($0,5); next}
  /^[0-9]+\..*--.*-->/{
    n++
    if (n<=limit){
      line=$0
      sub(/^[0-9]+\. /,"",line)
      print op "|" line
    }
  }
' limit="$LIMIT" "$FSM_FILE" | while IFS='|' read -r op transition; do
  from="$(echo "$transition" | sed -E 's/ --.*$//')"
  event="$(echo "$transition" | sed -E 's/^.* --(.*)--> .*/\1/')"
  to="$(echo "$transition" | sed -E 's/^.*--> //')"

  template="non_gate"
  chain="$nongate_chain"
  if echo "$event" | rg -q '\(gate='; then
    template="gate_required"
    chain="$gate_chain"
  elif echo "$event" | rg -q 'timeout\.fired|retry-requested|recover-requested'; then
    template="retry_escalation"
    chain="$retry_chain"
  fi

  echo "OP=$op"
  echo "TRANSITION=$from --$event--> $to"
  echo "TEMPLATE=$template"
  echo "STEP_CHAIN=$chain"
  echo "---"
done
