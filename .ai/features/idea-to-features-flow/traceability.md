# Traceability — Idea to Features Flow

## Reguła: Aktywny projekt jest wymagany
- BDD: Scenariusz 2
- Testy: `testScenario02_generateFeaturesPromptWithoutActiveProject_returnsExplicitFailure`

## Reguła: Idea musi należeć do aktywnego projektu
- BDD: Scenariusz 3, 4
- Testy: `testScenario03_generateFeaturesPromptForNonExistentIdea_returnsExplicitFailure`, `testScenario04_generateFeaturesPromptForIdeaOutsideActiveProject_returnsExplicitFailure`

## Reguła: Idea musi mieć status `selected`
- BDD: Scenariusz 5
- Testy: `testScenario05_generateFeaturesPromptForIdeaNotSelected_returnsExplicitFailure`

## Reguła: Minimalny kontekst jest wymagany
- BDD: Scenariusz 6, 7
- Testy: `testScenario06_generatedPromptIncludesMinimalContext_withExplicitSuccess`, `testScenario07_generateFeaturesPromptWithMissingContext_returnsExplicitFailure`

## Reguła: Determinizm
- BDD: Scenariusz 8
- Testy: `testScenario08_generateFeaturesPromptDeterministicallyForSameInput_returnsEquivalentPrompt`

## Reguła: Aplikacja nie wykonuje promptu u AI
- BDD: Scenariusz 9
- Testy: `testScenario09_generateFeaturesPrompt_doesNotAutoExecuteAgainstAIProvider`

## Reguła: Wynik zawiera tożsamość idei i projektu
- BDD: Scenariusz 10
- Testy: `testScenario10_generationResultIncludesExplicitIdeaAndProjectIdentity`

## Reguła: Brak efektów ubocznych + ślad operacyjny
- BDD: Scenariusz 11
- Testy: `testScenario11_generatingFeaturesPromptDoesNotMutateIdeaAndCreatesTrace`
