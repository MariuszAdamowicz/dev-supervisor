# OP -> Action -> Tool Bindings

Cel:
deterministycznie mapowac przejscia OP na akcje i konkretne narzedzia.

## Kontrakt bindingu

Kazdy binding ma:
- transition_ref (OP from -> to)
- action_plan (lista action_id)
- tool_plan (lista tool invocations)
- required (true/false)
- guards
- failure_policy

## Baseline bindingi krytyczne

### 1. Project.initialized -> Project.baselined
- action_plan:
  - initialize_project
  - select_profiles
- tool_plan:
  - operator-ui: wizard input + confirmation
  - storage-adapter: persist baseline + profile selection
- required: true

### 2. Idea.captured -> Idea.scoped
- action_plan:
  - produce_prompt_task
  - ingest_prompt_result
- tool_plan:
  - prompt-transport: prepare/send prompt IDEA -> FEATURES
  - operator-ui: confirm imported result
  - storage-adapter: zapis idea scope
- required: true

### 3. Feature.spec-ready -> Feature.test-ready
- action_plan:
  - produce_prompt_task
  - ingest_prompt_result
- tool_plan:
  - prompt-transport: PRD -> BDD -> TESTY prompt flow
  - operator-ui: approve scenario package
  - storage-adapter: aktualizacja artifacts i traceability
- required: true

### 4. Feature.test-ready -> Feature.implemented
- action_plan:
  - run_validation_suite
- tool_plan (macos-swiftui):
  - shell: ./Scripts/build.sh
  - shell: ./Scripts/test.sh
  - shell: ./Scripts/lint.sh
- required: true

### 5. Feature.implemented -> Feature.stabilized
- action_plan:
  - produce_review_package
  - decide_gate
  - commit_checkpoint
- tool_plan:
  - shell: review package generator
  - operator-ui: gate approve/request_changes/defer/reject
  - git: add + commit
- required: true

### 6. Feature.stabilized -> Release.candidate
- action_plan:
  - start_release
- tool_plan:
  - storage-adapter: utworz release candidate
  - operator-ui: confirm release scope
- required: true

### 7. Release.approved -> Deployment.prepared
- action_plan:
  - deploy_release
- tool_plan:
  - deployment-adapter: deploy
  - operator-ui: confirm deploy start
- required: true

### 8. Deployment.failed -> Rollback.prepared
- action_plan:
  - run_rollback
- tool_plan:
  - deployment-adapter: rollback
  - operator-ui: confirm rollback
- required: true

## Reguly

- Aplikacja nie wylicza samodzielnie komend; korzysta z bindingow.
- Profile moga nadpisac tool_plan, ale nie intent action.
- Brak bindingu dla legal transition oznacza konfiguracje niekompletna.
- Jesli action wymaga decyzji czlowieka, tool_plan musi zawierac operator-ui.
- Zmiana stanu OP przez UI bez odpowiadajacego bindingu jest niedozwolona.
