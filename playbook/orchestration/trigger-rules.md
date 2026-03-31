## Trigger Rules (event -> action)

Cel: automatycznie generowac wlasciwe PromptTask i wymuszac pelny flow bez recznego pilnowania zaleznosci.

## Reguly bazowe

### Idea / Feature
- Event: `Idea.scoped`
- Action: utworz `PromptTask(prd-draft)` dla nowego feature.

- Event: `Feature.specified`
- Action: utworz `PromptTask(ux-contract-check)`.

- Event: `Feature.ux-aligned`
- Action: utworz `PromptTask(prd-to-bdd)`.

- Event: `Scenario.updated`
- Action: utworz `PromptTask(bdd-to-tests)`.

### Terminologia (glossary lifecycle)
- Event: `Term.proposed`
- Action: utworz `PromptTask(term-impact-check)`:
  - czy termin wymaga nowego `UIComponent`
  - czy termin zmienia copy istniejacych komponentow
  - czy termin wymaga nowych scenariuszy BDD

- Event: `Term.approved`
- Action: zaktualizuj `glossary.md` i traceability (`Feature <-> Term`).

- Event: `Term.deprecated`
- Action: utworz `PromptTask(term-cleanup)` dla UI copy, scenariuszy i testow.

### UI/UX
- Event: `UIComponent.proposed`
- Action: utworz `PromptTask(ui-placement)`:
  - umiejscowienie w `UIScreen`
  - reguly visibility
  - reguly gate availability

- Event: `UIComponent.mapped`
- Action: utworz `PromptTask(ui-implementation)`.

- Event: `UIComponent.implemented`
- Action: utworz `PromptTask(ux-validation)` + testy widocznosci.

### Gate i walidacja
- Event: `PromptTask.executed`
- Action: zbuduj review package (diff + BDD map + build/test/lint).

- Event: `GateDecision.request_changes`
- Action: utworz `PromptTask(debug/fix)` z minimalnym kontekstem.

- Event: `GateDecision.approve`
- Action: odblokuj nastepny stan OP.

## Reguly deterministyczne
- Jeden event moze utworzyc wiele PromptTask, ale kazdy task ma jednego wlasciciela OP.
- Task bez wskazanego `target-op` jest niewazny.
- Nie mozna zamknac `Feature`, jesli istnieje otwarty `PromptTask` krytyczny.
