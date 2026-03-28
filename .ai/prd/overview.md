# Product Overview

## Summary

Dev Supervisor is a local desktop application that supervises and structures AI-assisted software development workflows.

It does not act as an AI agent itself.
Instead, it acts as a deterministic control layer that:
- manages project structure
- enforces development process
- generates structured prompts
- tracks feature lifecycle
- maintains traceability between specifications, tests and implementation

The application is designed to reduce chaos, context drift and inconsistency when using AI for software development.

---

## Core Goals

- Provide a structured, repeatable workflow for AI-assisted development
- Enforce separation between idea, specification, tests and implementation
- Maintain clear traceability between:
  - PRD
  - BDD scenarios
  - tests
  - implementation
- Generate context-aware prompts for development steps
- Track feature lifecycle and progress
- Reduce cognitive load on the operator
- Prevent context explosion and inconsistency in AI usage

---

## Key Capabilities

### 1. Project Initialization
- create project structure
- generate `.ai` scaffolding
- initialize scripts and workflow

### 2. Idea & Feature Management
- store ideas
- convert ideas into features
- manage feature lifecycle

### 3. Specification Management
- manage PRD per feature
- manage BDD scenarios
- maintain traceability between rules and scenarios

### 4. Prompt Generation
- generate structured prompts for:
  - planning
  - test generation
  - implementation
  - debugging
  - refactoring
- keep prompt templates external to project when needed

### 5. Validation Tracking
- track build/test/lint results
- ensure each step is validated

### 6. Progress Visibility
- show feature status
- show specification completeness
- show validation status
- optionally show coverage-like metrics (based on scenarios/tests)

---

## Non-Goals (v1)

- direct execution of AI prompts
- full IDE replacement
- cloud synchronization
- multi-user collaboration
- complex plugin ecosystem
- deep code analysis beyond process-level tracking

---

## Design Principles

### Deterministic Control
The application must remain predictable and deterministic.
It supervises the process, not replaces decision-making.

### Tool-Agnostic
The system must not depend on any specific AI provider, CLI tool, or programming language.

### Minimal Context
The system should always promote minimal, focused context for AI interactions.

### Specification-Driven Development
All development should be driven by:
PRD → BDD → tests → implementation

### Traceability First
Every important rule should be traceable to:
- a scenario
- a test

### Incremental Workflow
Work should be performed in small, controlled steps.

---

## Target Users

- solo developers using AI-assisted workflows
- engineers building local-first tools
- developers who want strict control over AI-driven code generation

---

## Boundaries

The application:
- manages process and structure
- generates prompts
- tracks state

The application does NOT:
- own the code execution environment
- replace developer judgment
- enforce a specific technology stack

---

## Success Criteria

The system is successful if:
- features are implemented with minimal rework
- AI interactions remain predictable
- context size stays small
- feature changes do not create inconsistencies
- the operator can clearly see the state of the project at any time

