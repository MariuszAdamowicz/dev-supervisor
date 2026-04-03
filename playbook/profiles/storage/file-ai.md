## Storage Profile: file-ai

Cel:
- przechowywac runtime i artefakty procesu bezposrednio w plikach repo
- traktowac folder .ai/ jako glowny nosnik runtime

## Model danych
- source-of-truth dla artefaktow runtime: .ai/*
- stan OP moze byc wyliczany z plikow lub trzymany pomocniczo w pamieci

## Zakres
- .ai/prd/*
- .ai/features/<feature>/*
- .ai/ideas.md
- .ai/stack/*
- .ai/ux/*

## Reguly
- kazda zmiana procesu aktualizuje odpowiednie pliki .ai
- decyzje gate i audit sa zapisywane w modelu OP (GateDecision + ProcessEvent)
- notes/tasks moga zawierac kontekst pomocniczy, ale nie zastepuja audit trail
- transport promptow moze byc zautomatyzowany (np. MCP), ale kontrola job lifecycle AI nalezy do DS
- zapis artefaktow pozostaje audytowalny w repo

## Zalety
- prosty audyt przez git
- niski prog wejscia
- brak zaleznosci od silnika DB

## Ograniczenia
- trudniejsze query przekrojowe (cross-feature/cross-project)
- wieksza ilosc recznych aktualizacji przy rozbudowanym runtime

## Runtime contract (file-ai-runtime/v1)

Cel:
- zapewnic deterministyczny i audytowalny zapis OP runtime
- wymusic audit contract i no-silent-transitions

### Struktura runtime

`.ai/runtime/v1/`:
- `ops/<op_id>/versions/<op_version>.json` (immutable snapshot OP)
- `ops/<op_id>/events.ndjson` (append-only log ProcessEvent)
- `ops/<op_id>/gates.ndjson` (append-only log GateDecision)

Reguly:
- `op_version` to dodatnia liczba calkowita i rosnacy numer rewizji OP.
- `events.ndjson` i `gates.ndjson` dopuszczaja tylko dopisywanie nowych rekordow.
- istniejacy snapshot `versions/<op_version>.json` nie moze byc nadpisany.

### Kontrakt rekordu: OP snapshot

Wymagane pola:
- `schema_version` = `file-ai-runtime/v1`
- `entity` = `op_instance`
- `op_id`
- `op_type`
- `op_version`
- `state`
- `owner`
- `created_at` (RFC3339 UTC)
- `updated_at` (RFC3339 UTC)
- `links` (lista relacji)
- `tags`
- `last_event_id`

Opcjonalne pola:
- `payload` (dane specyficzne typu OP)

### Kontrakt rekordu: GateDecision (NDJSON)

Wymagane pola:
- `schema_version` = `file-ai-runtime/v1`
- `entity` = `gate_decision`
- `decision_id`
- `op_id`
- `gate_type`
- `decision` (`approve | request_changes | defer | reject`)
- `reason`
- `actor`
- `ts` (RFC3339 UTC)
- `idempotency_key`

Opcjonalne pola:
- `based_on_event_id`
- `context_hash` (sha256)

### Kontrakt rekordu: ProcessEvent (NDJSON)

Wymagane pola:
- `schema_version` = `file-ai-runtime/v1`
- `entity` = `process_event`
- `event_id`
- `op_id`
- `event_type`
- `payload_hash` (sha256)
- `actor`
- `ts` (RFC3339 UTC)
- `idempotency_key`

Opcjonalne pola:
- `op_type`
- `from_state`
- `to_state`
- `gate_decision_id`
- `trigger_rule_id`
- `causation_event_id`

### Idempotency i konflikt zapisu

- kazdy zapis `ProcessEvent` i `GateDecision` MUSI miec `idempotency_key`.
- jesli istnieje rekord z tym samym `idempotency_key` i tym samym payloadem, zapis jest uznany za idempotentny (bez duplikatu).
- ten sam `idempotency_key` z innym payloadem to blad konfliktu i transition jest invalid.

### Obowiazkowe zapisy per transition

1. Proba transition:
- MUSI powstac `ProcessEvent` z `event_type=transition.attempted`.

2. Guard fail:
- MUSI powstac `ProcessEvent` z `event_type=transition.blocked`.
- NIE wolno tworzyc nowej wersji OP.

3. Transition gate-required:
- MUSI powstac rekord `GateDecision`.
- MUSI powstac `ProcessEvent` z `event_type=gate.recorded`.
- brak ktoregokolwiek z tych rekordow uniewaznia transition.

4. Transition committed:
- MUSI powstac `ProcessEvent` z `event_type=transition.committed`.
- MUSI powstac nowy snapshot `versions/<op_version+1>.json`.
- nowy snapshot MUSI ustawic `last_event_id` na event commit.

Definicja gate-required:
- transition jest gate-required, gdy binding (`tooling/bindings.md`) wymaga `decide_gate` i `operator-ui`.

### Przykład: Feature.implemented -> Feature.stabilized

Minimalna sekwencja:
1. `events.ndjson`: `transition.attempted` (`from_state=implemented`, `to_state=stabilized`).
2. `gates.ndjson`: `GateDecision` z `decision=approve`.
3. `events.ndjson`: `gate.recorded` z `gate_decision_id`.
4. `versions/<n+1>.json`: snapshot Feature ze `state=stabilized`.
5. `events.ndjson`: `transition.committed` z referencja do gate.

### Kompatybilnosc wersji

- `file-ai-runtime/v1` dopuszcza tylko zmiany kompatybilne wstecz (nowe pola opcjonalne).
- zmiana breaking wymaga nowej wersji kontraktu i nowego katalogu runtime, np. `.ai/runtime/v2/`.
