# Project Bootstrap Flow — Kontrola Spójności

Data: 2026-03-30
Zakres:
- `.ai/features/project-bootstrap-flow/prd.md`
- `.ai/features/project-bootstrap-flow/bdd.md`
- `App/Core/Domain/ProjectBootstrapContract.swift`
- `App/Core/Domain/ProjectBootstrapModels.swift`
- `App/Core/ProjectBootstrap/ProjectBootstrapFileSystem.swift`
- `App/ContentView.swift`
- `Scripts/test.sh`
- `Tests/ProjectBootstrap/ProjectBootstrapFileSystemTests.swift`

## Wynik ogólny
Funkcja tworzy pierwszy używalny punkt wejścia operatora: bootstrap nowego projektu i inspekcja istniejącego projektu, z profilem storage (`file-ai`/`sqlbase`).

## Potwierdzona zgodność
- Bootstrap tworzy baseline `.ai` i skrypty `Scripts/*`.
- Walidacja pustych wejść działa jawnie.
- Kolizja z niepustym katalogiem jest jawnie odrzucana.
- `sqlbase` tworzy artefakt `State/supervisor.sqlite3`.
- Inspekcja zwraca jawny raport o stanie projektu i wykrytym storage profile.
- Gate testowy jest deterministyczny: `./Scripts/test.sh` kończy się błędem, gdy nie można potwierdzić `testsCount > 0`.
- Skrypt testowy domyślnie uruchamia `-only-testing:DevSupervisorTests`, aby uniknąć niestabilności/blokad związanych z UI test target.
- Skrypt testowy ma watchdog timeout (`TEST_TIMEOUT_SECONDS`, domyślnie 900s), więc zawieszony `xcodebuild` nie blokuje workflow.
- Product Gate jest jawnie raportowany przez inspekcję (`overview`, `constraints`, `glossary`) i blokuje przejście `IDEA -> FEATURES` przy brakach.

## Braki lub niespójności
- Integracja bootstrapu z rejestrem projektów domenowych pozostaje otwarta.

## Rekomendowany następny pojedynczy krok
Zintegrować bootstrap z rejestrem projektów domenowych, tak aby nowy projekt był automatycznie widoczny w aktywnej liście projektów operatora.
