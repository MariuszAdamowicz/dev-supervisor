# Verification Module

Cel:
sprawdzic, czy playbook dziala deterministycznie i operacyjnie, a nie tylko jest spojnym opisem.

## Zakres
1. Walidacja statyczna kontraktow playbooka.
2. Symulacja deterministyczna (replay eventow OP).
3. E2E run na projekcie referencyjnym.
4. Testy odpornosci procesu (chaos procesowy).

## Artefakty modulu
- verification/static-validation.md
- verification/deterministic-replay.md
- verification/e2e-reference-run.md
- verification/chaos-tests.md
- verification/report-template.md

## Kryterium koncowe
Playbook uznajemy za dzialajacy, jesli wszystkie cztery warstwy testu przejda i powstanie raport zgodny z `verification/report-template.md`.
