# OP Layer

Rola:
- kanoniczny model procesu niezalezny od konkretnego projektu.

Zakres:
- typy OP,
- maszyny stanow,
- triggery,
- gate effects,
- guard conditions,
- invariants,
- retry/idempotency/compensation,
- audit event model.

Kanoniczne pliki:
- ./op/object-catalog.md
- ./op/state-machines.md
- ./op/trigger-rules.md

Co ta warstwa MUSI dostarczyc:
- jednoznaczny lifecycle dla kazdego OP,
- formalny kontrakt przejsc stanu,
- reguly decyzyjne dla gate,
- audytowalnosc zdarzen.

Czego ta warstwa NIE robi:
- nie definiuje stacka technologicznego,
- nie narzuca UI konkretnej aplikacji,
- nie przechowuje danych konkretnego projektu.
