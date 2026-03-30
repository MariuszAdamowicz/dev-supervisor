# Funkcja: Idea to PRD Flow

## Cel
Zapewnić deterministyczny i jawny workflow przejścia od wybranej idei do wygenerowanego promptu PRD, tak aby operator mógł uruchomić krok `IDEA -> PRD` bez utraty kontekstu projektu i bez automatycznego wykonywania promptu przez aplikację.

## Wejścia
- Aktywny projekt wybrany przez operatora.
- Idea z rejestru idei aktywnego projektu (zwykle oznaczona jako `selected`).
- Jawne działanie operatora uruchamiające generowanie promptu PRD.
- Kontekst minimalny wymagany do zbudowania promptu (PRD constraints, glossary, overview, reguły stacka).
- Opcjonalne parametry operatora dla promptu (np. poziom szczegółowości, dodatkowe ograniczenia).

## Wyjścia
- Wygenerowany tekst promptu `IDEA -> PRD` gotowy do użycia przez operatora.
- Jawna informacja, której idei i którego projektu dotyczy wygenerowany prompt.
- Deterministyczny wynik operacji (jawny sukces albo jawna przyczyna błędu).
- Ślad operacyjny wskazujący moment wygenerowania promptu PRD.

## Reguły
- Operacja generowania promptu PRD musi być blokowana lub jawnie odrzucana, gdy nie wybrano aktywnego projektu.
- Prompt PRD musi być generowany wyłącznie dla idei należącej do aktywnego projektu.
- Wygenerowanie promptu PRD musi być wyłącznie operacją inicjowaną przez operatora; brak automatycznych uruchomień.
- Aplikacja nie wykonuje promptu u dostawcy AI; operator odpowiada za jego wykonanie.
- Prompt musi zawierać minimalny, relewantny kontekst zgodny z zasadą minimal context.
- Prompt musi być deterministyczny i strukturalnie zgodny z wymaganym szablonem `IDEA -> PRD`.
- Operacja musi jawnie wskazywać źródłową ideę (tożsamość idei) i aktywny projekt (tożsamość projektu).
- Operacja musi zwracać jawny błąd, gdy wskazana idea nie istnieje lub nie jest dostępna w zakresie aktywnego projektu.
- Operacja musi zwracać jawny błąd, gdy wymagane źródła kontekstu promptu są niedostępne.
- Funkcja nie może modyfikować treści idei ani statusów idei jako efektu ubocznego samego generowania promptu.

## Przypadki brzegowe
- Próba wygenerowania promptu PRD bez aktywnego projektu.
- Próba wygenerowania promptu PRD dla nieistniejącej idei.
- Próba wygenerowania promptu PRD dla idei z innego projektu.
- Próba wygenerowania promptu PRD przy brakujących źródłach kontekstu (`overview`, `constraints`, `glossary` lub wymagane reguły stacka).
- Próba wygenerowania promptu PRD wielokrotnie dla tej samej idei.
- Próba wygenerowania promptu PRD, gdy idea nie jest oznaczona jako `selected` (jeśli taki warunek zostanie egzekwowany w finalnej wersji flow).

## Poza zakresem
- Automatyczne wysyłanie promptu do dowolnego dostawcy AI.
- Automatyczne zapisywanie wygenerowanego PRD do pliku funkcji bez jawnego działania operatora.
- Automatyczna zmiana statusu idei po wygenerowaniu promptu.
- Ranking lub priorytetyzacja idei oparta o AI.
- Kompletny workflow `PRD -> BDD` (to oddzielny krok procesu).
