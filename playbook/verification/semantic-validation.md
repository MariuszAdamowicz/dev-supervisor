# Semantic Validation

Cel:
zweryfikowac nie tylko obecnosc nazw i artefaktow, ale tez prawdziwa semantyke procesu.

## 1. Co musi byc sprawdzane

1. Workflow <-> exec alignment
- `workflow/*` i `runtime/playbook-exec.yaml` nie moga opisywac roznych baseline, entrypointow ani gate rules.

2. Authz semantics
- kazdy state-changing flow ma authz precheck, deny-by-default i sciezke `ExceptionCase(authz)`.

3. Guard semantics
- guardy z OP sa egzekwowane przed zapisem stanu, a nie tylko opisywane w dokumentacji.

4. Invariant semantics
- parent linkage, no-cycle, dependency relation status, dependency direction, open critical task rules i terminal path rules sa sprawdzane na dowodach runtime.
- `SchedulerTimer` ma poprawny lifecycle `scheduled -> fired -> consumed|cancelled`.
- `DeploymentRun` ma poprawny lifecycle `planned -> running -> succeeded|failed|cancelled`.
- `PromptTask` ma poprawny lifecycle `created -> ready -> executed -> validated|cancelled -> closed|cancelled`.
- `RollbackAction` ma poprawny lifecycle `planned -> running -> completed|failed|cancelled`.
- `CompensationAction` ma poprawny lifecycle `planned -> running -> completed|failed|cancelled`.

5. CRUD semantics
- create/read/update/remove dla OP, relacji grafu i artefaktow jest deterministyczne i audytowalne.
- create/read/update/remove dla delivery controls jest deterministyczne i audytowalne.
- create/read/update/remove dla job controls jest deterministyczne i audytowalne.
- create/read/update/remove dla risk controls jest deterministyczne i audytowalne.
- create/read/update/remove dla scheduler controls jest deterministyczne i audytowalne.
- create/read/update/remove dla recovery controls jest deterministyczne i audytowalne.

6. Evidence class semantics
- symulacja, fixture, runtime capture i lane binarny maja jawna klase dowodu.

7. Version-control semantics
- `Repository` i `ChangeSet` sa sprawdzane pod katem traceability, policy alignment i integrity commit scope.

8. Verification planning semantics
- `VerificationPolicy` musi mapowac lane do Feature/ChangeSet/ReleaseBundle zgodnie z profilem projektu.

9. Data and environment semantics
- `DataSchema`, `Migration` i `EnvironmentTarget` musza byc sprawdzane tam, gdzie aktywne sa `persistent-data` lub `deployable-runtime`.

10. Runtime scheduling semantics
- po jednym evencie moze powstac wiele OP/control, ale scheduler musi deterministycznie wybrac jeden `primary active step`.
- create wymagany przez trigger jest obowiazkowy, ale create nie daje auto-transition bez jawnego scheduler selection albo explicit exec step.
- kroki state-changing na tym samym scope nie moga biec wspolbieznie.

## 2. Minimalne metody walidacji

- structural checks,
- state-machine replay,
- contract tests dla request/response/tool contracts,
- semantic assertions na runtime evidence,
- negative tests dla authz, invalidation, reject/defer, retry, recovery controls,
- scheduling assertions dla `primary active step`, `pending/blocked/waiting` i scope lock conflict,
- traceability assertions dla Repository/ChangeSet i VerificationPolicy,
- compatibility assertions dla DataSchema/Migration/EnvironmentTarget,
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
