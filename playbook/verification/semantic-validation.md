# Semantic Validation

Cel:
zweryfikowac nie tylko obecnosc nazw i artefaktow, ale tez prawdziwa semantyke procesu.

## 1. Co musi byc sprawdzane

1. Workflow <-> exec alignment
- `workflow/*` i `runtime/playbook-exec.yaml` nie moga opisywac roznych baseline, entrypointow ani gate rules.

2. Authz semantics
- kazdy state-changing flow ma authz precheck, deny-by-default i sciezke `Exception(authz)`.

3. Guard semantics
- guardy z OP sa egzekwowane przed zapisem stanu, a nie tylko opisywane w dokumentacji.

4. Invariant semantics
- parent linkage, no-cycle, dependency direction, open critical task rules i terminal path rules sa sprawdzane na dowodach runtime.

5. CRUD semantics
- create/read/update/remove dla OP i artefaktow jest deterministyczne i audytowalne.

6. Evidence class semantics
- symulacja, fixture, runtime capture i lane binarny maja jawna klase dowodu.

## 2. Minimalne metody walidacji

- structural checks,
- state-machine replay,
- contract tests dla request/response/tool contracts,
- semantic assertions na runtime evidence,
- negative tests dla authz, invalidation, reject/defer, retry, compensation,
- provenance verification.

## 3. Kryterium PASS

PASS wymaga lacznie:
- brak niespelnionych kontraktow strukturalnych,
- brak niespelnionych kontraktow semantycznych,
- real runtime capture dla co najmniej jednego end-to-end flow,
- lane binarny aplikacji pass dla zakresu zmiany,
- provenance i evidence class zapisane dla kazdego dowodu.

## 4. Zrodla praktyk

Punkty odniesienia:
- OWASP Authorization Cheat Sheet: deny-by-default i testowanie autoryzacji.
- Pact: kontrakty powinny sprawdzac zachowanie na granicach, nie tylko schematy.
- Temporal: workflow musi byc deterministyczny, replayable i jawnie modelowac retry/timeout/recovery.

Linki:
- https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html
- https://docs.pact.io/
- https://docs.temporal.io/workflow-definition
- https://docs.temporal.io/encyclopedia/retry-policies
