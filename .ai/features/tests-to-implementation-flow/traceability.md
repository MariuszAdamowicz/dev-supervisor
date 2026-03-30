# Traceability — Tests to Implementation Flow

## Reguła: Aktywny projekt jest wymagany
- BDD: Scenariusz 2
- Testy: `testScenario02_generateImplementationFromTestsWithoutActiveProject_returnsExplicitFailure`

## Reguła: Tytuł idei i dokument testów są wymagane
- BDD: Scenariusz 3, 4
- Testy: `testScenario03_generateImplementationFromTestsWithEmptyIdeaTitle_returnsExplicitFailure`, `testScenario04_generateImplementationFromTestsWithEmptyDocument_returnsExplicitFailure`

## Reguła: Kontekst minimalny jest wymagany
- BDD: Scenariusz 5, 6
- Testy: `testScenario05_generateImplementationFromTestsWithMissingContext_returnsExplicitFailure`, `testScenario06_generatedPromptIncludesMinimalContext_withExplicitSuccess`

## Reguła: Determinizm
- BDD: Scenariusz 7
- Testy: `testScenario07_generateImplementationFromTestsDeterministically_returnsEquivalentPromptAndFingerprint`

## Reguła: Brak automatycznego wykonania promptu
- BDD: Scenariusz 8
- Testy: `testScenario08_generateImplementationFromTests_doesNotAutoExecuteAgainstAIProvider`

## Reguła: Ślad operacyjny
- BDD: Scenariusz 9
- Testy: `testScenario09_generateImplementationFromTestsCreatesTraceBoundToIdeaAndProject`
