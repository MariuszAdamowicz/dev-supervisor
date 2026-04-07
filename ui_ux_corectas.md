# UI/UX Correctas

## Stan obecny przed zmianami

Przed korekta playbook mial dokumenty `experience/*`, ale nie wymuszal ich przez `runtime/playbook-exec.yaml` ani `validation/playbook-contracts.md`.
Skutki:
- mozna bylo zbudowac UI poprawne procesowo, ale slabego poziomu produktowego,
- `operator-ui` byl promptocentryczny zamiast task-first,
- audit/debug i operator UI mieszaly sie w jednym widoku,
- brakowalo twardego kontraktu dla empty/loading/success/error/blocked states.

## CRUD dla punktu

Create:
- `Term` istnial w runtime po `add_idea`,
- `UIComponent` i `UIScreen` istnialy w OP/bindings, ale nie byly twardo wymagane przez entrypointy UX.

Read:
- operator mogl czytac projection OP, ale bez rozdzialu operator/audit.

Update:
- mozna bylo aktualizowac artefakty UX i OP po srednio opisanych zasadach.

Remove:
- brak twardej polityki deprecacji/usuwania artefaktow UX.

## Praktyki zewnetrzne

- Apple HIG: task clarity, hierarchy, feedback.
- GOV.UK Design System: naprawialne i czytelne bledy formularzy.
- WCAG 2.2: labels, error identification, status messages.
- Material Design: jawne stany empty/error/loading.
- Nielsen Norman Group: visibility of system status, error prevention, progressive disclosure.

Linki:
- https://developer.apple.com/design/human-interface-guidelines/
- https://design-system.service.gov.uk/components/error-message/
- https://www.w3.org/WAI/WCAG22/Understanding/labels-or-instructions.html
- https://www.w3.org/WAI/WCAG22/Understanding/error-identification.html
- https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html
- https://m3.material.io/
- https://www.nngroup.com/articles/ten-usability-heuristics/

## Plan zmian

1. Dodac nadrzedny kontrakt operator UX.
2. Wymusic task-first fields w `operator-ui` request schema.
3. Rozdzielic operator UI od audit/debug UI.
4. Wymusic `.ai/ux/<entrypoint>.md` dla krytycznych entrypointow.
5. Dodac walidacje accessibility i state handling.

## Czy plan domyka problem

Tak dla poziomu playbooka. Plan nie gwarantuje jeszcze dobrego wykonania w aplikacji, ale zamyka glowna luke: nie da sie juz zgodnie z kontraktem pominac UX jako osobnej warstwy wykonawczej i walidacyjnej.

## Wprowadzone zmiany

- dodany `playbook/experience/operator-ux-contract.md`,
- rozszerzone `playbook/experience/screen-flow-contracts.md`,
- rozszerzone `playbook/experience/ux-validation.md`,
- poprawione `playbook/experience/operator-journey.md`,
- poprawione `playbook/experience/interaction-patterns.md`,
- `playbook/runtime/playbook-exec.yaml` wymaga task-first fields i artefaktow UX,
- `playbook/validation/playbook-contracts.md` wymaga UX contract i state handling.

## Podsumowanie

Brakujacy UX zostal przeniesiony z warstwy "nice to have" do twardego kontraktu. Najwieksza zmiana polega na tym, ze operator nie jest juz domyslnie obslugiwany przez prompt dump, tylko przez jawny model celu, kroku i stanu interfejsu.
