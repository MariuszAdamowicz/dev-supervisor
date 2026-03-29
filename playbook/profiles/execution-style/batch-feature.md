## Batch Feature Profile

Batch implementation = realizacja feature krokami na bazie planu, bez przełączania kontekstu na wiele feature jednocześnie.

Canonical prompts:
- `prompts/implementation-batch.md`
- `prompts/cleanup.md`

Flow:
- przygotuj plan
- implementuj step X
- wykonaj build/test/lint
- napraw błędy
- stabilizuj feature
