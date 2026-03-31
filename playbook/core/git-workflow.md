## Git Workflow (OP-aligned)

## Cel
Git ma wspierac bezpieczne przejscia OP, nie byc osobnym procesem.

## Model branchingu

- main: jedyna dlugowieczna galaz
- feat/<feature>: branch dla jednej odpowiedzialnosci

Zasady:
- maly branch, maly diff, szybki merge,
- branch startuje z aktualnego main,
- po merge branch jest usuwany.

## Minimalny flow

1. git checkout main && git pull
2. git checkout -b feat/<feature>
3. praca + commity logiczne
4. build/test/lint
5. review package + GateDecision
6. merge do main
7. usuniecie brancha

## PR i solo mode

- W trybie zespolowym: PR jest preferowanym gate review.
- W trybie solo-no-pr: self-review jest obowiazkowy i rownowazny gate.

## Definition of Done (branch)

Przed merge musza byc domkniete:
- feature artifacts (prd, bdd, tasks, notes, traceability),
- build/test/lint,
- GateDecision,
- QualitySignal,
- brak krytycznych otwartych PromptTask.

## OP alignment

Merge do main jest dozwolony tylko jesli przejscie OP jest legalne wg guardow.
Wymagane artefakty audytu:
- ProcessEvent,
- GateDecision,
- quality outcome.
