# Runtime Exec Spec

Kanoniczne zrodlo wykonania DS:
- `playbook-exec.yaml`

Plik opisuje deterministycznie:
- entrypointy,
- kroki wykonawcze,
- narzedzie per krok,
- request/response contracts,
- side effects i persistence map,
- retry/failure policy.

## Dry-run simulation (bez zapisow)

```bash
./playbook/verification/scripts/exec-dry-run.sh new_project playbook/runtime/playbook-exec.yaml playbook/runtime/simulation-inputs/new-project-ds.json
```

```bash
./playbook/verification/scripts/exec-dry-run.sh add_idea playbook/runtime/playbook-exec.yaml playbook/runtime/simulation-inputs/new-project-ds.json
```
