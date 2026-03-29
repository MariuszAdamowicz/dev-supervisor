# Product Overview

## Summary

Dev Supervisor is a local desktop application that supervises and structures AI-assisted software development workflows across multiple projects.

It is not an AI agent.
It is a deterministic process supervisor that helps the operator manage:
- project setup
- ideas
- features
- specifications
- tests
- prompts
- validation
- progress tracking

The application is intended to reduce chaos, context drift and inconsistency in AI-assisted development.

---

## Core Goals

- Provide a structured and repeatable workflow for AI-assisted software development
- Supervise multiple projects from one local application
- Enforce separation between:
  - ideas
  - specifications
  - BDD scenarios
  - tests
  - implementation
- Maintain traceability between requirements, scenarios, tests and implementation
- Generate structured prompts for different stages of work
- Track validation state and progress across projects and features
- Reduce cognitive load on the operator

---

## Key Capabilities

### 1. Project Management
- create and initialize projects
- manage project structure
- track project status
- support multiple projects

### 2. Idea Management
- store ideas per project
- move ideas into feature definition flow
- keep ideas separate from implementation

### 3. Feature Management
- create and manage feature lifecycle
- track feature status
- connect features with specifications and validation

### 4. Specification Management
- manage feature PRD
- manage BDD scenarios
- maintain traceability between rules and scenarios

### 5. Prompt Generation
- generate prompts for:
  - planning
  - PRD creation
  - BDD creation
  - test generation
  - implementation
  - debugging
  - refactoring
- allow prompt templates to live outside project files

### 6. Validation Tracking
- record build/test/lint status
- show whether a feature is ready to move forward
- support session-to-session continuity

### 7. Progress Visibility
- show feature lifecycle state
- show project-level progress
- show specification completeness
- show validation readiness
- optionally derive progress metrics from scenario/test state

### 8. Traceability Support
- connect PRD rules to BDD scenarios
- connect scenarios to tests
- make gaps visible

---

## Non-Goals (initial phase)

- direct execution of prompts through an AI provider
- full IDE replacement
- cloud-first architecture
- collaborative real-time editing
- deep semantic code analysis
- automatic code modification without operator control

---

## Design Principles

### Deterministic Control
The application must remain deterministic and operator-driven.

### Tool Agnostic
The system must support different development stacks, different prompt strategies and different AI providers without hard coupling to any specific one.

### Local First
The application should work as a local desktop supervisor with local state and local persistence.

### Specification Driven Development
The preferred workflow is:
idea → PRD → BDD → tests → implementation → validation

### Traceability First
Important rules should remain traceable across:
- PRD
- BDD
- tests

### Incremental Workflow
The application should guide work in small, controlled steps rather than large ambiguous jumps.

---

## Storage Model

The application uses a local database to maintain process state, operational metadata and project supervision data.

The database is not intended to replace project files as the source of truth for specifications.
Instead:
- project files remain the source of truth for project artifacts
- the local database stores operational state, references and supervision metadata

---

## Target Users

- solo developers using AI-assisted workflows
- engineers managing multiple local projects
- developers who want strict process control when working with AI

---

## Product Boundaries

The application:
- supervises process
- tracks state
- generates prompts
- maintains references
- helps the operator stay in control

The application does not:
- replace engineering judgment
- own the execution environment of code
- force a single AI provider or stack
- become the implementation engine itself

---

## Success Criteria

The system is successful if:
- projects can be initialized consistently
- feature work follows a repeatable flow
- prompt generation reduces operator effort
- validation state is visible at all times
- traceability gaps are easy to detect
- multiple projects can be supervised without confusion
