## Layered Monolith

## Model
- prezentacja (UI/API)
- application/service layer
- domain layer
- infrastructure layer

## Reguły
- zależności tylko w dół warstw
- brak bezpośrednich importów z UI do infrastructure
- logika biznesowa pozostaje w domain/application
