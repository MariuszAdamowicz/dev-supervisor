# Deterministic Replay

Cel:
udowodnic, ze dla tych samych danych wejsciowych silnik procesu daje te same wyniki.

## Zasada
Ten sam zestaw:
- initial OP states,
- event sequence,
- gate decisions,
- retry/timeouts,
musi dawac identyczny:
- final OP graph,
- ProcessEventRecord log,
- GateDecisionRecord log.

Replay jest dowodem klasy `synthetic-contract-simulation`.
Nie moze samodzielnie dawac globalnego PASS.

## Scenariusze referencyjne
1. Feature happy path: `drafted -> done`.
2. Feature rework path: `implemented -> test-ready -> implemented -> stabilized`.
3. PromptTask job control defer + timeout + retry.
4. ReleaseBundle approve -> deployment fail -> rollback succeed -> release re-approve.
5. RiskEntry escalated blokuje release do czasu resolution.
6. Authz denied blokuje transition i tworzy ExceptionCase(authz).
7. CRUD tombstone po deprecacji/revoke/drop bez utraty linkow parent/child.

## Procedura
1. Zapisz snapshot startowy runtime.
2. Odtworz scenariusz A i zapisz wynik.
3. Odtworz scenariusz A drugi raz na tym samym wejsciu.
4. Porownaj hash final state + hash event log.
5. Powtorz dla scenariuszy B-F.

## Kryterium PASS
Kazdy scenariusz ma identyczny wynik w powtorzeniu (hash match = true) i ten sam evidence class/provenance metadata.
