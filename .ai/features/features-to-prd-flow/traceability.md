# Traceability — Features to PRD Flow

## Reguła: Aktywny projekt jest wymagany
- BDD: Scenariusz 2
- Testy: `testScenario02_generatePRDFromFeaturesWithoutActiveProject_returnsExplicitFailure`

## Reguła: Tytuł idei i lista funkcjonalności są wymagane
- BDD: Scenariusz 3, 4
- Testy: `testScenario03_generatePRDFromFeaturesWithEmptyIdeaTitle_returnsExplicitFailure`, `testScenario04_generatePRDFromFeaturesWithoutFeatureCandidates_returnsExplicitFailure`

## Reguła: Kontekst minimalny jest wymagany
- BDD: Scenariusz 5, 6
- Testy: `testScenario05_generatePRDFromFeaturesWithMissingContext_returnsExplicitFailure`, `testScenario06_generatedPromptIncludesMinimalContext_withExplicitSuccess`

## Reguła: Determinizm
- BDD: Scenariusz 7
- Testy: `testScenario07_generatePRDFromFeaturesDeterministically_returnsEquivalentPromptAndFingerprint`

## Reguła: Brak automatycznego wykonania promptu
- BDD: Scenariusz 8
- Testy: `testScenario08_generatePRDFromFeatures_doesNotAutoExecuteAgainstAIProvider`

## Reguła: Ślad operacyjny
- BDD: Scenariusz 9
- Testy: `testScenario09_generatePRDFromFeaturesCreatesTraceBoundToIdeaAndProject`
