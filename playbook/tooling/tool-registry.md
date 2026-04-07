# Tool Registry

Cel:
zdefiniowac komplet narzedzi dostepnych dla Playbook Layer, niezaleznie od konkretnego runtime projektu.

## Kontrakt narzedzia

Kazde narzedzie ma:
- tool_id
- class (human | app | cli | service)
- scope (global | profile | runtime)
- capabilities
- adapter (jak wywolac)
- preconditions
- failure_modes
- observability (jak logowac wynik)

## Narzedzia baseline (wymagane)

### 1. operator-ui (human)
- class: human
- capabilities: choose_action, confirm_gate, provide_input, approve_reject, collect_inline_form, show_status, explain_blocker, progressive_disclosure
- adapter: akcja operatora w UI aplikacji
- observability: ProcessEventRecord z actor_role=operator

### 2. ai-runner (service)
- class: service
- capabilities: submit_job, poll_job, cancel_job, retry_job, reset_context, open_session
- adapter: direct LLM API (preferowane)
- observability: job_id, request_id, status, retry_count, context_revision

### 3. storage-adapter (app)
- class: app
- capabilities: read_state, write_state, persist_artifacts, append_audit
- adapter: profile storage file-ai lub sqlbase
- observability: ProcessEventRecord + wersja zapisu

### 3a. policy-engine (app)
- class: app
- capabilities: authorize_transition, validate_semantics, validate_invariants, classify_evidence
- adapter: deterministyczny silnik polityk i invariantow
- observability: ProcessEventRecord + wynik authz/guard/invariant/provenance

### 4. shell (cli)
- class: cli
- capabilities: execute_script, execute_command
- adapter: lokalna powloka
- observability: kod wyjscia + log skrocony

### 5. git (cli)
- class: cli
- capabilities: init, branch, checkout, status, diff, add, commit, merge, rebase, remote, fetch, pull, push, tag
- adapter: lokalny git
- observability: hash commit, branch, diff summary

### 6. quality-runner (cli/profile)
- class: cli
- capabilities: build, test, lint, format, coverage, unit_test, integration_test, acceptance_test, e2e_test, smoke_test
- adapter: stack profile (np. xcodebuild/swiftlint/swiftformat)
- observability: QualityEvidenceRecord pass/fail + metryki

## Narzedzia opcjonalne

### 7. mcp-bridge (service)
- class: service
- capabilities: transport_tool_call, transport_tool_result
- adapter: MCP server/client
- observability: mcp_server, tool_name, call_id

Uwagi:
- mcp-bridge jest adapterem transportowym do narzedzi, w tym ai-runner.
- mcp-bridge sam nie gwarantuje wykonania retry/scheduler/reset_context.
- gwarancje procesu zapewnia DS orchestration.

## Narzedzia profilowe (przyklady)

- xcodebuild (stack: macos-swiftui)
  - capabilities: build, test
- swiftlint (stack: macos-swiftui)
  - capabilities: lint
- swiftformat (stack: macos-swiftui)
  - capabilities: format
- npm/pnpm (stack: react-node-postgres)
  - capabilities: install, build, test, lint
- pytest/ruff (stack: python-fastapi-react)
  - capabilities: test, lint
- deployment-adapter (runtime)
  - capabilities: deploy, rollback, verify_environment

## Zasady

- Operator jest legalnym narzedziem wykonawczym: zmiana stanu przez UI jest tool invocation.
- Agent AI jest legalnym narzedziem wykonawczym: wywolania sa job-based i sterowane przez DS.
- Profil moze dodac narzedzia, ale nie moze usunac baseline bez jawnego override policy.
- Kazde uruchomienie narzedzia (takze operator-ui i ai-runner) musi byc audytowane przez ProcessEventRecord.
- Kazdy state-changing flow przechodzi przez `policy-engine` przed zapisem stanu.
- Brak narzedzia wymaganej capability blokuje transition OP.
- Playbook Layer mapuje transition na akcje i narzedzia; aplikacja nie zgaduje narzedzi dynamicznie.
