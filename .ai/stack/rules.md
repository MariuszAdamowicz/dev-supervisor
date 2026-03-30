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

## Reguła Szumu Metadanych Xcode

- Przed każdym commitem uruchom pełną walidację: `./Scripts/build.sh && ./Scripts/test.sh && ./Scripts/lint.sh`.
- Jeżeli po walidacji pozostają wyłącznie techniczne zmiany metadanych Xcode (np. `DevSupervisor.xcodeproj/project.pbxproj` z różnicą `lastKnownFileType` dla `.xctestplan`, `xcuserdata`, `*.xcuserstate`), traktuj je jako szum środowiskowy.
- Szum środowiskowy nie jest zmianą feature i nie powinien być commitowany.
- `project.pbxproj` commituj tylko wtedy, gdy zmiana jest wymagana merytorycznie (np. dodanie/konfiguracja targetu, planu testów, ustawień buildu) i wynika bezpośrednio z zakresu feature.
