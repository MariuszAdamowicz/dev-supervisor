# Śledzalność

- Reguła: Operacja generowania promptu PRD musi być blokowana lub jawnie odrzucana, gdy nie wybrano aktywnego projektu.
  - Pokryte przez: Scenariusz 2 "Odrzucenie generowania promptu PRD bez aktywnego projektu"

- Reguła: Prompt PRD musi być generowany wyłącznie dla idei należącej do aktywnego projektu.
  - Pokryte przez: Scenariusz 1 "Wygenerowanie promptu PRD dla idei z aktywnego projektu"
  - Pokryte przez: Scenariusz 4 "Odrzucenie generowania promptu dla idei spoza aktywnego projektu"

- Reguła: Operacja musi zwracać jawny błąd, gdy wskazana idea nie istnieje lub nie jest dostępna w zakresie aktywnego projektu.
  - Pokryte przez: Scenariusz 3 "Odrzucenie generowania promptu dla nieistniejącej idei"
  - Pokryte przez: Scenariusz 4 "Odrzucenie generowania promptu dla idei spoza aktywnego projektu"

- Reguła: Prompt musi zawierać minimalny, relewantny kontekst zgodny z zasadą minimal context.
  - Pokryte przez: Scenariusz 5 "Prompt zawiera minimalny i relewantny kontekst"

- Reguła: Operacja musi zwracać jawny błąd, gdy wymagane źródła kontekstu promptu są niedostępne.
  - Pokryte przez: Scenariusz 6 "Odrzucenie generowania promptu przy brakujących źródłach kontekstu"

- Reguła: Prompt musi być deterministyczny i strukturalnie zgodny z wymaganym szablonem `IDEA -> PRD`.
  - Pokryte przez: Scenariusz 7 "Deterministyczność wygenerowanego promptu"

- Reguła: Wygenerowanie promptu PRD musi być wyłącznie operacją inicjowaną przez operatora; brak automatycznych uruchomień.
  - Pokryte przez: Scenariusz 8 "Brak automatycznego wykonywania promptu przez aplikację"

- Reguła: Aplikacja nie wykonuje promptu u dostawcy AI; operator odpowiada za jego wykonanie.
  - Pokryte przez: Scenariusz 8 "Brak automatycznego wykonywania promptu przez aplikację"

- Reguła: Operacja musi jawnie wskazywać źródłową ideę (tożsamość idei) i aktywny projekt (tożsamość projektu).
  - Pokryte przez: Scenariusz 9 "Jawna identyfikowalność idei i projektu w wyniku"

- Reguła: Funkcja nie może modyfikować treści idei ani statusów idei jako efektu ubocznego samego generowania promptu.
  - Pokryte przez: Scenariusz 10 "Brak efektów ubocznych na stanie idei podczas generowania promptu"

- Reguła: Operacja musi pozostawiać ślad operacyjny powiązany z ideą i projektem.
  - Pokryte przez: Scenariusz 11 "Rejestrowanie śladu operacyjnego dla wygenerowania promptu"
