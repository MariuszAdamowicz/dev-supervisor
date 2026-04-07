# Playbook Correctness Matrix

Cel:
jednoznacznie pokazac, czy playbook jest poprawny operacyjnie dla wszystkich OP i czy raport nie myli symulacji z realnym runtime.

## Definicja "poprawny playbook"

Dla kazdego OP musza byc spelnione 6 warstw:
1. `static`: definicja OP + FSM + binding coverage.
2. `semantic`: workflow<->exec alignment, authz, guardy, invarianty, CRUD, provenance labeling.
3. `replay`: deterministyczny wynik (run1 == run2).
4. `fixture`: syntetyczny runtime fixture z klasyfikacja evidence.
5. `runtime`: real runtime capture (nie fixture).
6. `chaos`: legalna reakcja na zaklocenia i komplet audytu.

## Status po korekcie kontraktow

Wersja historyczna `2026-04-07-full-op` byla wystarczajaca dla starej definicji 4-warstwowej, ale nie dla aktualnej definicji 6-warstwowej.

Dlatego aktualny status globalny brzmi:
- `static`: legacy-pass
- `semantic`: pending-rerun
- `replay`: legacy-pass
- `fixture`: legacy-pass
- `runtime`: pending-real-capture
- `chaos`: legacy-pass

## Regula decyzji

Globalny `verified` mozna ustawic tylko gdy:
- `semantic=pass`
- `runtime=pass`
- `fixture` i `replay` sa tylko wsparciem, nie substytutem runtime
- raport zawiera provenance metadata

W przeciwnym razie status globalny musi pozostac:
- `partial`, albo
- `pending-rerun`.
