# Notes — Gate Prompt Persistence

## Decyzje implementacyjne
- Dodano izolowany moduł `GatePromptPersistenceFileSystem` niezależny od logiki gate'ów.
- Zapis jest uruchamiany automatycznie tylko po sukcesie gate.
- Użyto katalogów `.ai/gates` i `State/gates` zależnie od aktywnego profilu storage.

## Ryzyka / dług techniczny
- Profil `sqlbase` jest na razie realizowany przez trwały zapis plikowy w `State/gates`, bez schematu SQL.
- Brak dedykowanego ekranu historii artefaktów gate w UI.
