# Action Catalog

Cel:
opisac neutralne akcje procesu, niezalezne od konkretnego narzedzia.

## Kontrakt akcji

Kazda akcja ma:
- action_id
- intent
- required_capabilities
- required_inputs
- success_outputs
- failure_policy
- audit_event

## Akcje bazowe

### Inicjalizacja i plan

- initialize_project
  - intent: utworzenie instancji projektu i baseline OP
  - required_capabilities: write_state, provide_input

- select_profiles
  - intent: wybor profili playbooka przez operatora
  - required_capabilities: choose_action, write_state

- produce_prompt_task
  - intent: wygenerowanie PromptTask dla AI
  - required_capabilities: prepare_prompt, hash_context, write_state

- ingest_prompt_result
  - intent: zapis wyniku promptu i update stanu OP
  - required_capabilities: ingest_response, write_state, append_audit

### Implementacja i jakosc

- prepare_branch
  - intent: przygotowanie izolowanej pracy
  - required_capabilities: branch

- run_validation_suite
  - intent: walidacja build/test/lint
  - required_capabilities: build, test, lint

- commit_checkpoint
  - intent: zapis punktu kontrolnego zmian
  - required_capabilities: add, commit

- produce_review_package
  - intent: przygotowanie materialu do GateDecision
  - required_capabilities: execute_script, read_state

### Gate i decyzje

- decide_gate
  - intent: zapis decyzji operatora
  - required_capabilities: confirm_gate, approve_reject, append_audit

- request_rework
  - intent: cofniecie do poprawy po gate
  - required_capabilities: choose_action, write_state

### Release i operacje

- start_release
  - intent: utworzenie Release candidate
  - required_capabilities: write_state, append_audit

- deploy_release
  - intent: wykonanie deployment
  - required_capabilities: deploy

- run_rollback
  - intent: cofniecie deployment
  - required_capabilities: rollback
