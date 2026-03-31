# OP -> Action -> Tool Bindings

Cel:
deterministycznie mapowac przejscia OP na akcje i konkretne narzedzia.

## Kontrakt bindingu

Kazdy binding ma:
- transition_ref (OP from -> to)
- event_ref (source event z OP trigger rules)
- action_plan (lista action_id)
- tool_plan (lista tool invocations)
- required (true/false)
- guards
- failure_policy

## Baseline bindingi krytyczne

### A. Project

1. Project.created -> Project.configured
- event_ref: project.initialize-requested
- action_plan: initialize_project
- tool_plan:
  - operator-ui: podaj nazwe/opis projektu
  - storage-adapter: utworz runtime storage
- required: true

2. Project.configured -> Project.baseline-approved
- event_ref: project.baseline-ready
- action_plan: select_profiles, decide_gate
- tool_plan:
  - operator-ui: wizard wyboru profili + confirm gate
  - storage-adapter: persist profile set
- guards:
  - overview/constraints/glossary istnieja
- required: true

3. Project.baseline-approved -> Project.active
- event_ref: gate.approve
- action_plan: ingest_prompt_result
- tool_plan:
  - storage-adapter: update stanu OP
- required: true

### B. Idea -> Feature

4. Idea.captured -> Idea.scoped
- event_ref: idea.scope-requested
- action_plan: produce_prompt_task, ingest_prompt_result
- tool_plan:
  - prompt-transport: IDEA -> FEATURES prompt
  - operator-ui: confirm imported scope
  - storage-adapter: zapis scope
- required: true

5. Idea.scoped -> Idea.converted
- event_ref: idea.convert-approved
- action_plan: decide_gate
- tool_plan:
  - operator-ui: approve conversion do Feature
  - storage-adapter: zapis GateDecision + Feature create
- required: true

6. Idea.scoped -> Idea.dropped
- event_ref: idea.drop-approved
- action_plan: decide_gate
- tool_plan:
  - operator-ui: reject/defer z reason
  - storage-adapter: audit + closed reason
- required: true

### C. Feature spec/test/impl

7. Feature.drafted -> Feature.specified
- event_ref: Idea.scoped
- action_plan: produce_prompt_task, ingest_prompt_result
- tool_plan:
  - prompt-transport: IDEA -> PRD
  - operator-ui: confirm PRD import
  - storage-adapter: persist PRD
- required: true

8. Feature.specified -> Feature.ux-aligned
- event_ref: Feature.specified
- action_plan: produce_prompt_task, ingest_prompt_result
- tool_plan:
  - prompt-transport: ux-contract-check + term-extract
  - operator-ui: approve term/ui deltas
  - storage-adapter: update Term/UIComponent/UIScreen
- required: true

9. Feature.ux-aligned -> Feature.scenario-ready
- event_ref: Feature.ux-aligned
- action_plan: produce_prompt_task, ingest_prompt_result
- tool_plan:
  - prompt-transport: PRD -> BDD
  - operator-ui: approve scenario package
  - storage-adapter: persist BDD
- required: true

10. Feature.scenario-ready -> Feature.test-ready
- event_ref: Scenario.approved
- action_plan: produce_prompt_task, ingest_prompt_result
- tool_plan:
  - prompt-transport: BDD -> TESTY
  - operator-ui: confirm test mapping
  - storage-adapter: persist tests + traceability
- required: true

11. Feature.test-ready -> Feature.implemented
- event_ref: tests.implemented
- action_plan: run_validation_suite
- tool_plan (macos-swiftui):
  - shell: ./Scripts/build.sh
  - shell: ./Scripts/test.sh
  - shell: ./Scripts/lint.sh
- guards:
  - wszystkie krytyczne scenariusze maja testy
- required: true

12. Feature.implemented -> Feature.stabilized
- event_ref: PromptTask.executed
- action_plan: produce_review_package, decide_gate, commit_checkpoint
- tool_plan:
  - shell: review package generator
  - operator-ui: gate approve/request_changes/defer/reject
  - git: add + commit
- required: true

### D. Term / UIComponent / UIScreen

13. Term.proposed -> Term.approved
- event_ref: Term.proposed
- action_plan: produce_prompt_task, decide_gate
- tool_plan:
  - prompt-transport: term-impact-check
  - operator-ui: approve term scope
  - storage-adapter: persist term + impacts
- required: true

14. UIComponent.proposed -> UIComponent.mapped
- event_ref: UIComponent.proposed
- action_plan: produce_prompt_task, ingest_prompt_result
- tool_plan:
  - prompt-transport: ui-placement
  - operator-ui: confirm placement
  - storage-adapter: update UI map
