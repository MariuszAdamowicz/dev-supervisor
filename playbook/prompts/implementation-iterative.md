### Implementacja iteracyjna (scenario-by-scenario TDD)
```text
Read:
- .ai/features/<feature>/prd.md
- .ai/features/<feature>/bdd.md
- relevant tests
- .ai/stack/rules.md

Task:
Implement only the minimal production code needed to make the selected scenario(s) pass.

Instructions:
1. Focus only on the selected scenario(s), not the whole feature.
2. Use tests as the primary source of truth for behavior.
3. Extract domain types to production code if tests introduced temporary placeholders.
4. Do not add database, networking, UI or unrelated abstractions.
5. Keep the implementation in-memory and minimal unless the feature explicitly requires more.
6. Do not weaken tests.

At the end, print:
- which scenario(s) were implemented
- which files were created or modified
- which domain types were extracted
- what should be refactored before the next scenario
```
