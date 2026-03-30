## ✅ Checklista startowa projektu

```text
[ ] utworzone repo
[ ] utworzony folder .ai
[ ] utworzone .ai/prd/overview.md
[ ] utworzony .ai/prd/constraints.md
[ ] utworzony .ai/prd/glossary.md
[ ] Product Gate przeszedł (kompletność + spójność + decyzja operatora)
[ ] utworzone .ai/stack/core.md
[ ] utworzone .ai/stack/architecture.md
[ ] utworzone .ai/stack/shared-code.md
[ ] utworzone .ai/stack/ui.md
[ ] utworzone .ai/stack/api.md
[ ] utworzone .ai/stack/rules.md
[ ] utworzony .ai/agent.md
[ ] utworzone Scripts/build.sh
[ ] utworzone Scripts/test.sh
[ ] utworzone Scripts/lint.sh
[ ] wybrany profil storage (`profiles/storage/file-ai.md` lub `profiles/storage/sqlbase.md`)
[ ] skonfigurowany podstawowy workflow Git (main + feat/<feature>)
[ ] utworzony .gitignore
[ ] ukończony setup stack profile (np. `profiles/stack/macos-swiftui.md`)
[ ] potwierdzone realne wykonanie testów (`testsCount > 0`)
```

---

## ✅ Checklista dodania feature

```text
[ ] idea dodana do .ai/ideas.md
[ ] wykonany scoping idea -> feature(s)
[ ] utworzony folder .ai/features/<feature>/
[ ] utworzony branch feat/<feature>
[ ] utworzony prd.md
[ ] utworzony bdd.md
[ ] utworzony tasks.md
[ ] utworzony notes.md
[ ] utworzony traceability.md
[ ] wygenerowane / poprawione testy
[ ] przygotowany plan implementacji
[ ] kod zaimplementowany krokami
[ ] review package pokazany operatorowi (diff + mapowanie do BDD + walidacja)
[ ] decyzja gate operatora zapisana (approve/request changes/defer/reject)
[ ] build przechodzi
[ ] testy przechodzą
[ ] lint przechodzi
[ ] testy faktycznie wykonane (nie tylko green status)
[ ] notes.md uzupełniony
[ ] tasks.md uzupełniony (status wykonania + deferred)
[ ] traceability.md uzupełniony
[ ] sprawdzono czy nie ma duplikacji do extraction
[ ] wykonany integration hardening
[ ] brak dead code
[ ] PR przygotowany i gotowy do merge
```

---

## ✅ Checklista zmiany feature

```text
[ ] zaktualizowany prd.md
[ ] zaktualizowany bdd.md
[ ] zaktualizowane lub wygenerowane od nowa testy
[ ] zaktualizowany traceability.md
[ ] wykonana analiza rozbieżności
[ ] przygotowany plan migracji
[ ] stary kod usunięty lub zastąpiony
[ ] nieaktualne testy usunięte
[ ] nieaktualne referencje w traceability usunięte
[ ] build przechodzi
[ ] testy przechodzą
[ ] lint przechodzi
[ ] testy faktycznie wykonane (nie tylko green status)
[ ] tasks.md zaktualizowany (status wykonania + deferred)
[ ] traceability.md zaktualizowany
[ ] review package pokazany operatorowi i decyzja gate zapisana
[ ] wykonany integration hardening
[ ] brak martwego kodu po starej implementacji
[ ] branch gotowy do merge po review
```

---

## ✅ Checklista współdzielonego kodu

```text
[ ] sprawdzono czy podobna logika już istnieje w Core/*
[ ] brak lokalnych helperów dublujących wspólny kod
[ ] drugi podobny przypadek został zgłoszony do extraction
[ ] współdzielony kod trafił do właściwego modułu (Domain / Shared / Providers / Routing)
[ ] zaktualizowano .ai/stack/shared-code.md jeśli pojawiła się nowa reguła organizacji kodu
```
