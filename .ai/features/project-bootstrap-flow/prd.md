# Funkcja: Project Bootstrap Flow

## Cel
Zapewnić deterministyczny onboarding nowego projektu oraz inspekcję istniejącego projektu, tak aby operator mógł rozpocząć pracę zgodnie z playbookiem bez ręcznego tworzenia pełnej struktury folderów i plików.

## Wejścia
- Nazwa projektu podana przez operatora.
- Ścieżka katalogu głównego na projekty.
- Wybrany profil storage (`file-ai` lub `sqlbase`).
- Decyzja operatora, czy inicjalizować repozytorium git.
- (Inspekcja) ścieżka istniejącego projektu.

## Wyjścia
- Utworzony katalog projektu ze strukturą bootstrapową.
- Utworzony baseline `.ai` (`overview`, `constraints`, `glossary`, stack rules, profile manifest).
- Utworzone skrypty `Scripts/build.sh`, `Scripts/test.sh`, `Scripts/lint.sh`.
- Jawny wynik operacji (sukces albo jawna przyczyna błędu).
- Raport inspekcji istniejącego projektu (obecność `.ai`, `Scripts`, git, wykryty storage profile).

## Reguły
- Bootstrap jest inicjowany wyłącznie przez operatora.
- Nazwa projektu i katalog główny muszą być niepuste.
- Jeśli docelowy katalog projektu już istnieje i nie jest pusty, operacja bootstrap musi zostać jawnie odrzucona.
- Profil storage musi być jawny i zapisany w `.ai/project-profile.json`.
- Dla `sqlbase` musi zostać utworzony lokalny artefakt bazy (`State/supervisor.sqlite3`).
- Aplikacja nie wykonuje ukrytych zmian poza zakresem bootstrapu.
- Inspekcja istniejącego projektu nie modyfikuje stanu projektu.

## Przypadki brzegowe
- Pusta nazwa projektu.
- Pusta ścieżka katalogu głównego.
- Kolizja z istniejącym niepustym katalogiem projektu.
- Inspekcja ścieżki, która nie istnieje lub nie jest katalogiem.
- Inspekcja projektu bez `.ai` lub bez `Scripts`.

## Poza zakresem
- Automatyczne uruchamianie promptów AI.
- Automatyczne generowanie PRD/BDD dla pierwszego feature.
- Pełne tworzenie i konfiguracja natywnego projektu Xcode nowego repo (szablony stack-specific pozostają po stronie dalszych kroków setupu).
