## Iterative TDD Profile

Implementacja iteracyjna = scenario-by-scenario.

Zasada z lifecycle:
Implementuj kod dopiero po przygotowaniu scenariuszy i testów. Dla feature tworzących model domenowy preferuj test-by-test / scenario-by-scenario implementation.

Canonical prompt: `prompts/implementation-iterative.md`.

Flow:
- wybór scenariusza
- test failing
- minimalna implementacja
- refactor po scenariuszu
- walidacja
