## Iterative TDD Profile

Implementacja iteracyjna = scenario-by-scenario.

Zasada z lifecycle:
Implementuj kod dopiero po przygotowaniu scenariuszy i testów. Dla feature tworzących model domenowy preferuj test-by-test / scenario-by-scenario implementation.

Canonical prompt: `prompts/implementation-iterative.md`.

Flow:
- wybór scenariusza
- potwierdzenie VerificationPolicy dla scope
- test failing
- minimalna implementacja
- refactor po scenariuszu
- aktualizacja ChangeSet i traceability
- walidacja
