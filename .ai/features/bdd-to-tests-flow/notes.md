# Notes — BDD to Tests Flow

## Decyzje implementacyjne
- Krok `BDD -> TESTY` dodany jako niezależny gate operatora.
- Użyto prostego kontraktu in-memory do domknięcia logiki i testów.
- Pole BDD w UI może być podane ręcznie; gdy puste, używany jest ostatni wynik z kroku `PRD -> BDD`.

## Ryzyka / dług techniczny
- Brak trwałego zapisu wygenerowanego promptu testów do struktury projektu.
- Brak dedykowanego modelu zatwierdzenia BDD przez operatora przed uruchomieniem gate.
