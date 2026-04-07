#!/usr/bin/env bash
set -euo pipefail

CATALOG_FILE="playbook/layers/op/object-catalog.md"
FSM_FILE="playbook/layers/op/state-machines.md"
BINDINGS_FILE="playbook/tooling/bindings.md"
E2E_SCENARIO="${1:-playbook/verification/replay/scenario-e2e-full-op.csv}"
CHAOS_SCENARIO="${2:-playbook/verification/replay/scenario-chaos-full-op.csv}"

if [ ! -f "$CATALOG_FILE" ] || [ ! -f "$FSM_FILE" ] || [ ! -f "$BINDINGS_FILE" ]; then
  echo "ERROR missing required playbook files" >&2
  exit 2
fi

if [ ! -f "$E2E_SCENARIO" ] || [ ! -f "$CHAOS_SCENARIO" ]; then
  echo "ERROR missing scenario file(s)" >&2
  exit 2
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

awk '
  /^### [0-9]+\./{
    name=$0
    sub(/^### [0-9]+\. /,"",name)
    print name
  }
' "$CATALOG_FILE" > "$tmp_dir/catalog_ops.txt"
sort -u "$tmp_dir/catalog_ops.txt" -o "$tmp_dir/catalog_ops.txt"
awk '
  /^## System record contracts/ {exit}
  /^### /{print substr($0,5)}
' "$FSM_FILE" > "$tmp_dir/fsm_ops.txt"
sort -u "$tmp_dir/fsm_ops.txt" -o "$tmp_dir/fsm_ops.txt"
awk -F, 'NR>1{print $1}' "$E2E_SCENARIO" | sort -u > "$tmp_dir/e2e_ops.txt"
awk -F, 'NR>1{print $1}' "$CHAOS_SCENARIO" | sort -u > "$tmp_dir/chaos_ops.txt"
awk '
  /^- [A-Za-z][A-Za-z0-9]*/{
    line=$0
    sub(/^- /,"",line)
    gsub(/,.*/,"",line)
    gsub(/[ ]+$/,"",line)
    if (line != "") print line
  }
' "$BINDINGS_FILE" | sort -u > "$tmp_dir/binding_ops_raw.txt"

# Add OPs covered by G templates list explicitly.
awk '
  /Zakres OP objetych tym mechanizmem:/ {capture=1; next}
  capture==1 && /^- /{
    line=$0
    sub(/^- /,"",line)
    gsub(/,/,"",line)
    n=split(line,a," ")
    for(i=1;i<=n;i++){
      if(a[i] ~ /^[A-Z][A-Za-z0-9]*$/) print a[i]
    }
    next
  }
  capture==1 && !/^- / && NF==0 {capture=0}
' "$BINDINGS_FILE" >> "$tmp_dir/binding_ops_raw.txt"
sort -u "$tmp_dir/binding_ops_raw.txt" > "$tmp_dir/binding_ops.txt"

missing_catalog=0
missing_fsm=0
missing_bindings=0
missing_e2e=0
missing_chaos=0
extra_fsm=0

if ! diff -u "$tmp_dir/catalog_ops.txt" "$tmp_dir/fsm_ops.txt" > "$tmp_dir/catalog-vs-fsm.diff"; then
  extra_fsm="$(comm -13 "$tmp_dir/catalog_ops.txt" "$tmp_dir/fsm_ops.txt" | wc -l | tr -d ' ')"
fi

echo "OP_COVERAGE_AUDIT_BEGIN"
while IFS= read -r op; do
  in_catalog="yes"
  in_fsm="yes"
  in_bindings="yes"
  in_e2e="yes"
  in_chaos="yes"

  if ! rg -x --fixed-strings "$op" "$tmp_dir/binding_ops.txt" >/dev/null; then
    in_bindings="no"
    missing_bindings=$((missing_bindings+1))
  fi
  if ! rg -x --fixed-strings "$op" "$tmp_dir/fsm_ops.txt" >/dev/null; then
    in_fsm="no"
    missing_fsm=$((missing_fsm+1))
  fi
  if ! rg -x --fixed-strings "$op" "$tmp_dir/e2e_ops.txt" >/dev/null; then
    in_e2e="no"
    missing_e2e=$((missing_e2e+1))
  fi
  if ! rg -x --fixed-strings "$op" "$tmp_dir/chaos_ops.txt" >/dev/null; then
    in_chaos="no"
    missing_chaos=$((missing_chaos+1))
  fi

  echo "OP=$op catalog=$in_catalog fsm=$in_fsm bindings=$in_bindings e2e=$in_e2e chaos=$in_chaos"
done < "$tmp_dir/catalog_ops.txt"

total_ops="$(wc -l < "$tmp_dir/catalog_ops.txt" | tr -d ' ')"
echo "SUMMARY total_ops=$total_ops missing_catalog=$missing_catalog missing_fsm=$missing_fsm extra_fsm=$extra_fsm missing_bindings=$missing_bindings missing_e2e=$missing_e2e missing_chaos=$missing_chaos"
echo "OP_COVERAGE_AUDIT_END"

if [ "$missing_catalog" -gt 0 ] || [ "$missing_fsm" -gt 0 ] || [ "$extra_fsm" -gt 0 ] || [ "$missing_bindings" -gt 0 ] || [ "$missing_e2e" -gt 0 ] || [ "$missing_chaos" -gt 0 ]; then
  exit 1
fi
