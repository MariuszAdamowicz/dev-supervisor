# Verification Module

Cel:
sprawdzic, czy playbook dziala deterministycznie i operacyjnie, a nie tylko jest spojnym opisem.

## Zakres
1. Walidacja statyczna kontraktow playbooka.
2. Walidacja semantyczna guardow, invariantow, CRUD i authz.
3. Symulacja deterministyczna (replay eventow OP).
4. E2E run na projekcie referencyjnym.
5. Testy odpornosci procesu (chaos procesowy).

## Artefakty modulu
- runtime/playbook-exec.yaml
- verification/static-validation.md
- verification/semantic-validation.md
- verification/deterministic-replay.md
- verification/e2e-reference-run.md
- verification/evidence-provenance.md
- verification/chaos-tests.md
- verification/playbook-correctness-matrix.md
- verification/report-template.md
- verification/scripts/semantic-contract-audit.sh
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
Playbook uznajemy za dzialajacy, jesli przejda warstwy strukturalna, semantyczna, replay, e2e real runtime i chaos, a raport rozroznia evidence syntetyczne od realnego.
