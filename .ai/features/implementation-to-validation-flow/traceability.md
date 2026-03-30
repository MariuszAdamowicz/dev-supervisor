# Traceability — Implementation to Validation Flow

## Reguła: Aktywny projekt jest wymagany
- BDD: Scenariusz 2
- Testy: `testScenario02_generateValidationFromImplementationWithoutActiveProject_returnsExplicitFailure`

## Reguła: Tytuł idei i dokument implementacji są wymagane
- BDD: Scenariusz 3, 4
- Testy: `testScenario03_generateValidationFromImplementationWithEmptyIdeaTitle_returnsExplicitFailure`, `testScenario04_generateValidationFromImplementationWithEmptyDocument_returnsExplicitFailure`

## Reguła: Kontekst minimalny jest wymagany
- BDD: Scenariusz 5, 6
- Testy: `testScenario05_generateValidationFromImplementationWithMissingContext_returnsExplicitFailure`, `testScenario06_generatedPromptIncludesMinimalContext_withExplicitSuccess`

## Reguła: Determinizm
- BDD: Scenariusz 7
- Testy: `testScenario07_generateValidationFromImplementationDeterministically_returnsEquivalentPromptAndFingerprint`

## Reguła: Brak automatycznego wykonania promptu
- BDD: Scenariusz 8
- Testy: `testScenario08_generateValidationFromImplementation_doesNotAutoExecuteAgainstAIProvider`

## Reguła: Ślad operacyjny
- BDD: Scenariusz 9
- Testy: `testScenario09_generateValidationFromImplementationCreatesTraceBoundToIdeaAndProject`