- required: true

15. UIComponent.mapped -> UIComponent.implemented
- event_ref: UIComponent.mapped
- action_plan: produce_prompt_task, ingest_prompt_result
- tool_plan:
  - prompt-transport: ui-implementation
  - operator-ui: confirm implementation import
  - storage-adapter: update component state
- required: true

16. UIComponent.implemented -> UIComponent.verified
- event_ref: UIComponent.implemented
- action_plan: run_validation_suite, decide_gate
- tool_plan:
  - quality-runner: UI validation tests
  - operator-ui: approve UX validation
- required: true

17. UIScreen.proposed -> UIScreen.mapped
- event_ref: screen.mapping-requested
- action_plan: produce_prompt_task, ingest_prompt_result
- tool_plan:
  - prompt-transport: screen-flow mapping
  - operator-ui: confirm screen map
  - storage-adapter: update UIScreen
- required: true

18. UIScreen.mapped -> UIScreen.verified
- event_ref: screen.validation-requested
- action_plan: run_validation_suite, decide_gate
- tool_plan:
  - quality-runner: navigation + visibility checks
  - operator-ui: approve UX gate
- required: true

### E. PromptTask / Quality / Exception

19. PromptTask.created -> PromptTask.ready
- event_ref: prompt.context-ready
- action_plan: produce_prompt_task
- tool_plan:
  - prompt-transport: prepare_prompt + hash_context
  - storage-adapter: persist PromptTask
- required: true

20. PromptTask.ready -> PromptTask.executed
- event_ref: prompt.sent
- action_plan: ingest_prompt_result
- tool_plan:
  - prompt-transport: send_prompt + ingest_response
  - operator-ui: confirm response acceptance
- required: true

21. QualitySignal.evaluated -> QualitySignal.fail
- event_ref: quality.failed
- action_plan: request_rework
- tool_plan:
  - storage-adapter: utworz Exception + debug task
  - operator-ui: confirm rework/defer
- required: true

22. Exception.detected -> Exception.handled
- event_ref: exception.fix-applied
- action_plan: run_validation_suite, decide_gate
- tool_plan:
  - quality-runner: rerun failing suite
  - operator-ui: close/escalate exception
- required: true

23. Timeout.fired -> Timeout.handled
- event_ref: timeout.fired
- action_plan: decide_gate
- tool_plan:
  - operator-ui: defer/reject z reason
  - storage-adapter: zapis timeout resolution
- required: true

### F. Release / Deployment / Rollback

24. Feature.stabilized -> Release.candidate
- event_ref: Feature.stabilized
- action_plan: start_release
- tool_plan:
  - storage-adapter: utworz release candidate
  - operator-ui: confirm release scope
- guards:
  - brak critical Exception
  - Dependency != blocked
- required: true

25. Release.candidate -> Release.approved
- event_ref: release.gate-requested
- action_plan: decide_gate
- tool_plan:
  - operator-ui: release approve/request_changes/defer/reject
  - storage-adapter: persist gate
- required: true

26. Release.approved -> Deployment.prepared
- event_ref: Release.approved
- action_plan: deploy_release
- tool_plan:
  - deployment-adapter: deploy prepare
  - operator-ui: confirm deploy start
- required: true

27. Deployment.prepared -> Deployment.running -> Deployment.succeeded
- event_ref: deployment.started/completed
- action_plan: deploy_release
- tool_plan:
  - deployment-adapter: execute deploy
  - storage-adapter: persist deployment status
- required: true

28. Deployment.running -> Deployment.failed
- event_ref: deployment.failed
- action_plan: run_rollback
- tool_plan:
  - deployment-adapter: detect fail + emit signal
  - storage-adapter: create Rollback + Compensation
- required: true

29. Deployment.failed -> Rollback.prepared -> Rollback.running -> Rollback.succeeded
- event_ref: Deployment.failed
- action_plan: run_rollback, decide_gate
- tool_plan:
  - deployment-adapter: rollback
  - operator-ui: confirm rollback/close
  - storage-adapter: persist compensation outcome
- required: true

## Reguly

- Aplikacja nie wylicza samodzielnie komend; korzysta z bindingow.
- Profile moga nadpisac tool_plan, ale nie intent action.
- Brak bindingu dla legal transition oznacza konfiguracje niekompletna.
- Jesli action wymaga decyzji czlowieka, tool_plan musi zawierac operator-ui.
- Zmiana stanu OP przez UI bez odpowiadajacego bindingu jest niedozwolona.
- Kazdy binding krytyczny musi miec audit trace: ProcessEvent + GateDecision (jesli gate wystepuje).
