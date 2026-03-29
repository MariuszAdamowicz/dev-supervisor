## 🧱 Struktura projektu

```text
my-app/
├── App/                  # warstwa UI (framework wg stack profile)
├── Core/
│   ├── Domain/           # modele domenowe
│   ├── Shared/           # współdzielone helpery i utilities
│   ├── Providers/        # abstrakcje providerów i adaptery
│   ├── Routing/          # wybór providera, fallback, polityki routingu
│   └── Persistence/      # lokalna persystencja (SQLite / Core Data / pliki)
├── Services/             # integracje zewnętrzne i klienty API
├── Integrations/         # opcjonalne moduły specyficzne dla stacka
├── Tests/                # XCTest / testy integracyjne
├── Scripts/
│   ├── build.sh
│   ├── test.sh
│   └── lint.sh
├── .ai/                  # specyfikacja, zasady i materiały sterujące AI
└── pliki narzędziowe wg stack profile
```

Szczegóły layoutu modułów: `profiles/architecture/modular-monolith.md`.
Szczegóły narzędziowe i platformowe: `profiles/stack/macos-swiftui.md`.

## 🧠 Zasady nazewnictwa

Feature:
- kebab-case
- opisowe nazwy

Branch:
- feat/<feature>

Folder feature:
- identyczny jak branch

Zasada:
Jedna nazwa = jeden feature = jeden branch

---

## 🧠 Struktura `.ai/`

```text
.ai/
├── ideas.md
├── prd/
│   ├── overview.md
│   ├── constraints.md
│   └── glossary.md
├── stack/
│   ├── architecture.md
│   ├── shared-code.md
│   ├── core.md
│   ├── ui.md
│   ├── api.md
│   └── rules.md
├── features/
│   └── <feature>/
│       ├── prd.md
│       ├── bdd.md
│       ├── tasks.md
│       ├── notes.md
│       └── traceability.md
├── prompts/
└── agent.md
```

## 📄 Co powinno zawierać każde miejsce w `.ai/`

### `.ai/ideas.md`
Luźny backlog pomysłów.  
To nie jest PRD.  
To nie jest zobowiązanie do implementacji.

**Przykład:**
```markdown
- dodać fallback między providerami
- dodać cache odpowiedzi
- dodać statystyki procentowe token usage
```

### `.ai/prd/overview.md`
Opis produktu jako całości:
- czym jest system
- jaki problem rozwiązuje
- jakie ma granice
- jakie są główne capability

Przykład: `templates/ai/overview.md`

### `.ai/prd/constraints.md`
Ograniczenia techniczne i produktowe, których AI ma nie łamać.

Przykład: `templates/ai/constraints.md`

### `.ai/prd/glossary.md`
Słownik pojęć używanych w projekcie:
- provider
- fallback
- quota
- token usage
- route
- active provider

Dzięki temu AI nie zmienia znaczenia terminów.

### `.ai/stack/architecture.md`
Opis architektury projektu:
- jakie są główne moduły
- co trafia do `App/`, `Core/`, `Services/`, `Tests/`
- kiedy tworzyć nowy moduł, a kiedy używać istniejącego
- jak unikać rozlewania odpowiedzialności między feature'ami

### `.ai/stack/shared-code.md`
Zasady dotyczące kodu współużytkowanego:
- gdzie trafiają helpery
- gdzie trafiają modele współdzielone
- kiedy należy zrobić extraction do `Core/Shared` lub `Core/Domain`
- kiedy duplikacja jest sygnałem do refaktoru

### `.ai/stack/core.md`
Zasady dotyczące logiki:
- moduły
- podział odpowiedzialności
- styl implementacji

### `.ai/stack/ui.md`
Zasady dla warstwy UI:
- View / ViewModel
- stan
- nawigacja
- komponenty UI

Szczegóły frameworka UI: stack profile.

### `.ai/stack/api.md`
Zasady dla lokalnego API:
- routing
- DTO
- błędy
- kompatybilność endpointów

### `.ai/stack/rules.md`
Twarde reguły kodu i pracy AI.

**Przykład:**
```markdown
- No force unwrap
- No global mutable state
- Functions < 50 lines when practical
- Prefer value types
- Prefer explicit domain types over raw dictionaries
- Do not modify unrelated files
```

### `.ai/features/<feature>/prd.md`
Oficjalna specyfikacja jednego feature.

Przykład: `templates/ai/feature-prd-example.md`

### `.ai/features/<feature>/bdd.md`
Scenariusze BDD, które opisują zachowanie feature i są podstawą do wygenerowania testów.

Przykład: `templates/ai/bdd-example.md`

### `.ai/features/<feature>/tasks.md`
Mała lista kroków implementacyjnych.

**Przykład:**
```markdown
- add routing policy type
- implement provider selection
- handle quota error fallback
- expose routing metadata to stats module
```

### `.ai/features/<feature>/notes.md`
Lokalne notatki projektowe:
- decyzje
- edge case'y
- znane ryzyka
- krótkie wnioski po implementacji

### `.ai/features/<feature>/traceability.md`
Lekki plik wiążący specyfikację z testami.

Przykład: `templates/ai/traceability-example.md`

### `.ai/prompts/`
Gotowe prompty:
- plan
- implementacja
- refactor
- debug
- cleanup
- test generation

### `.ai/agent.md`
Krótka instrukcja dla AI, jak ma pracować w tym repo.

**Przykład:**
```markdown
- Read only the minimal context needed
- Follow .ai/stack/rules.md strictly
- Implement incrementally
- Update only the active feature files unless asked otherwise
- Keep tests aligned with BDD scenarios
```

---

## 1. Setup
- utwórz repo
- utwórz .gitignore
- utwórz `.ai/`
- skonfiguruj build, test, lint
- skonfiguruj Git workflow (branching + PR)
- skonfiguruj zasady dla shared code (`.ai/stack/shared-code.md`)

See stack profile for platform-specific setup.

---

## 🧠 Polityka aktualizacji dokumentacji

Zawsze aktualizuj:
- feature/prd.md
- feature/bdd.md
- testy
- traceability.md

Aktualizuj warunkowo:
- architecture.md
- shared-code.md
- playbook / setup rules, jeśli praktyka ujawniła nowe wymagania operacyjne
- glossary.md

Nie aktualizuj automatycznie:
- overview.md
- constraints.md

Zasada:
Dokumentacja zmienia się tylko wtedy, gdy zmienia się zachowanie systemu.

---

## 2. Feature loop
- wybór pomysłu
- utworzenie feature capsule
- utworzenie branchu `feat/<feature>`
- przygotowanie PRD + BDD + wstępnych testów
- wygenerowanie planu
- testy
- implementacja
- cleanup
- stabilizacja

## 3. Stabilizacja
- porządkowanie modułów
- poprawa nazw
- upraszczanie kodu
- usuwanie martwego kodu
- aktualizacja lokalnej specyfikacji feature
- review duplikacji i ewentualny extraction do `Core/Shared` / `Core/Domain`
- merge do `main` i usunięcie brancha feature

## 4. Rozwój
- kolejne feature
- refactor
- rozszerzanie testów
- doprecyzowywanie constraints i rules
- aktualizacja `architecture.md` i `shared-code.md`, jeśli zmienił się sposób organizacji kodu
