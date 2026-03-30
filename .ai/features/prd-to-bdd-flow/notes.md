# Notes — PRD to BDD Flow

## Decyzje implementacyjne
- Krok `PRD -> BDD` dodany jako niezależny gate operatora.
- Użyto prostego kontraktu in-memory do domknięcia logiki i testów.
- Pole PRD w UI może być podane ręcznie; gdy puste, używany jest ostatni wynik z kroku `FEATURES -> PRD`.

## Ryzyka / dług techniczny
- Brak trwałego zapisu wygenerowanego promptu BDD do struktury projektu.
- Brak dedykowanego modelu zatwierdzenia PRD przez operatora przed uruchomieniem gate.
