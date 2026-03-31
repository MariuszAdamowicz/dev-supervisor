## Traceability (OP-aligned)

Cel:
utrzymac lekka, praktyczna mapowalnosc miedzy wymaganiem, scenariuszem i testem,
bez budowy ciezkiego systemu.

## Minimalny kontrakt

Dla kazdej istotnej reguly:
- Requirement/Rule -> Scenario -> Test

W runtime mozna to zapisywac lekko (traceability.md), ale musi byc zgodne z OP:
- Scenario OP
- Feature OP
- ProcessEvent (audit zmian)

## Co jest wystarczajace

W feature/traceability.md trzymaj mapowanie:
- Rule/Requirement
- Scenario ID lub nazwa
- Test reference

## Dodatkowa zasada OP

Przy zmianie scenariuszy lub testow:
- zaktualizuj traceability.md,
- zapisz ProcessEvent,
- upewnij sie, ze GateDecision opiera sie na aktualnym mapowaniu.

## Przyklad

- Rule: fallback on provider error
  - Scenario: fallback to next provider
  - Test: ProviderRoutingTests/testFallbackOnError

- Rule: skip disabled provider
  - Scenario: disabled provider is ignored
  - Test: ProviderRoutingTests/testSkipDisabledProvider
