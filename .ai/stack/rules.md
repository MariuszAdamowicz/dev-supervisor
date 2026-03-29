- No force unwrap
- No global mutable state
- Functions < 50 lines when practical
- Prefer value types
- Prefer explicit domain types over raw dictionaries
- Do not modify unrelated files

## Domain Types Rule

- Domain types must not remain inside test files.
- Tests may introduce temporary placeholder types only to express behavior.
- Before or during implementation, all domain types must be extracted to Core/Domain.
- Production code must be the single source of truth for domain models.
- Tests must depend on domain types, not define them.

## Test Boundary Rule

- Tests define behavior, not architecture.
- Tests may define minimal contracts to express expectations.
- Final architecture must be derived during implementation, not fixed prematurely in tests.
