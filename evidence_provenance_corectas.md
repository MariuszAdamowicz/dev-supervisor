# Evidence Provenance Correctas

## Stan obecny przed zmianami

Playbook zbyt slabo odroznial:
- dry-run,
- fixture,
- runtime evidence,
- build/test/lint na prawdziwej aplikacji.

To powodowalo ryzyko falszywego PASS i mylenia symulacji z dowodem wykonania.

## CRUD dla punktu

Create:
- evidence powstawalo bez jednoznacznej klasy i bez minimalnego provenance metadata.

Read:
- czytelnik raportu nie wiedzial, czy patrzy na fixture czy real runtime.

Update:
- raporty mogly byc aktualizowane bez utrzymania pochodzenia dowodu.

Remove:
- brak jasnej polityki retencji nie jest jeszcze w pelni rozwiazany, ale provenance zostalo przynajmniej ustrukturyzowane.

## Praktyki zewnetrzne

- SLSA provenance: build provenance i atrybuty pochodzenia.
- GitHub artifact attestations: attestation dla artefaktow i buildow.

Linki:
- https://slsa.dev/spec/v1.0/provenance
- https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations

## Plan zmian

1. Dodac klasy evidence.
2. Dodac wymagane provenance metadata.
3. Oznaczyc dry-run i fixture jako syntetyczne.
4. Zmienic globalny PASS tak, aby wymagac runtime-capture.

## Czy plan domyka problem

Tak dla kontraktu i raportowania. Nadal potrzeba realnych runtime captures, ale playbook juz nie pozwala pomylic ich z fixture.

## Wprowadzone zmiany

- dodany `playbook/verification/evidence-provenance.md`,
- `playbook/runtime/playbook-exec.yaml` ma `evidence_contract`,
- `playbook/verification/scripts/exec-dry-run.sh` emituje `EVIDENCE_CLASS=synthetic-contract-simulation`,
- `playbook/verification/scripts/e2e-fixture-run.sh` emituje `EVIDENCE_CLASS=fixture-simulation`,
- `playbook/verification/scripts/verify-all.sh` raportuje `partial`, gdy brak `runtime-capture`.

## Podsumowanie

Najwiekszy zysk jest epistemiczny: po poprawce wiemy, co jest tylko symulacja, a co rzeczywistym dowodem wykonania procesu.
