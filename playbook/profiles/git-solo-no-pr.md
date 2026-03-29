## Git Profile: Solo No PR

Cel:
- uprościć workflow dla pojedynczego developera
- zachować jakość bez formalnego etapu platformowego Pull Request

## Kiedy używać
- projekt ma jednego aktywnego developera
- akceptacja PR jest technicznie zablokowana lub nieopłacalna
- chcesz utrzymać szybki, deterministyczny loop zmian

## Reguły
- dalej pracuj w branchach `feat/<feature>`
- nie pushuj zmian roboczych bez walidacji
- przed merge do `main` wykonaj self-review na checklistach z `core/git-workflow.md`
- merge do `main` wyłącznie po zielonym:
  - `./Scripts/build.sh`
  - `./Scripts/test.sh`
  - `./Scripts/lint.sh`

## Minimalny daily flow
```bash
git checkout main
git pull
git checkout -b feat/<feature>
# implementacja krokami + commity
./Scripts/build.sh
./Scripts/test.sh
./Scripts/lint.sh
# self-review (spec/BDD/tests/duplikacja/traceability)
git checkout main
git merge --no-ff feat/<feature>
git push origin main
git branch -d feat/<feature>
git push origin --delete feat/<feature>
```

## Artifacts gate
Przed merge do `main` upewnij się, że:
- `prd.md`, `bdd.md`, `notes.md`, `tasks.md`, `traceability.md` są zsynchronizowane i domknięte
- testy pokrywają aktualne scenariusze BDD
- nie ma martwego kodu po zmianie feature
