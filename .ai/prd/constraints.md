# Constraints

## Platform

- macOS only (initial phase)
- Desktop application (window-based UI)
- No web UI
- No Electron
- No browser-based primary interface

---

## Language and Framework

- Swift as primary language
- SwiftUI for UI layer
- Native Apple frameworks preferred

---

## Architecture

- Prefer simple modular monolith in initial phase
- Clear separation between:
  - UI (App/)
  - Domain logic (Core/)
  - Integrations (Services/)
- Avoid over-engineering (no microservices, no distributed systems)

---

## Tool Agnosticism

- The system must not depend on any specific:
  - AI provider
  - CLI tool
  - programming language used in supervised projects

- The application supervises process, not execution engine

---

## AI Interaction Model

- The application must NOT automatically execute prompts
- Prompts are generated and presented to the operator
- The operator is responsible for execution

---

## Storage

- Local database is required
- No cloud dependency in initial phase
- Database stores:
  - project metadata
  - feature state
  - progress tracking
  - traceability references

- Project files remain the source of truth for:
  - PRD
  - BDD
  - feature specifications

---

## Project Scope

- Support multiple projects
- Each project is isolated in terms of:
  - ideas
  - features
  - progress
  - metadata

---

## Validation

- Every feature must be verifiable through:
  - build
  - tests
  - lint

- The system must track validation state but does not execute it automatically

---

## Prompt System

- Prompt templates may be stored outside project files
- Prompts must be:
  - deterministic
  - structured
  - minimal in context

---

## Quality Rules

- No silent failures
- No hidden state changes
- No implicit behavior without traceability

- Prefer explicit models over dynamic structures
- Prefer clarity over cleverness

---

## Evolution Constraints

- New capabilities must not break:
  - existing feature workflows
  - traceability model
  - minimal context principle

- Changes to workflow must be reflected in:
  - PRD
  - BDD
  - tests