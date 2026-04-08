## Checklista entrypoint OP

- wybrany target OP (entrypoint)
- odczytany current_state
- wyznaczony next_transition
- sprawdzone guardy transition
- okreslone pending PromptTask controls
- okreslony wymagany gate decision
- znaleziony binding transition -> action -> tool

## Checklista wykonania transition

- wykonany prompt/akcja dla transition
- uruchomiony tool_plan zgodny z bindingiem
- przygotowany review package (diff + mapowanie + build/test/lint)
- decyzja GateDecisionRecord zapisana
- QualityEvidenceRecord zaktualizowany
- ProcessEventRecord zapisany
- stan OP po transition zaktualizowany

## Checklista Decision Envelope (dla gate-required)

- przygotowany `transition_ref` i target_state
- komplet guardow z wynikiem pass/fail
- jawny `change_set` (diff/artefakty/OP updates)
- jawny wynik walidacji (build/test/lint/QualityEvidenceRecord)
- jawne ryzyka, dependencies i exception status
- jawny plan rollback lub rework
- jawne skutki dla opcji: approve/request_changes/defer/reject
- wskazany uprawniony actor (`required_actor`)
- komplet `audit_refs` do powiazania GateDecisionRecord z ProcessEventRecord

## Checklista AI job

- utworzony job ai-runner (job_id)
- zarejestrowany status polling
- zdefiniowany timeout i retry policy
- zdefiniowana polityka cancel/reset_context
- wynik zaakceptowany przez operatora lub odrzucony z reason

## Checklista feature runtime

- Feature OP utworzony i powiazany z Idea
- ChangeSet powiazany z Feature i repozytorium, gdy scope dotyka kodu
- Requirement/Constraint/DecisionRecord powiazane z Feature
- UseCase OP istnieja dla kluczowych zachowan Feature
- PortContract OP sa zatwierdzone dla granic z adapterami
- Component OP ma wynik check bez cykli zaleznosci
- VerificationPolicy wskazuje wymagane lane dla Feature
- krytyczne Requirement sa w stanie `linked` przed `Feature.done`
- krytyczne Constraint sa w stanie `enforced` lub `revised` przed `Feature.done`
- wymagane DecisionRecord sa w stanie `approved` przed `Feature.done`
- Scenario OP powiazane z testami
- dependency relations i RiskEntry ocenione
- brak krytycznych otwartych PromptTask controls

## Checklista release runtime

- ReleaseBundle candidate utworzony
- GateDecisionRecord approve dla release
- QualityEvidenceRecord pass
- EnvironmentTarget jest w stanie co najmniej `ready`
- DeploymentRun planned albo running istnieje
- rollback/compensation plan gotowy

## Checklista repository i changeset

- Repository istnieje i ma przypiety remote/policy
- ChangeSet ma jawny file scope i traceability do OP pracy
- commit refs sa zapisane po `ChangeSet.committed`
- brak nieautoryzowanych zmian poza zakresem owned paths

## Checklista danych i srodowisk

- DataSchema istnieje dla zmian dotykajacych trwale dane
- Migration istnieje dla zmian niekompatybilnych lub operacyjnie istotnych
- EnvironmentTarget ma capability, config i constraints jawne dla lane
- rollback lub compatibility plan jest jawny dla danych i deploymentu

## Checklista audytu OP

- kazde krytyczne przejscie ma event + guard + actor
- kazda decyzja gate ma ProcessEventRecord
- brak osieroconych OP
- brak niespojnych stanow OP nadrzedny/podrzedny
- kazdy transition ma wynik authz precheck (pass/fail)
- dla kazdego OP istnieje co najmniej jedna sciezka non-happy path (rework/retry/defer/reject/escalation)
- kazdy event legalny dla OP ma jawne mapowanie `from_state -> to_state` w `layers/op/state-machines.md`

## Checklista audytu tooling

- kazdy krytyczny transition ma binding w tooling/bindings.md
- kazda akcja z action_plan ma capability w tool-registry.md
- profile nie zmieniaja intent akcji, tylko mapowanie tool_plan
- brak uruchomien narzedzi poza zadeklarowanym bindingiem
- kazdy binding ma jawny authz precheck (AccessGrant)

## Checklista audytu playbook contracts

- coverage contract: transition OP -> binding
- capability contract: action -> capability -> tool
- gate contract: gate-required ma decide_gate + operator-ui
- audit contract: krytyczne akcje maja ProcessEventRecord
- source-of-truth contract: brak konfliktu z layers/op/*
- AI orchestration contract: control-plane i scheduler sa po stronie DS

## Checklista verification run

- static validation wykonane i oznaczone PASS/FAIL
- deterministic replay wykonany dla scenariuszy referencyjnych
- e2e reference run wykonany na mini-projekcie
- chaos process tests wykonane (timeout/authz/quality/deploy/rollback/gate reject)
- raport verification zapisany wg verification/report-template.md

## Checklista architektury (Martin alignment)

- use-case first: implementacja mapuje sie na UseCase, nie na framework task
- dependency direction: zaleznosci kodu ida do rdzenia (inward-only)
- boundary DTO: przez granice przechodza DTO, bez typow frameworka
- composition root: podpinanie adapterow jest w jednym jawnym miejscu
- ADP: brak cykli zaleznosci miedzy Component
- SDP/SAP: stabilniejsze Component nie zalezne od mniej stabilnych szczegolow
- domain purity: reguly biznesowe testowalne bez UI/DB/sieci
