# Notes — Tests to Implementation Flow

## Decyzje implementacyjne
- Krok `TESTY -> IMPLEMENTACJA` dodany jako niezależny gate operatora.
- Użyto prostego kontraktu in-memory do domknięcia logiki i testów.
- Pole testów w UI może być podane ręcznie; gdy puste, używany jest ostatni wynik z kroku `BDD -> TESTY`.

## Ryzyka / dług techniczny
- Brak trwałego zapisu wygenerowanego promptu implementacyjnego do struktury projektu.
- Brak dedykowanego modelu zatwierdzenia dokumentu testów przez operatora przed uruchomieniem gate.
