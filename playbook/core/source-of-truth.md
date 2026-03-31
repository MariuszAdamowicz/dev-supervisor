## Source of Truth (OP-aligned)

Cel:
Playbook Layer nie definiuje semantyki procesu. Semantyka procesu jest kanoniczna w OP Layer.

Kanoniczne definicje OP:
- layers/op/object-catalog.md
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
- release/deployment/rollback status (w stanie OP, nie w notatkach)

Quality and Audit:
- quality signals (pass/fail) i decyzje gate
- ProcessEvent jako audit trail

## Zasada priorytetu

Dla implementacji zachowania:
PRD < BDD < TESTY

Dla procesu:
state machine + trigger rules + gate decisions z OP Layer wygrywaja nad opisami operacyjnymi.

## Czego nie traktowac jako source of truth

- tasks.md (plan)
- notes.md (kontekst)
- traceability.md (mapowanie)

Te artefakty sa pomocnicze i musza byc spojne z OP i testami.

## Zasada anty-duplikacyjna

Nie duplikuj definicji procesu w kilku miejscach.
- Lifecycle, trigger i gate value definiujemy tylko w OP Layer.
- Playbook Layer zawiera mapowanie krokow operatora na OP.
