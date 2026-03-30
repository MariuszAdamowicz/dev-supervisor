# Notes — Idea to Features Flow

## Decyzje implementacyjne
- Utrzymano implementację in-memory, aby domknąć logikę i testy procesu przed podłączeniem persystencji projektowej.
- Dodano twardy warunek statusu `selected` jako gate dla kroku `IDEA -> FEATURES`.
- Lista `FeatureCandidate` jest deterministycznie wyprowadzana z idei przez stały schemat trzech funkcjonalności.
- Kontekst minimalny ograniczono do `overview`, `constraints`, `glossary`, zgodnie z modelem minimal context.

## Ryzyka / dług techniczny
- Brak trwałego zapisu wygenerowanego feature-setu do projektu (obecnie tylko wynik operacji).
- Brak mechanizmu potwierdzania feature-setu przez operatora przed przejściem do `FEATURES -> PRD`.
- Integracja z UI jest etapowa i nie zastępuje docelowego workflow opartego o model projektu.
