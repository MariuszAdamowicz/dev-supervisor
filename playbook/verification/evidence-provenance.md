# Evidence Provenance

Cel:
odroznic dowod syntetyczny od dowodu z realnego uruchomienia i wymagac jawnego pochodzenia evidence.

## 1. Klasy dowodu

1. `synthetic-contract-simulation`
- dry-run, preview, mock tool results.

2. `fixture-simulation`
- wygenerowany runtime fixture z pliku scenariusza.

3. `runtime-capture`
- dowod z realnego uruchomienia silnika lub aplikacji.

4. `binary-quality-lane`
- build/test/lint wykonane na prawdziwym kodzie aplikacji.

## 2. Metadata wymagane dla kazdego dowodu

- evidence_id,
- evidence_class,
- source_ref,
- executor_ref,
- started_at,
- finished_at,
- actor_or_system,
- environment,
- subject_hash lub artifact_hash,
- replayable_input_ref,
- attestation_ref jesli dotyczy.

## 3. Zasady PASS/FAIL

- `synthetic-contract-simulation` i `fixture-simulation` nigdy same nie wystarczaja do globalnego PASS.
- globalny PASS wymaga co najmniej jednego `runtime-capture` oraz jednego `binary-quality-lane`.
- raport musi rozdzielac evidence syntetyczne od evidence produkowanego przez runtime.

## 4. Attestation

Jesli dowod dotyczy buildu, release albo runtime capture, wymagane sa:
- provenance statement,
- hash artefaktu,
- ref do commita,
- ref do workflow/job,
- ref do operator decision jesli gate byl ludzki.

## 5. Zrodla praktyk

Punkty odniesienia:
- SLSA provenance spec.
- GitHub artifact attestations.

Linki:
- https://slsa.dev/spec/v1.0/provenance
- https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations
