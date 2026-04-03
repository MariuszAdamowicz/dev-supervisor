# Playbook Review Protocol v1 — Krok 5: Patche P0

Data UTC: 2026-04-03T22:34:00Z

## Cel kroku
Usunac luki P0 z audytu coverage:
1. domkniecie lifecycle `Feature` (`released`, `done`),
2. domkniecie lifecycle `Release` (`published`, `closed`),
3. rozdzielenie deployment transitions na osobne kroki.

## Zmiany wykonane

### 1) Trigger rules (`playbook/layers/op/trigger-rules.md`)
Dodano:
- `Deployment.succeeded` -> oznaczenie `Release.published` i odblokowanie `Feature.released`.
- `Release.published` -> tworzenie prompt taskow domkniecia (`release-close-review`, `feature-close-review`).

### 2) Bindings (`playbook/tooling/bindings.md`)
- Rozdzielono deployment:
  - `Deployment.prepared -> Deployment.running`
  - `Deployment.running -> Deployment.succeeded`
- Dodano brakujace przejscia:
  - `Feature.stabilized -> Feature.released`
  - `Feature.released -> Feature.done`
  - `Release.approved -> Release.published`
  - `Release.published -> Release.closed`
- Utrzymano rollback chain z jawnym zapisem compensation outcome.

## Analiza kroku: czy to byl wlasciwy krok?
Tak. To najnizszy kosztowo zestaw zmian, ktory domyka najwazniejsze luki lifecycle bez przebudowy calego modelu OP.

## Analiza alternatywy: co moglo byc inne?
Mozna bylo od razu dopisac tez P1/P2, ale to zwiekszyloby ryzyko niespojnych zmian i utrudnilo walidacje efektu P0.

## Dowod kroku
- zmiany w `trigger-rules.md` i `bindings.md`
- ten artefakt review

## Otwarty efekt uboczny (do P1)
Nadal brak formalnego standardu "kiedy gate jest wymagany" dla nowych transition closure (`Feature.done`, `Release.closed`) poza kontraktem Decision Envelope. W kroku P1 trzeba to doprecyzowac jako regule walidacji.

## Nastepny krok
Krok 6: patch P1 (PromptTask lifecycle, QualitySignal.pass, Project.archived, doprecyzowanie gate-required classifier).
