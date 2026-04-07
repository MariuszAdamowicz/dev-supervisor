# Runtime Exec Spec

Kanoniczne zrodlo wykonania DS:
- `playbook-exec.yaml`

Plik opisuje deterministycznie:
- entrypointy,
- entrypoint contracts (task-first UX + baseline/authz/CRUD/evidence),
- kroki wykonawcze,
- narzedzie per krok,
- request/response contracts,
- side effects i persistence map,
- transition execution templates (gate/non-gate/retry-escalation) dla calego FSM,
- retry/failure policy.

Wymaganie:
- bootstrap `new_project` obejmuje lokalny git oraz utworzenie/podpiecie repozytorium zdalnego (GitHub adapter).

## Dry-run simulation (bez zapisow)

```bash
./playbook/verification/scripts/exec-dry-run.sh new_project playbook/runtime/playbook-exec.yaml playbook/runtime/simulation-inputs/new-project-ds.json
```

```bash
./playbook/verification/scripts/exec-dry-run.sh add_idea playbook/runtime/playbook-exec.yaml playbook/runtime/simulation-inputs/new-project-ds.json
```

Podglad globalny (pierwsze N transition z calego FSM, mapowane na templates wykonawcze):

```bash
./playbook/verification/scripts/exec-transition-preview.sh playbook/runtime/playbook-exec.yaml playbook/layers/op/state-machines.md 40
```

Uwaga:
- dry-run i fixture run sa dowodami syntetycznymi.
- globalny PASS wymaga dodatkowo runtime-capture i binary-quality-lane.
