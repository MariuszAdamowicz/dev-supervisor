# Replay Scenarios

## Canonical scenarios

Do pelnej weryfikacji playbooka uzywamy:
- `scenario-e2e-full-op.csv`
- `scenario-chaos-full-op.csv`

Te dwa pliki sa zrodlem prawdy dla coverage `N/N OP`, gdzie `N` jest liczone z kanonicznego FSM w `layers/op/state-machines.md`.

## Legacy / scoped scenarios

Ponizsze scenariusze sa nadal przydatne do szybkich testow lokalnych, ale nie stanowia pelnej walidacji:
- `scenario-e2e-reference.csv`
- `scenario-feature-happy.csv`
- `scenario-feature-rework.csv`
- `scenario-access-grant.csv`
- `scenario-decision-record.csv`
- `scenario-environment-target.csv`
- `scenario-exception-case.csv`
- `scenario-glossary-entry.csv`
- `scenario-migration-action.csv`
- `scenario-repository-control.csv`
- `scenario-risk-entry.csv`
- `scenario-verification-policy.csv`
- `scenario-release-bundle.csv`
- `scenario-release-rollback.csv`
- `scenario-chaos-timeout.csv`
- `scenario-chaos-quality.csv`
- `scenario-chaos-deploy-rollback-fail.csv`
- `scenario-chaos-gate-reject.csv`
- `scenario-ui-component-coverage.csv`
- `scenario-ui-screen-coverage.csv`

## One-shot run

Pelny przebieg uruchom:

```bash
./playbook/verification/scripts/verify-all.sh 2026-04-07
```

Skrypt generuje podsumowanie:
- `playbook/verification/reports/2026-04-07-verify-all-summary.md`
