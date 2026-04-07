#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-playbook}"

require_pattern() {
  local pattern="$1"
  local file="$2"
  if ! rg -n "$pattern" "$file" >/dev/null; then
    echo "FAIL file=$file missing_pattern=$pattern"
    exit 1
  fi
}

files=(
  "$ROOT/runtime/playbook-exec.yaml"
  "$ROOT/workflow/setup.md"
  "$ROOT/workflow/daily-workflow.md"
  "$ROOT/validation/playbook-contracts.md"
  "$ROOT/tooling/tool-registry.md"
  "$ROOT/tooling/action-catalog.md"
  "$ROOT/tooling/bindings.md"
  "$ROOT/verification/semantic-validation.md"
  "$ROOT/verification/evidence-provenance.md"
)

for f in "${files[@]}"; do
  if [ ! -f "$f" ]; then
    echo "FAIL missing_file=$f"
    exit 1
  fi
done

require_pattern '^baseline_contract:' "$ROOT/runtime/playbook-exec.yaml"
require_pattern '^authz_contract:' "$ROOT/runtime/playbook-exec.yaml"
require_pattern '^crud_contract:' "$ROOT/runtime/playbook-exec.yaml"
require_pattern '^evidence_contract:' "$ROOT/runtime/playbook-exec.yaml"
require_pattern '^entrypoint_catalog:' "$ROOT/runtime/playbook-exec.yaml"
require_pattern 'policy-engine' "$ROOT/runtime/playbook-exec.yaml"

require_pattern 'ActorRolePermission' "$ROOT/workflow/setup.md"
require_pattern '\.ai/ux/new-project\.md' "$ROOT/workflow/setup.md"
require_pattern '\.ai/architecture/use-cases\.md' "$ROOT/workflow/setup.md"
require_pattern 'Product baseline maintenance' "$ROOT/workflow/daily-workflow.md"
require_pattern 'ActorRolePermission' "$ROOT/workflow/daily-workflow.md"
require_pattern 'policy-engine' "$ROOT/workflow/daily-workflow.md"

require_pattern 'Baseline completeness contract' "$ROOT/validation/playbook-contracts.md"
require_pattern 'Runtime lifecycle coverage contract' "$ROOT/validation/playbook-contracts.md"
require_pattern 'CRUD integrity contract' "$ROOT/validation/playbook-contracts.md"
require_pattern 'Semantic guard contract' "$ROOT/validation/playbook-contracts.md"
require_pattern 'Evidence provenance contract' "$ROOT/validation/playbook-contracts.md"

require_pattern 'policy-engine' "$ROOT/tooling/tool-registry.md"
require_pattern 'authorize_transition' "$ROOT/tooling/action-catalog.md"
require_pattern 'validate_semantics' "$ROOT/tooling/action-catalog.md"
require_pattern 'Kontrakt globalny runtime' "$ROOT/tooling/bindings.md"

echo "SEMANTIC_CONTRACT_AUDIT=pass"
