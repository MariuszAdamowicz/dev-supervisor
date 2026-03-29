# Traceability

- Rule: A project must have a non-empty name and a non-empty local path/reference.
  - Covered by: Scenario 3 "Reject registration with missing required fields"

- Rule: Each project must be uniquely identifiable in the registry.
  - Covered by: Scenario 1 "Register a valid project"
  - Covered by: Scenario 2 "Register multiple projects concurrently"

- Rule: Two active project records must not point to the same local path/reference.
  - Covered by: Scenario 4 "Reject duplicate active path/reference"
  - Covered by: Scenario 20 "Reject update that introduces duplicate active path/reference"
  - Covered by: Scenario 23 "Reject reactivation when local path/reference conflicts with another active project"

- Rule: Project registration and updates must be operator-initiated; no implicit project creation.
  - Covered by: Scenario 1 "Register a valid project"
  - Covered by: Scenario 5 "Update project metadata by explicit operator action"
  - Covered by: Scenario 15 "List behavior when no projects exist"

- Rule: Project data must remain isolated from other projects' ideas, features, progress and metadata.
  - Covered by: Scenario 14 "Project isolation across supervised data"

- Rule: Archive/reactivate operations must preserve project history and identity.
  - Covered by: Scenario 7 "Archive project preserves identity and history"
  - Covered by: Scenario 8 "Reactivate archived project preserves identity and history"

- Rule: The registry must support multiple projects concurrently.
  - Covered by: Scenario 2 "Register multiple projects concurrently"
  - Covered by: Scenario 22 "List includes active and archived projects together"

- Rule: State changes must be explicit and traceable; silent failures are not allowed.
  - Covered by: Scenario 3 "Reject registration with missing required fields"
  - Covered by: Scenario 4 "Reject duplicate active path/reference"
  - Covered by: Scenario 6 "Reject update for non-existent project"
  - Covered by: Scenario 9 "Reject archive of an already archived project"
  - Covered by: Scenario 10 "Reject reactivation of an already active project"
  - Covered by: Scenario 16 "Reject archive for non-existent project"
  - Covered by: Scenario 17 "Explicit failure when registered path/reference is unavailable"
  - Covered by: Scenario 18 "Reject selection of non-existent project"
  - Covered by: Scenario 19 "Reject selection of archived project"
  - Covered by: Scenario 20 "Reject update that introduces duplicate active path/reference"
  - Covered by: Scenario 23 "Reject reactivation when local path/reference conflicts with another active project"

- Rule: Exactly one project can be selected as the active working project at a time.
  - Covered by: Scenario 11 "Select one active working project explicitly"
  - Covered by: Scenario 12 "Replace active working project selection"

- Rule: The active project must be explicitly set by the operator.
  - Covered by: Scenario 11 "Select one active working project explicitly"
  - Covered by: Scenario 12 "Replace active working project selection"

- Rule: If no project is selected, feature-level operations must be blocked or return explicit error.
  - Covered by: Scenario 13 "Block feature-level operations when no project is selected"
