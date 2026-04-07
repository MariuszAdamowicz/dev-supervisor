# OP CRUD Contract

Cel:
ustalic jednoznaczny kontrakt tworzenia, odczytu, modyfikacji i usuwania OP oraz ich relacji.

## 1. Create

- kazdy entrypoint deklaruje jawnie, jakie OP moze utworzyc.
- create wymaga: `op_type`, parent linkage, owner, initial state, source artifact lub source event.
- create bez parent linkage jest nielegalne, z wyjatkiem `Project`.

## 2. Read

- runtime musi utrzymywac indeks aktywnych OP i ich relacji.
- projection operatora pokazuje task-first summary, a nie surowe ids jako primary UI.
- audit/debug moze czytac pelny graph, event log i gate log.

## 3. Update

- update OP zachodzi tylko przez legal transition albo audytowalny update artefaktu niezmieniajacy state.
- update musi zapisac:
  - actor,
  - change reason,
  - trace do review package lub prompt task,
  - invalidation scope dla downstream OP.
- kazda zmiana guardow lub linkow wymaga ponownej walidacji invariantow grafu.

## 4. Remove

- hard delete OP po utworzeniu ProcessEvent jest zabronione.
- usuniecie semantyczne zachodzi przez stany terminalne: deprecated, revoked, dropped, cancelled, archived, closed.
- remove wymaga tombstone metadata:
  - who,
  - why,
  - replacement_ref lub brak replacement z reason,
  - impacted_children.

## 5. Graph integrity

- brak osieroconych OP poza `Project`.
- brak dangling links.
- kazdy child zna parent, a parent ma mozliwosc projekcji child summary.
- `Component` i `Dependency` wymagaja kontroli kierunku zaleznosci i no-cycle.
- `UseCase` / `PortContract` / `Component` musza byc wyszukiwalne z `Feature`.

## 6. Runtime artefakty

Minimalny runtime po bootstrapie musi miec:
- `op-index.json` lub rownowazny indeks OP,
- jawny parent linkage,
- indeks terminal/deprecated OP,
- audyt create/update/remove.

## 7. Zrodla praktyk

Punkty odniesienia:
- PostgreSQL constraints: integralnosc i twarde blokowanie nielegalnych zapisow.
- Neo4j constraints: jawne ograniczenia dla grafu i identyfikatorow.
- OWASP logging guidance: audyt create/update/delete bez cichych zmian.

Linki:
- https://www.postgresql.org/docs/current/ddl-constraints.html
- https://neo4j.com/docs/cypher-manual/current/schema/constraints/create-constraints/
- https://cheatsheetseries.owasp.org/cheatsheets/Logging_Cheat_Sheet.html
