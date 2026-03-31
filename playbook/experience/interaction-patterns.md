# Interaction Patterns

## Pattern 1: Next Best Action
UI zawsze pokazuje jedną główną akcję "co dalej".

## Pattern 2: Gate Card
Każdy krok pipeline ma kartę gate:
- input artifact
- output artifact
- status: pending/ready/accepted/invalidated
- akcje: generate, review, accept, regenerate

## Pattern 3: Review Before Accept
Operator zawsze akceptuje artefakt jawnie.
Akceptacja zapisuje fingerprint artefaktu.

## Pattern 4: Invalidation Warning
Przy zmianie upstream UI pokazuje listę gate, które zostaną unieważnione.

## Pattern 5: Deterministic Audit Trail
Każda akcja operatora jest logowana:
- kto
- kiedy
- jaka akcja
- jaki artefakt/fingerprint
