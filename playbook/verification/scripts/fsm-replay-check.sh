#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "usage: $0 <scenario-csv>" >&2
  exit 2
fi

SCENARIO="$1"
FSM_FILE="playbook/layers/op/state-machines.md"

if [ ! -f "$SCENARIO" ]; then
  echo "ERROR scenario not found: $SCENARIO" >&2
  exit 2
fi

if [ ! -f "$FSM_FILE" ]; then
  echo "ERROR fsm file not found: $FSM_FILE" >&2
  exit 2
fi

pass=0
fail=0
idx=0

while IFS=, read -r op from event to; do
  idx=$((idx+1))

  if [ "$idx" -eq 1 ]; then
    continue
  fi

  if [ -z "$op" ] || [ -z "$from" ] || [ -z "$event" ] || [ -z "$to" ]; then
    echo "FAIL step=$idx reason=invalid_csv_row"
    fail=$((fail+1))
    continue
  fi

  pattern="$from --$event--> $to"

  if rg -F -- "$pattern" "$FSM_FILE" >/dev/null; then
    echo "PASS op=$op from=$from event=$event to=$to"
    pass=$((pass+1))
  else
    echo "FAIL op=$op from=$from event=$event to=$to reason=transition_not_found"
    fail=$((fail+1))
  fi
done < "$SCENARIO"

echo "SUMMARY pass=$pass fail=$fail scenario=$SCENARIO"

if [ "$fail" -gt 0 ]; then
  exit 1
fi
