# Glossary

## Project

A supervised software project managed by Dev Supervisor.

A project consists of:
- ideas
- features
- specifications (PRD, BDD)
- validation state
- progress tracking

A project is typically mapped to a local repository but is not limited to it.

---

## Idea

A raw, unstructured concept or potential feature.

Characteristics:
- not yet specified
- not committed to implementation
- stored in ideas.md
- can be promoted to a feature

---

## Feature

A defined unit of functionality with a clear responsibility.

Characteristics:
- has its own specification (PRD)
- has defined behavior (BDD)
- has associated tests
- follows a lifecycle from idea to implementation

---

## PRD (Product Requirements Document)

A structured description of what a feature or system must do.

Contains:
- goal
- inputs
- outputs
- rules
- constraints
- edge cases

PRD defines the contract but does not enforce behavior.

---

## BDD (Behavior Driven Development)

A set of scenarios describing how the system should behave.

Characteristics:
- written as scenarios
- covers happy path, edge cases and failures
- used as a base for test generation

BDD defines expected behavior.

---

## Test

Executable verification of system behavior.

Characteristics:
- derived from BDD scenarios
- enforce correctness
- prevent regressions

Tests are the final source of truth for behavior.

---

## Traceability

The relationship between:
- PRD rules
- BDD scenarios
- tests

Purpose:
- ensure coverage
- detect gaps
- maintain consistency

---

## Prompt

A structured instruction used to guide AI-assisted development.

Types:
- planning
- PRD generation
- BDD generation
- test generation
- implementation
- debugging
- refactoring

Prompts are deterministic and context-aware.

---

## Prompt Template

A reusable structure for generating prompts.

Stored outside or alongside project files.

---

## Validation

The process of verifying system correctness using:
- build
- tests
- lint

Validation determines readiness of a feature or project.

---

## Feature Lifecycle

The sequence of steps a feature follows:

idea → PRD → BDD → tests → implementation → validation → stabilization

---

## Stabilization

The process of:
- cleaning up code
- removing dead logic
- aligning implementation with specification
- updating documentation

---

## Operator

The human user of Dev Supervisor.

Responsibilities:
- making decisions
- executing prompts
- supervising the workflow

---

## Supervisor

Dev Supervisor itself.

Responsibilities:
- structuring the process
- generating prompts
- tracking state
- maintaining traceability

Does NOT:
- execute code
- replace developer judgment

---

## Context

The set of information provided to AI at a given step.

Principles:
- minimal
- relevant
- feature-scoped

---

## Shared Code

Code reused across multiple features.

Located in:
- Core/Domain
- Core/Shared
- Core/Providers
- Core/Routing

---

## Extraction

The process of moving duplicated or reusable logic into shared modules.

Triggered when:
- similar logic appears more than once

