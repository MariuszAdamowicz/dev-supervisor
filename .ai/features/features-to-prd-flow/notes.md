# Notes — Features to PRD Flow

## Decyzje implementacyjne
- Krok `FEATURES -> PRD` dodany jako niezależny gate operatora.
- Użyto prostego kontraktu in-memory do domknięcia logiki i testów.
- Prompt jest budowany deterministycznie na podstawie listy `FeatureCandidate`.

## Ryzyka / dług techniczny
- Brak trwałego zapisu promptu do struktury projektu.
- Brak zatwierdzania feature-setu przed uruchomieniem gate w UI.
