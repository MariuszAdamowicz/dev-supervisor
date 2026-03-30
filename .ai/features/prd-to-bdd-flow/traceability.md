# Traceability — PRD to BDD Flow

## Reguła: Aktywny projekt jest wymagany
- BDD: Scenariusz 2
- Testy: `testScenario02_generateBDDFromPRDWithoutActiveProject_returnsExplicitFailure`

## Reguła: Tytuł idei i dokument PRD są wymagane
- BDD: Scenariusz 3, 4
- Testy: `testScenario03_generateBDDFromPRDWithEmptyIdeaTitle_returnsExplicitFailure`, `testScenario04_generateBDDFromPRDWithEmptyDocument_returnsExplicitFailure`

## Reguła: Kontekst minimalny jest wymagany
- BDD: Scenariusz 5, 6
- Testy: `testScenario05_generateBDDFromPRDWithMissingContext_returnsExplicitFailure`, `testScenario06_generatedPromptIncludesMinimalContext_withExplicitSuccess`

## Reguła: Determinizm
- BDD: Scenariusz 7
- Testy: `testScenario07_generateBDDFromPRDDeterministically_returnsEquivalentPromptAndFingerprint`

## Reguła: Brak automatycznego wykonania promptu
- BDD: Scenariusz 8
- Testy: `testScenario08_generateBDDFromPRD_doesNotAutoExecuteAgainstAIProvider`

## Reguła: Ślad operacyjny
- BDD: Scenariusz 9
- Testy: `testScenario09_generateBDDFromPRDCreatesTraceBoundToIdeaAndProject`
