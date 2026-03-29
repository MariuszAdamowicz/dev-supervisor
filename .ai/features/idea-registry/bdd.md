# Feature: Idea Registry

## Scenario 1: Create an idea for active project with valid title
Given project "Alpha" is selected as the active project
And the idea registry for project "Alpha" is empty
When the operator creates an idea with title "Offline mode" and description "Support offline workflow"
Then a new idea record is created with stable identity
And the idea belongs to project "Alpha"
And the idea status is `new`
And the operation result is explicit success

## Scenario 2: Support multiple ideas within one project
Given project "Alpha" is selected as the active project
And project "Alpha" already has idea "Offline mode"
When the operator creates another idea with title "Bulk import"
Then both ideas exist in project "Alpha" idea registry
And each idea remains uniquely identifiable
And the operation result is explicit success

## Scenario 3: Reject idea creation when no active project is selected
Given no active project is selected
When the operator creates an idea with title "Offline mode"
Then no idea is created
And the operation is blocked or explicitly rejected
And the operation result is explicit failure with reason

## Scenario 4: Reject idea creation with empty title
Given project "Alpha" is selected as the active project
When the operator creates an idea with an empty title
Then no idea is created
And the operation result is explicit failure with reason

## Scenario 5: Update idea content by explicit operator action
Given project "Alpha" is selected as the active project
And idea "Offline mode" exists in project "Alpha"
When the operator updates idea "Offline mode" title to "Offline-first mode" and description to "Prioritize no-network use"
Then the same idea identity is preserved
And updated idea content is visible in project "Alpha"
And the operation result is explicit success

## Scenario 6: Reject update for non-existent idea
Given project "Alpha" is selected as the active project
And project "Alpha" contains no idea with identity "I-404"
When the operator requests content update for idea "I-404"
Then no idea state changes
And the operation result is explicit failure with reason

## Scenario 7: Change idea status to deferred
Given project "Alpha" is selected as the active project
And idea "Offline mode" exists in project "Alpha" with status `new`
When the operator changes status of idea "Offline mode" to `deferred`
Then idea "Offline mode" status is `deferred`
And the operation result is explicit success

## Scenario 8: Select one idea as PRD candidate
Given project "Alpha" is selected as the active project
And idea "Offline mode" exists in project "Alpha" with status `new`
When the operator changes status of idea "Offline mode" to `selected`
Then idea "Offline mode" status is `selected`
And project "Alpha" has explicit indicator of selected PRD candidate
And the operation result is explicit success

## Scenario 9: Reject second selected idea in the same project
Given project "Alpha" is selected as the active project
And idea "Offline mode" exists in project "Alpha" with status `selected`
And idea "Bulk import" exists in project "Alpha" with status `new`
When the operator changes status of idea "Bulk import" to `selected`
Then idea "Bulk import" status remains `new`
And only one idea remains `selected` in project "Alpha"
And the operation result is explicit failure with reason

## Scenario 10: Reject invalid idea status value
Given project "Alpha" is selected as the active project
And idea "Offline mode" exists in project "Alpha"
When the operator changes status of idea "Offline mode" to "in-progress"
Then idea "Offline mode" status does not change
And the operation result is explicit failure with reason

## Scenario 11: Reject status change for non-existent idea
Given project "Alpha" is selected as the active project
And project "Alpha" contains no idea with identity "I-404"
When the operator changes status for idea "I-404" to `deferred`
Then no idea state changes
And the operation result is explicit failure with reason

## Scenario 12: Reject update and status changes when no active project is selected
Given no active project is selected
And idea records exist in other projects
When the operator requests idea update or status change
Then no idea state changes
And the operation is blocked or explicitly rejected
And the operation result is explicit failure with reason

## Scenario 13: List ideas scoped to active project only
Given project "Alpha" is selected as the active project
And project "Alpha" has idea "Offline mode"
And project "Beta" has idea "Telemetry export"
When the operator requests idea list for active project
Then the list includes only ideas from project "Alpha"
And no idea from project "Beta" is included

## Scenario 14: List ideas returns explicit empty list
Given project "Alpha" is selected as the active project
And project "Alpha" has no ideas
When the operator requests idea list for active project
Then an explicit empty list is returned
And no implicit idea is created

## Scenario 15: Selecting PRD candidate is explicit and traceable
Given project "Alpha" is selected as the active project
And idea "Offline mode" exists with status `new`
When the operator explicitly selects idea "Offline mode" as PRD candidate
Then idea "Offline mode" status becomes `selected`
And the selection change is traceable as an explicit state transition
And the operation result is explicit success

## Scenario 16: Preserve project isolation for idea access
Given project "Alpha" and project "Beta" both exist
And project "Alpha" is selected as the active project
And project "Beta" contains idea "Telemetry export"
When the operator requests operations in project "Alpha" scope
Then idea data from project "Beta" is not accessible in that scope
And no cross-project idea mutation is performed
