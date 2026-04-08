# Exception Contracts (kanoniczne)

Cel:
opisac mutowalne przypadki wyjatkow i incydentow wykonawczych,
ktore nie sa samodzielnymi OP, ale maja jawny status,
resolution path, blocker projection i audit.

Exception control nie jest:
- OP z pelnym lifecycle produktu,
- system recordem append-only,
- ukrytym logiem bledu bez skutkow downstream.

Exception control jest:
- mutowalnym przypadkiem bledu procesu, runtime albo danych wejsciowych,
- bytem queryable po scope, severity i statusie,
- nosnikiem decyzji `handle|escalate` oraz warunkiem recovery.

## Kontrakt wspolny exception control

Kazdy exception control ma pola:
- `exception_id`
- `subject_ref`
- `exception_class`
- `severity`
- `status`
- `owner`
- `created_at`
- `updated_at`
- `reason`

Pola opcjonalne:
- `compensation_required`
- `recovery_refs`
- `evidence_refs`
- `replacement_ref`

Reguly:
- exception control musi byc zapisany w runtime index i reverse lookup po `subject_ref`,
- mutacja exception control wymaga `ProcessEventRecord`,
- brak reverse lookup uniewaznia projection blockerow i recovery scope,
- exception control nie moze byc ukryty przed operatorem, gdy ma status `escalated` albo `severity=high|critical`.

## ExceptionCase

Rola:
opisuje pojedynczy przypadek bledu procesu lub wykonania,
ktory wymaga klasyfikacji, jawnej obslugi albo eskalacji.

Punkty odniesienia:
- Camunda Incidents: problem wykonania procesu jest stanem runtime wymagajacym interwencji operatora i jawnego `resolve`, a nie bytem produktu.
- Microsoft Workflow Foundation: obsluga wyjatku zachodzi w trakcie wykonania, a kompensacja jest osobnym mechanizmem recovery po wykonanym kroku.

### Statusy

- `detected`: blad zostal wykryty i czeka na klasyfikacje.
- `classified`: blad ma juz okreslony typ/severity i czeka na resolution path.
- `handled`: problem zostal obsluzony i nie blokuje juz scope.
- `escalated`: problem wymaga decyzji operatora, retry albo recovery control.

### CRUD semantics

Create:
- tworz `ExceptionCase`, gdy authz, quality, runtime albo dane wejsciowe blokuja legalny progres,
- create wymaga `subject_ref`, `exception_class`, `severity` i wstepnego `reason`.

Read:
- runtime musi umiec pytac:
  - `jakie ExceptionCase sa otwarte dla danego scope`,
  - `czy istnieje critical ExceptionCase blokujacy release albo feature closure`,
  - `jakie ExceptionCase wymagaja compensation albo retry`.

Update:
- dozwolone sa tylko status changes:
  - `detected -> classified`
  - `classified -> handled | escalated`
  - `escalated -> classified`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia blocker projection dla impacted scope.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `handled`,
- `handled` wymaga jawnego reason i zachowania trace do resolution path.

### Propagation

- `detected`:
  - blokuje automatyczne domkniecie scope do czasu klasyfikacji.
- `classified`:
  - wymaga decyzji `handle` albo `escalate`,
  - moze wymagac `CompensationAction`, `RollbackAction` albo retry.
- `handled`:
  - odblokowuje scope, jesli nie ma otwartych recovery controls ani nowych exception cases.
- `escalated`:
  - blokuje delivery albo closure target scope do czasu jawnej decyzji/recovery.

## Invariants

- `ExceptionCase` musi wskazywac `subject_ref`, `exception_class`, `severity` i `reason`,
- `classified` bez jawnej decyzji `handle|escalate` jest invalid,
- `escalated` bez blocker projection dla impacted scope jest invalid,
- `compensation_required=true` bez aktywnego lub completed `CompensationAction` jest invalid,
- exception control nie moze zniknac z indeksu po pojawieniu sie audytu.

## Zrodla praktyk

Linki:
- https://docs.camunda.io/docs/components/concepts/incidents/
- https://learn.microsoft.com/en-us/dotnet/framework/windows-workflow-foundation/exceptions
