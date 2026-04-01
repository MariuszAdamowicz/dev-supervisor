## Daily workflow (OP-driven)

Zasada nadrzedna:
Operator nie wybiera "kroku pipeline" recznie.
Operator wybiera entrypoint OP, a system wyznacza next_transition z OP Layer.

Kanoniczna semantyka:
- layers/op/object-catalog.md
- layers/op/state-machines.md
- layers/op/trigger-rules.md

## 1. Wybierz entrypoint OP

Dopuszczalne entrypointy (zalezne od kontekstu):
- Project (nowy projekt / re-konfiguracja)
- Idea (intake i scoping)
- Feature (spec/test/implement)
- Term/UIComponent (UX alignment)
- Release (delivery)
- Exception/Timeout (obsluga awarii)

## 2. Odczytaj stan instancji OP

Dla wybranego OP ustal:
- current_state
- legalne przejscia
- guardy blokujace
- pending PromptTask
- latest GateDecision

## 3. Wyznacz next_transition

Next transition wynika z OP state machine + guardow.
Playbook nie tworzy alternatywnej logiki przejsc.

## 4. Zbuduj projection dla operatora

Z OP -> UI/Prompt/Checklist:
- jaka jedna akcje pokazac (next best action)
- jaki minimalny kontekst zaladowac
- jaki prompt/job uruchomic
- jakie warunki gate musza byc spelnione

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

## 6. GateDecision

Operator podejmuje decyzje gate:
- approve
- request_changes
- defer
- reject

Efekty decyzji sa zdefiniowane przez OP trigger rules.

## 7. Walidacja i audit

Obowiazkowo:
- QualitySignal (pass/fail)
- ProcessEvent
- aktualizacja stanu OP

## 8. Petla

Jesli transition nie jest domkniety:
- wykonaj poprawki,
- odswiez stan OP,
- wyznacz nowe next_transition.

## 9. Release handoff

Gdy Feature OP osiagnie gotowosc release:
- przekaz do Release OP,
- przejdz przez Deployment/Rollback wg guardow OP.
