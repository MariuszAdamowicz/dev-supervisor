# Verification Module

Cel:
sprawdzic, czy playbook dziala deterministycznie i operacyjnie, a nie tylko jest spojnym opisem.

## Zakres
1. Walidacja statyczna kontraktow playbooka.
2. Symulacja deterministyczna (replay eventow OP).
3. E2E run na projekcie referencyjnym.
4. Testy odpornosci procesu (chaos procesowy).

## Artefakty modulu
- runtime/playbook-exec.yaml
- verification/static-validation.md
- verification/deterministic-replay.md
- verification/e2e-reference-run.md
- verification/chaos-tests.md
- verification/playbook-correctness-matrix.md
- verification/report-template.md
- verification/replay/README.md
- verification/scripts/verify-all.sh
- verification/scripts/exec-spec-check.sh
- verification/scripts/exec-dry-run.sh
- verification/scripts/exec-transition-coverage-check.sh
- verification/scripts/exec-transition-preview.sh

## Canonical outcome (full-op)

Raport nadrzedny dla decyzji globalnej:
- `verification/reports/2026-04-07-full-op-verification-report.md`

## Kryterium koncowe
Playbook uznajemy za dzialajacy, jesli wszystkie cztery warstwy testu przejda i powstanie raport zgodny z `verification/report-template.md`.
