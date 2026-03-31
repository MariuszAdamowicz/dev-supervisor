# UX Validation

## Kryteria jakości UX
- Operator bez znajomości kodu potrafi wykonać cały flow krok po kroku.
- UI nie pokazuje zbędnych paneli.
- Brak akcji, które kończą się "silent failure".
- Każdy stan blokady ma explicit reason.

## Testy UX (obowiązkowe)
1. Visibility tests
2. State transition tests
3. Gate availability tests
4. Invalidation tests
5. Navigation continuity tests

## Definition of Done (UX)
- Każdy nowy krok pipeline ma:
  - definicję stanu
  - reguły widoczności
  - reguły dostępności akcji
  - testy przejść i blokad
