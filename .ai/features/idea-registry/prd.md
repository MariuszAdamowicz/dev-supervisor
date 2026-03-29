# Feature: Idea Registry

## Goal
Provide a deterministic and project-scoped way to capture, organize and select ideas so the operator can move ideas into the feature specification flow without losing context or mixing work across projects.

## Inputs
- Operator action to create an idea for the active project.
- Idea payload provided by the operator (title + optional description/context).
- Operator action to update idea content.
- Operator action to change idea status.
- Operator request to list ideas for the active project.
- Operator action to select one idea as the next candidate for PRD generation.

## Outputs
- A persisted idea record with stable identity and explicit status.
- Project-scoped idea list visible to the operator.
- Deterministic operation results (explicit success or explicit failure reason).
- Explicit indicator of which idea is selected as the next PRD candidate.

## Rules
- Every idea must belong to exactly one project.
- Idea operations must be blocked or explicitly rejected when no active project is selected.
- Idea creation and updates must be operator-initiated; no implicit idea creation.
- An idea must have a non-empty title.
- Idea status must be explicit and limited to allowed states: `new`, `selected`, `deferred`, `done`.
- At most one idea per project can have status `selected` at a time.
- Selecting an idea for PRD candidate must be explicit and traceable.
- Listing ideas must return only ideas scoped to the active project.
- State changes must be explicit and traceable; silent failures are not allowed.
- Idea registry must support multiple ideas per project.

## Edge Cases
- Attempt to create an idea when no active project is selected.
- Attempt to create an idea with an empty title.
- Attempt to update or change status of a non-existent idea.
- Attempt to set `selected` on an idea when another idea in the same project is already `selected`.
- Attempt to access ideas from a different project context.
- Listing ideas when a project has no ideas.

## Non-Goals
- Auto-generating PRD from ideas without operator action.
- Executing prompts automatically against any AI provider.
- Cross-project idea deduplication or global idea search in this feature scope.
- Ranking/prioritization using AI scoring.
- Managing implementation artifacts beyond idea-level records.
