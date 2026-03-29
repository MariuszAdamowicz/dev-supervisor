# Feature: Project Registry

## Goal
Provide a deterministic way to register, view and manage supervised projects so each project has explicit identity, isolation and lifecycle visibility within Dev Supervisor.

## Inputs
- Operator action to create a project record.
- Project metadata provided by the operator (project name and local path/reference).
- Operator action to update project metadata.
- Operator action to archive or reactivate a project.
- Operator request to list projects.
- Operator action to select an active project.

## Outputs
- A persisted project record with stable identity and explicit metadata.
- A project list visible to the operator.
- Project status visibility (active or archived).
- Deterministic feedback for each operation (success or explicit failure reason).
- Information about the currently active project.

## Rules
- A project must have a non-empty name and a non-empty local path/reference.
- Each project must be uniquely identifiable in the registry.
- Two active project records must not point to the same local path/reference.
- Project registration and updates must be operator-initiated; no implicit project creation.
- Project data must remain isolated from other projects' ideas, features, progress and metadata.
- Archive/reactivate operations must preserve project history and identity.
- The registry must support multiple projects concurrently.
- State changes must be explicit and traceable; silent failures are not allowed.
- Exactly one project can be selected as the active working project at a time.
- The active project must be explicitly set by the operator.
- If no project is selected, feature-level operations must be blocked or return explicit error.

## Edge Cases
- Attempt to register a project with missing required fields.
- Attempt to register a project whose local path/reference is already used by another active project.
- Attempt to archive an already archived project.
- Attempt to reactivate an already active project.
- Attempt to update or archive a non-existent project.
- Project local path/reference becomes unavailable after registration.
- No projects exist in the registry.

## Non-Goals
- Executing project build, test, lint or prompts.
- Auto-discovering projects without operator action.
- Managing implementation artifacts (PRD/BDD/tests/code) beyond registry references.
- Cross-project merging, synchronization or shared mutable state.
- Cloud-based project registry or remote collaboration behavior.
