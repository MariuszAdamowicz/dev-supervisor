- Bez force unwrap
- Bez globalnego mutowalnego stanu
- Funkcje < 50 linii, gdy to praktyczne
- Preferuj typy wartości
- Preferuj jawne typy domenowe zamiast surowych słowników
- Nie modyfikuj niepowiązanych plików

## Reguła Typów Domenowych

- Typy domenowe nie mogą pozostawać wewnątrz plików testowych.
- Testy mogą wprowadzać tymczasowe typy zastępcze wyłącznie do wyrażenia zachowania.
- Przed implementacją lub w jej trakcie wszystkie typy domenowe muszą zostać wyekstrahowane do Core/Domain.
- Kod produkcyjny musi być pojedynczym źródłem prawdy dla modeli domenowych.
- Testy muszą zależeć od typów domenowych, a nie je definiować.

## Reguła Granicy Testów

- Testy definiują zachowanie, a nie architekturę.
- Testy mogą definiować minimalne kontrakty do wyrażenia oczekiwań.
- Ostateczna architektura musi być wyprowadzona podczas implementacji, a nie z góry usztywniona w testach.
