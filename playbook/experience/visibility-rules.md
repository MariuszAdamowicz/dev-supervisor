# Visibility Rules

## Zasady
1. Nie pokazuj paneli kroków przyszłych.
2. Nie pokazuj paneli kroków nieosiągalnych.
3. Dla kroku bieżącego pokaż:
   - wymagane wejścia
   - CTA wykonania
   - kryterium ukończenia kroku
4. Dla kroku ukończonego pokaż tylko skrót + możliwość podglądu.

## Dostępność akcji
Akcja jest aktywna tylko gdy:
- stan projektu dopuszcza akcję
- istnieje wymagany artefakt wejściowy
- gate upstream ma status `accepted`

## Komunikaty blokad
Dla każdej blokady UI zwraca explicit reason:
- brak aktywnego projektu
- brak aktywnej idei
- brak wymaganego artefaktu
- gate niezaakceptowany
- gate unieważniony przez zmianę upstream
