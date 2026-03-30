# Traceability — BDD to Tests Flow

## Reguła: Aktywny projekt jest wymagany
- BDD: Scenariusz 2
- Testy: `testScenario02_generateTestsFromBDDWithoutActiveProject_returnsExplicitFailure`

## Reguła: Tytuł idei i dokument BDD są wymagane
- BDD: Scenariusz 3, 4
- Testy: `testScenario03_generateTestsFromBDDWithEmptyIdeaTitle_returnsExplicitFailure`, `testScenario04_generateTestsFromBDDWithEmptyDocument_returnsExplicitFailure`

## Reguła: Kontekst minimalny jest wymagany
- BDD: Scenariusz 5, 6
- Testy: `testScenario05_generateTestsFromBDDWithMissingContext_returnsExplicitFailure`, `testScenario06_generatedPromptIncludesMinimalContext_withExplicitSuccess`

## Reguła: Determinizm
- BDD: Scenariusz 7
- Testy: `testScenario07_generateTestsFromBDDDeterministically_returnsEquivalentPromptAndFingerprint`

## Reguła: Brak automatycznego wykonania promptu
- BDD: Scenariusz 8
- Testy: `testScenario08_generateTestsFromBDD_doesNotAutoExecuteAgainstAIProvider`

## Reguła: Ślad operacyjny
- BDD: Scenariusz 9
- Testy: `testScenario09_generateTestsFromBDDCreatesTraceBoundToIdeaAndProject`
