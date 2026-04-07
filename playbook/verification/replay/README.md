# Replay Scenarios

## Canonical scenarios

Do pelnej weryfikacji playbooka uzywamy:
- `scenario-e2e-full-op.csv`
- `scenario-chaos-full-op.csv`

Te dwa pliki sa zrodlem prawdy dla coverage `26/26 OP` w warstwach replay/e2e/chaos.

## Legacy / scoped scenarios

Ponizsze scenariusze sa nadal przydatne do szybkich testow lokalnych, ale nie stanowia pelnej walidacji:
- `scenario-e2e-reference.csv`
- `scenario-feature-happy.csv`
- `scenario-feature-rework.csv`
- `scenario-release-rollback.csv`
- `scenario-chaos-timeout.csv`
- `scenario-chaos-quality.csv`
- `scenario-chaos-deploy-rollback-fail.csv`
- `scenario-chaos-gate-reject.csv`
- `scenario-term-coverage.csv`
- `scenario-ui-component-coverage.csv`
- `scenario-ui-screen-coverage.csv`

## One-shot run

Pelny przebieg uruchom:

```bash
./playbook/verification/scripts/verify-all.sh 2026-04-07
```

Skrypt generuje podsumowanie:
- `playbook/verification/reports/2026-04-07-verify-all-summary.md`
