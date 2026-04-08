## Daily workflow (OP-driven)

Zasada nadrzedna:
Operator nie wybiera "kroku pipeline" recznie.
Operator wybiera entrypoint OP albo control, a system wyznacza next_transition z OP Layer.

Kanoniczna semantyka:
- layers/op/object-catalog.md
- layers/op/authz-contracts.md
- layers/op/data-contracts.md
- layers/op/decision-contracts.md
- layers/op/delivery-contracts.md
- layers/op/environment-contracts.md
- layers/op/exception-contracts.md
- layers/op/glossary-contracts.md
- layers/op/job-contracts.md
- layers/op/relation-contracts.md
- layers/op/risk-contracts.md
- layers/op/recovery-contracts.md
- layers/op/scheduler-contracts.md
- layers/op/version-control-contracts.md
- layers/op/verification-contracts.md
- runtime/scheduling-contract.md
- layers/op/state-machines.md
- layers/op/trigger-rules.md

## 1. Wybierz entrypoint procesu

Dopuszczalne entrypointy (zalezne od kontekstu):
- Project (nowy projekt / re-konfiguracja)
- Product baseline maintenance
- Repository/ChangeSet (VCS i scope zmiany)
- Idea (intake i scoping)
- Feature (spec/test/implement)
- VerificationPolicy (polityka unit/integration/acceptance/e2e)
- UseCase/PortContract (granice i kontrakty aplikacyjne)
- Component / relation graph (reguly zaleznosci i spojnosci)
- DataSchema/MigrationAction (ewolucja danych)
- GlossaryEntry/UIComponent (UX alignment)
- AccessGrant / authz controls
- EnvironmentTarget (gotowosc lane i deploymentu)
- ReleaseBundle (delivery)
- ExceptionCase / recovery controls / scheduler timer escalation (obsluga awarii)

## 2. Odczytaj stan instancji OP

Dla wybranego OP ustal:
- current_state
- legalne przejscia
- guardy blokujace
- pending PromptTask control
- latest GateDecisionRecord
- parent linkage i impacted children
- evidence class ostatnich kluczowych dowodow

## 3. Wyznacz next_transition

Next transition wynika z OP state machine + guardow.
Playbook nie tworzy alternatywnej logiki przejsc.
Jesli kilka OP/control jest jednoczesnie gotowych, wybor primary step rozstrzyga `runtime/scheduling-contract.md`.

## 4. Zbuduj projection dla operatora

Z OP -> UI/Prompt/Checklist:
- jaka jedna akcje pokazac (next best action)
- jaki minimalny kontekst zaladowac
- jaki prompt/job uruchomic
- jakie warunki gate musza byc spelnione
- jakie checki architektury sa wymagane (dependency direction, no-cycle, DTO boundary)
- jakie elementy sa widoczne tylko w audit/debug

Zasada:
- runtime moze materializowac wiele OP/control po jednym evencie,
- ale projection pokazuje tylko jeden `primary active step`,
- pozostale kandydaty sa secondary (`pending|blocked|waiting`).

## 4a. Wyznacz Action i Tool plan

Na bazie tooling:
- tooling/action-catalog.md
- tooling/tool-registry.md
- tooling/bindings.md

Aplikacja mapuje:
transition OP -> action_plan -> tool_plan.

Uwaga:
- tool_plan moze zawierac narzedzia CLI/service oraz operator-ui.
- klikniecie/akceptacja w UI to legalna tool invocation, a nie wyjatek od modelu.
- kazdy state-changing flow zaczyna sie od `policy-engine`.

## 4b. Uruchom AI jako job (DS-controlled)

Jesli tool_plan zawiera ai-runner:
- DS tworzy job,
- DS odpyta status (poll),
- DS decyduje o retry/cancel/timeout,
- DS moze zresetowac kontekst przez reset_ai_context,
- DS dopiero po walidacji akceptuje wynik joba.

MCP (jesli wystepuje) jest tylko adapterem transportowym.

## 5. Wykonaj akcje i review package

Po akcji przygotuj review package:
- diff
- mapowanie do scenariuszy/testow
- build/test/lint
- status OP po wykonaniu akcji

## 6. Gate decision record

Operator podejmuje decyzje gate:
- approve
- request_changes
- defer
- reject

Efekty decyzji sa zdefiniowane przez OP trigger rules.

## 7. Walidacja i audit

Obowiazkowo:
- QualityEvidenceRecord (pass/fail)
- ProcessEventRecord
- aktualizacja stanu OP
- zapis evidence class i provenance metadata
- ponowna walidacja invariantow po zmianie linkow lub parent/child scope

## 8. Petla

Jesli transition nie jest domkniety:
- wykonaj poprawki,
- odswiez stan OP,
- wyznacz nowe next_transition.

## 9. Delivery handoff

Gdy Feature OP osiagnie gotowosc release:
- przekaz do ReleaseBundle control,
- przejdz przez DeploymentRun/recovery controls wg guardow OP.
