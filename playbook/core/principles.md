## Principles (OP-aligned)

## Cel systemu

Zbudowac workflow, w ktorym:
- AI implementuje kod,
- dokumentacja steruje AI,
- kontekst jest minimalny,
- zmiany sa prowadzone przez specyfikacje i testy,
- proces jest deterministyczny i audytowalny.

## Product guardrails

- dev-supervisor jest deterministic supervisor, nie agent AI.
- Proces jest operator-driven.
- System jest local-first, tool-agnostic, provider-agnostic.
- System nie wykonuje promptow automatycznie poza jawnym planem DS.
- System nie zastepuje osadu inzynierskiego.

## Kontrakt warstw

- OP Layer definiuje semantyke procesu.
- Playbook Layer mapuje procedure operatora na OP.
- Project Instance Layer wykonuje proces dla konkretnego projektu.

Dokumenty kanoniczne OP:
- layers/op/object-catalog.md
- layers/op/state-machines.md
- layers/op/trigger-rules.md

## Zasady operacyjne

1. Nie duplikuj semantyki state/trigger/gate poza OP Layer.
2. Dla zachowania implementacji: PRD < BDD < TESTY.
3. AI dostaje minimalny potrzebny kontekst.
4. Kazda iteracja konczy sie build + test + lint.
5. Kazda decyzja gate musi byc jawna i audytowalna.
6. Kod wspoldzielony jest zarzadzany jawnie (bez przypadkowego copy-paste).
7. Feature konczy sie dopiero po stabilizacji i gotowosci do release handoff.
8. Kazda zmiana stanu OP musi przejsc przez legalny binding: transition -> action_plan -> tool_plan.
9. Akcja operatora w UI jest narzedziem operator-ui i podlega tym samym zasadom audytu co CLI/service.
10. Agent AI jest narzedziem ai-runner sterowanym przez DS; DS kontroluje start, timeout, retry, cancel i reset kontekstu.
11. MCP jest opcjonalnym adapterem transportowym; nie jest zrodlem gwarancji wykonania procesu.

## Zasady negatywne

Nie rob:
- implementacji bez testow,
- zmian zaczynanych od kodu,
- merge bez walidacji,
- cichych zmian stanu procesu bez decyzji operatora,
- zmian stanu wykonywanych poza zadeklarowanym bindingiem tooling,
- opierania krytycznych krokow na domyslnej petli czarnej skrzynki agenta.
