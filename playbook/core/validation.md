## Validation (OP-aligned)

## Testy jako specyfikacja

Dla implementacji zachowania:
1. zaktualizuj prd,
2. zaktualizuj bdd,
3. zaktualizuj testy,
4. dopiero potem kod.

Testy sa wykonywalna specyfikacja.

## Strategia testow

- Unit: wiekszosc przypadkow
- Integration: przeplywy
- UI: minimum niezbedne

## Build/Test/Lint loop

Kazda iteracja konczy sie:
- Scripts/build.sh
- Scripts/test.sh
- Scripts/lint.sh

Green status bez wykonanych testow nie przechodzi gate.

## OP quality contract

Walidacja musi zasilic OP:
- QualityEvidenceRecord (pass/fail)
- GateDecisionRecord (approve/request_changes/defer/reject)
- ProcessEventRecord (audit)

## Failure paths

Kazdy failure path powinien miec:
- scenariusz BDD,
- test,
- log,
- policy w OP (retry/compensation/escalation).

Jesli wystapi Exception albo timeout scheduler'a:
- zarejestruj Exception OP i SchedulerTimer event,
- wykonaj retry lub compensation,
- podejmij jawna decyzje gate.
