## Rewrite Protocol (OP-aligned)

Zmiana feature bez aktualizacji testow jest bledem procesu.

## Kanoniczny flow rewrite

update spec -> update BDD -> update tests -> migrate code -> cleanup -> stabilize -> release handoff

## Kroki

1. Zaktualizuj prd.
2. Zaktualizuj bdd.
3. Zaktualizuj testy.
4. Zaktualizuj traceability.
5. Porownaj mismatch implementacji vs nowa spec.
6. Przygotuj plan migracji.
7. Zastosuj migracje i usun obsolete code/tests.
8. Uruchom build/test/lint.
9. Zapisz GateDecision.

## OP requirements

Podczas rewrite musza byc zaktualizowane:
- Feature OP state,
- Scenario OP i linki testow,
- Requirement/Constraint/DecisionRecord (jesli dotkniete),
- QualitySignal,
- ProcessEvent.

Jesli rewrite powoduje regression risk:
- utworz Risk OP,
- zweryfikuj Dependency OP,
- wykonaj dodatkowy gate przed release handoff.
