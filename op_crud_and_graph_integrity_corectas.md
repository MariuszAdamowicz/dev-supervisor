# OP CRUD And Graph Integrity Correctas

## Stan obecny przed zmianami

`object-catalog.md` wspominal CRUD policy i invarianty grafu, ale brakowalo spójnego kontraktu wykonawczego i walidacyjnego.
Najwieksze luki:
- brak twardego zakazu hard delete po audycie,
- brak wymuszonego `op-index`,
- brak jednoznacznych tombstone rules,
- za slaba kontrola parent linkage i dangling links.

## CRUD dla punktu

Create:
- OP mogly powstawac bez gwarancji indexowania i linkage.

Read:
- brak twardego wymagania indeksu i sposobu czytania graph summary przez operatora.

Update:
- update linkow nie wymuszal rewalidacji grafu.

Remove:
- remove byl bardziej konceptem stanu terminalnego niz wykonawczym kontraktem z tombstone metadata.

## Praktyki zewnetrzne

- PostgreSQL constraints: integralnosc relacyjna.
- Neo4j constraints: jawne ograniczenia grafowe.
- OWASP logging: audyt create/update/delete.

Linki:
- https://www.postgresql.org/docs/current/ddl-constraints.html
- https://neo4j.com/docs/cypher-manual/current/schema/constraints/create-constraints/
- https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html

## Plan zmian

1. Dodac osobny kontrakt CRUD dla OP i grafu.
2. Wymusic `op-index.json`, parent linkage i tombstone.
3. Dodac validation contract dla CRUD integrity.
4. Dopisac invariants do katalogu OP i workflow.

## Czy plan domyka problem

Tak. Problem nie lezal w braku pojedynczej reguly, tylko w rozproszeniu i niewymuszaniu. Po korekcie CRUD i graph integrity maja wspolny kontrakt.

## Wprowadzone zmiany

- dodany `playbook/workflow/op-crud-contract.md`,
- `playbook/runtime/playbook-exec.yaml` ma `crud_contract` oraz wymaga `op-index.json`,
- `playbook/validation/playbook-contracts.md` ma `CRUD integrity contract`,
- `playbook/layers/op/object-catalog.md` wzmacnia invarianty remove/link integrity,
- `playbook/workflow/daily-workflow.md` wymaga odczytu parent linkage i impacted children.

## Podsumowanie

CRUD OP przestal byc ukrytym zalozeniem. Jest teraz kontraktem, ktory obejmuje create, read, update, remove i spojnosc calego grafu OP.
