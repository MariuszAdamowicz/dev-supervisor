# Traceability — Gate Prompt Persistence

## Reguła: Zapis dla file-ai trafia do .ai/gates
- BDD: Scenariusz 1
- Testy: `testPersistPrompt_forFileAI_writesUnderAIGatesDirectory`

## Reguła: Zapis dla sqlbase trafia do State/gates
- BDD: Scenariusz 2
- Testy: `testPersistPrompt_forSQLBase_writesUnderStateGatesDirectory`

## Reguła: Pusty prompt powoduje jawną porażkę
- BDD: Scenariusz 3
- Testy: `testPersistPrompt_withEmptyPrompt_returnsExplicitFailure`

## Reguła: Persystencja uruchamiana po sukcesie gate
- BDD: Scenariusz 4
- Testy: pokryte integracyjnie przez wywołania `persistPromptIfPossible` w `ContentView` po sukcesie gate
