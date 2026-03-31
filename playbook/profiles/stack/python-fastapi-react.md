## Python FastAPI + React Stack Profile

## Zakres
- backend: Python + FastAPI
- frontend: React + TypeScript
- storage: PostgreSQL/SQLite (zależnie od profilu storage)

## Setup platform-specific
- skonfiguruj środowisko Pythona (venv/uv)
- skonfiguruj dependency lock
- skonfiguruj testy (`pytest`) i lint (`ruff`)
- skonfiguruj frontend build/test/lint

## Script expectations
- `Scripts/build.sh` buduje frontend i waliduje backend
- `Scripts/test.sh` uruchamia `pytest` + testy frontend
- `Scripts/lint.sh` uruchamia `ruff` + frontend lint
