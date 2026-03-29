# Modular Playbook System

Ten playbook jest podzielony na moduły, aby utrzymać minimalny kontekst, spójne źródła prawdy i przewidywalny workflow AI-driven development.

Source artifact:
- `operacyjny_playbook_v8.md` (monolit referencyjny)

## Product Direction Guardrails

- `dev-supervisor` jest deterministic supervisor, nie agent AI.
- Proces jest operator-driven: człowiek uruchamia prompty w zewnętrznym narzędziu.
- System pozostaje local-first.
- System pozostaje tool-agnostic i provider-agnostic.
- Tożsamość produktu jest stack-agnostic in principle; stack profile to konfiguracja, nie definicja produktu.

## Warstwy

### core
Reguły globalne i niezmienne fundamenty procesu:
- zasady operacyjne
- source of truth
- lifecycle feature
- rewrite protocol
- traceability
- validation
- git workflow

### workflow
Procedury wykonywania pracy:
- setup projektu
- codzienny loop
- zamykanie sesji
- checklisty

### profiles
Nakładki konfiguracyjne dla konkretnego kontekstu:
- stack (np. macos-swiftui)
- architecture (np. modular-monolith)
- language (pl/en)
- execution style (iterative, batch, hybrid)

### prompts
Kanoniczne prompty robocze per etap.

### templates
Gotowe wzorce plików AI i skryptów.

Zasada separacji:
- `core` i `workflow` nie kodują szczegółów konkretnej platformy.
- Szczegóły platformowe trafiają do `profiles/stack/*`.

## Example Configuration

- stack: `macos-swiftui`
- architecture: `modular-monolith`
- language: `pl`
- execution-style: `iterative-tdd`

## How To Use

Moduły obowiązkowe:
- `core/*`
- `workflow/*`
- jeden profil `stack/*`
- jeden profil `architecture/*`
- jeden profil `language/*`
- jeden profil `execution-style/*`

Moduły kontekstowe:
- `prompts/*` używane zależnie od etapu pracy
- `templates/*` używane przy inicjalizacji lub odtwarzaniu artefaktów

Sposób kompozycji:
1. Start od `core/` jako zasad nadrzędnych.
2. Wybierz i dołącz profile (`stack`, `architecture`, `language`, `execution-style`).
3. Realizuj pracę przez `workflow/daily-workflow.md`.
4. Używaj promptów kanonicznych z `prompts/`.
5. Zamykaj iteracje checklistami i `workflow/session-closure.md`.
