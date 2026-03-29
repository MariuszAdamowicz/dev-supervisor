# Feature: Project Registry

## Scenario 1: Register a valid project
Given the registry is empty
When the operator registers a project with name "Alpha" and local path/reference "/projects/alpha"
Then a new project record is created with stable identity
And the project is visible in the project list as active
And the operation result is explicit success

## Scenario 2: Register multiple projects concurrently
Given a project "Alpha" exists with local path/reference "/projects/alpha"
When the operator registers a second project with name "Beta" and local path/reference "/projects/beta"
Then both projects exist in the registry at the same time
And each project remains uniquely identifiable
And the operation result is explicit success

## Scenario 3: Reject registration with missing required fields
Given the registry is empty
When the operator registers a project with an empty name or empty local path/reference
Then no project is created
And the operation result is explicit failure with reason

## Scenario 4: Reject duplicate active path/reference
Given an active project "Alpha" exists with local path/reference "/projects/alpha"
When the operator registers another active project with local path/reference "/projects/alpha"
Then the second project is not created
And the operation result is explicit failure with reason

## Scenario 5: Update project metadata by explicit operator action
Given a project "Alpha" exists with local path/reference "/projects/alpha"
When the operator updates the project name to "Alpha Renamed"
Then the same project identity is preserved
And the updated metadata is visible in the registry
And the operation result is explicit success

## Scenario 6: Reject update for non-existent project
Given the registry contains no project with identity "P-404"
When the operator requests metadata update for project "P-404"
Then no project state changes
And the operation result is explicit failure with reason

## Scenario 7: Archive project preserves identity and history
Given an active project "Alpha" exists
When the operator archives project "Alpha"
Then the project status becomes archived
And the project identity is unchanged
And project history remains preserved
And the operation result is explicit success

## Scenario 8: Reactivate archived project preserves identity and history
Given an archived project "Alpha" exists
When the operator reactivates project "Alpha"
Then the project status becomes active
And the project identity is unchanged
And project history remains preserved
And the operation result is explicit success

## Scenario 9: Reject archive of an already archived project
Given project "Alpha" is archived
When the operator archives project "Alpha" again
Then no project state changes
And the operation result is explicit failure with reason

## Scenario 10: Reject reactivation of an already active project
Given project "Beta" is active
When the operator reactivates project "Beta" again
Then no project state changes
And the operation result is explicit failure with reason

## Scenario 11: Select one active working project explicitly
Given active projects "Alpha" and "Beta" exist
And no active working project is selected
When the operator selects "Alpha" as the active working project
Then "Alpha" is the only active working project
And active working project information is visible
And the operation result is explicit success

## Scenario 12: Replace active working project selection
Given active projects "Alpha" and "Beta" exist
And "Alpha" is selected as the active working project
When the operator selects "Beta" as the active working project
Then "Beta" is the only active working project
And "Alpha" is no longer selected as the active working project
And the operation result is explicit success

## Scenario 13: Block feature-level operations when no project is selected
Given active projects exist
And no active working project is selected
When a feature-level operation is requested
Then the operation is blocked or explicitly rejected
And the response includes an explicit error

## Scenario 14: Project isolation across supervised data
Given project "Alpha" and project "Beta" both exist
And each project has its own ideas, features, progress and metadata
When the operator views data scoped to project "Alpha"
Then only "Alpha" data is visible in that scope
And "Beta" data is not included in that scope

## Scenario 15: List behavior when no projects exist
Given the registry is empty
When the operator requests the project list
Then an explicit empty list is returned
And no implicit project is created

## Scenario 16: Reject archive for non-existent project
Given the registry contains no project with identity "P-404"
When the operator requests archive for project "P-404"
Then no project state changes
And the operation result is explicit failure with reason

## Scenario 17: Explicit failure when registered path/reference is unavailable
Given project "Alpha" is registered with local path/reference "/projects/alpha"
And the local path/reference is currently unavailable
When the operator performs an operation that requires that path/reference
Then no silent state change occurs
And the operation result is explicit failure with reason

## Scenario 18: Reject selection of non-existent project
Given the registry contains no project with identity "P-404"
When the operator selects project "P-404" as the active working project
Then no project is selected as the active working project
And the operation result is explicit failure with reason

## Scenario 19: Reject selection of archived project
Given project "Alpha" exists and is archived
When the operator selects "Alpha" as the active working project
Then no project is selected as the active working project
And the operation result is explicit failure with reason

## Scenario 20: Reject update that introduces duplicate active path/reference
Given an active project "Alpha" exists with local path/reference "/projects/alpha"
And an active project "Beta" exists with local path/reference "/projects/beta"
When the operator updates project "Beta" to use local path/reference "/projects/alpha"
Then the update is not applied
And the operation result is explicit failure with reason
