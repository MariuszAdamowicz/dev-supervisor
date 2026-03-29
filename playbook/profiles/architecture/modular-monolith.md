## Modular Monolith

```text
my-app/
├── App/                  # SwiftUI (UI)
├── Core/
│   ├── Domain/           # modele domenowe
│   ├── Shared/           # współdzielone helpery i utilities
│   ├── Providers/        # abstrakcje providerów i adaptery
│   ├── Routing/          # wybór providera, fallback, polityki routingu
│   └── Persistence/      # lokalna persystencja (SQLite / Core Data / pliki)
├── Services/             # integracje zewnętrzne i klienty API
├── XPCService/           # opcjonalnie: helper / proces wydzielony
├── Tests/                # XCTest / testy integracyjne
```

### Architecture

#### App
Contains SwiftUI views, view models and app lifecycle glue.

#### Core
Contains domain logic and reusable modules.

#### Services
Contains integrations with external APIs.

#### Rule
If logic is reused by more than one feature, it should not stay inside a feature-specific implementation.

### Shared Code Rules

#### Domain
Shared business types and DTOs.

#### Shared
Reusable helpers and common validation logic.

#### Extraction Rule
When the second similar implementation appears, propose extraction.

### Domain Types Rule
- Domain types must not remain inside test files.
- Tests may introduce temporary placeholder types only to express behavior.
- Before or during implementation, all domain types must be extracted to Core/Domain.
- Production code must be the single source of truth for domain models.
- Tests must depend on domain types, not define them.

### Test Boundary Rule
- Tests define behavior, not architecture.
- Tests may define minimal contracts to express expectations.
- Final architecture must be derived during implementation, not fixed prematurely in tests.
