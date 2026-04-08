## Daily workflow (OP-driven)

Zasada nadrzedna:
Operator nie wybiera "kroku pipeline" recznie.
Operator wybiera entrypoint OP, a system wyznacza next_transition z OP Layer.

Kanoniczna semantyka:
- layers/op/object-catalog.md
- layers/op/relation-contracts.md
- layers/op/recovery-contracts.md
- layers/op/scheduler-contracts.md
- layers/op/state-machines.md
- layers/op/trigger-rules.md

## 1. Wybierz entrypoint OP

Dopuszczalne entrypointy (zalezne od kontekstu):
- Project (nowy projekt / re-konfiguracja)
- Product baseline maintenance
- Repository/ChangeSet (VCS i scope zmiany)
- Idea (intake i scoping)
- Feature (spec/test/implement)
- VerificationPlan (polityka unit/integration/acceptance/e2e)
- UseCase/PortContract (granice i kontrakty aplikacyjne)
- Component / relation graph (reguly zaleznosci i spojnosci)
- DataSchema/Migration (ewolucja danych)
- Term/UIComponent (UX alignment)
- ActorRolePermission (authz i ownership)
- RuntimeEnvironment (gotowosc lane i deploymentu)
- Release (delivery)
- Exception / recovery controls / scheduler timer escalation (obsluga awarii)

## 2. Odczytaj stan instancji OP

Dla wybranego OP ustal:
- current_state
- legalne przejscia
- guardy blokujace
- pending PromptTask
- latest GateDecisionRecord
- parent linkage i impacted children
- evidence class ostatnich kluczowych dowodow

## 3. Wyznacz next_transition

Next transition wynika z OP state machine + guardow.
Playbook nie tworzy alternatywnej logiki przejsc.

## 4. Zbuduj projection dla operatora

Z OP -> UI/Prompt/Checklist:
- jaka jedna akcje pokazac (next best action)
- jaki minimalny kontekst zaladowac
- jaki prompt/job uruchomic
- jakie warunki gate musza byc spelnione
- jakie checki architektury sa wymagane (dependency direction, no-cycle, DTO boundary)
- jakie elementy sa widoczne tylko w audit/debug

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

## 9. Release handoff

Gdy Feature OP osiagnie gotowosc release:
- przekaz do Release OP,
- przejdz przez Deployment/Rollback wg guardow OP.
