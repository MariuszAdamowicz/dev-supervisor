## Source of Truth (OP-aligned)

Cel:
Playbook Layer nie definiuje semantyki procesu. Semantyka procesu jest kanoniczna w OP Layer.

Kanoniczne definicje OP:
- layers/op/object-catalog.md
- layers/op/authz-contracts.md
- layers/op/data-contracts.md
- layers/op/decision-contracts.md
- layers/op/delivery-contracts.md
- layers/op/environment-contracts.md
- layers/op/exception-contracts.md
- layers/op/glossary-contracts.md
- layers/op/job-contracts.md
- layers/op/relation-contracts.md
- layers/op/risk-contracts.md
- layers/op/recovery-contracts.md
- layers/op/scheduler-contracts.md
- layers/op/verification-contracts.md
- layers/op/state-machines.md
- layers/op/trigger-rules.md

## Zrodla prawdy per typ OP

Project:
- overview.md (opis produktu)
- constraints.md (ograniczenia)
- glossary.md (slownik)

Feature:
- feature/prd.md (kontrakt feature)
- feature/bdd.md (zachowanie)
- testy (wykonywalna specyfikacja)

Delivery:
- release/deployment run status + recovery controls (w stanie runtime, nie w notatkach)

Quality and Audit:
- quality evidence records (pass/fail) i decyzje gate
- ProcessEventRecord jako audit trail

## Zasada priorytetu

Dla implementacji zachowania:
PRD < BDD < TESTY

Dla procesu:
authz contracts + data contracts + decision contracts + delivery contracts + environment contracts + exception contracts + glossary contracts + job contracts + relation contracts + risk contracts + recovery contracts + scheduler contracts + verification contracts + state machine + trigger rules + gate decisions z OP Layer wygrywaja nad opisami operacyjnymi.

## Czego nie traktowac jako source of truth

- tasks.md (plan)
- notes.md (kontekst)
- traceability.md (mapowanie)

Te artefakty sa pomocnicze i musza byc spojne z OP i testami.

## Zasada anty-duplikacyjna

Nie duplikuj definicji procesu w kilku miejscach.
- Lifecycle, trigger i gate value definiujemy tylko w OP Layer.
- Playbook Layer zawiera mapowanie krokow operatora na OP.
