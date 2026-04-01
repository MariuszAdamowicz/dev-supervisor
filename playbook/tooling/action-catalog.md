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

### AI orchestration

- create_ai_job
  - intent: utworzenie zadania dla ai-runner
  - required_capabilities: submit_job, write_state, append_audit

- poll_ai_job
  - intent: odczyt statusu zadania ai-runner
  - required_capabilities: poll_job, read_state

- accept_ai_result
  - intent: zaakceptowanie wyniku joba i update stanu OP
  - required_capabilities: read_state, write_state, append_audit

- retry_ai_job
  - intent: ponowienie zadania po fail/timeout
  - required_capabilities: retry_job, write_state, append_audit

- cancel_ai_job
  - intent: anulowanie zadania
  - required_capabilities: cancel_job, write_state, append_audit

- reset_ai_context
  - intent: reset kontekstu agenta i otwarcie nowej sesji
  - required_capabilities: reset_context, open_session, write_state

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
