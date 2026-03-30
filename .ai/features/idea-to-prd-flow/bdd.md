# Funkcja: Idea to PRD Flow

## Scenariusz 1: Wygenerowanie promptu PRD dla idei z aktywnego projektu
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha"
Kiedy operator uruchamia operację `IDEA -> PRD` dla idei "Offline mode"
Wtedy generowany jest prompt PRD gotowy do użycia przez operatora
Oraz wynik operacji to jawny sukces

## Scenariusz 2: Odrzucenie generowania promptu PRD bez aktywnego projektu
Zakładając, że nie wybrano aktywnego projektu
Kiedy operator uruchamia operację `IDEA -> PRD`
Wtedy prompt PRD nie jest generowany
Oraz operacja jest zablokowana lub jawnie odrzucona
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 3: Odrzucenie generowania promptu dla nieistniejącej idei
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz projekt "Alpha" nie zawiera idei o tożsamości "I-404"
Kiedy operator uruchamia operację `IDEA -> PRD` dla idei "I-404"
Wtedy prompt PRD nie jest generowany
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 4: Odrzucenie generowania promptu dla idei spoza aktywnego projektu
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Telemetry export" należy do projektu "Beta"
Kiedy operator uruchamia operację `IDEA -> PRD` dla idei "Telemetry export"
Wtedy prompt PRD nie jest generowany
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 5: Prompt zawiera minimalny i relewantny kontekst
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha"
Oraz źródła kontekstu (`overview`, `constraints`, `glossary`, reguły stacka) są dostępne
Kiedy operator uruchamia operację `IDEA -> PRD`
Wtedy wygenerowany prompt zawiera wyłącznie minimalny kontekst wymagany do kroku `IDEA -> PRD`
Oraz wynik operacji to jawny sukces

## Scenariusz 6: Odrzucenie generowania promptu przy brakujących źródłach kontekstu
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha"
Oraz co najmniej jedno wymagane źródło kontekstu promptu jest niedostępne
Kiedy operator uruchamia operację `IDEA -> PRD`
Wtedy prompt PRD nie jest generowany
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 7: Deterministyczność wygenerowanego promptu
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha"
Oraz kontekst wejściowy nie uległ zmianie
Kiedy operator uruchamia operację `IDEA -> PRD` wielokrotnie dla tej samej idei
Wtedy każde wygenerowanie zwraca prompt o tej samej strukturze i semantyce
Oraz wynik każdej operacji jest jawny

## Scenariusz 8: Brak automatycznego wykonywania promptu przez aplikację
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha"
Kiedy operator uruchamia operację `IDEA -> PRD`
Wtedy aplikacja generuje wyłącznie tekst promptu
Oraz aplikacja nie wysyła promptu do dostawcy AI
Oraz wykonanie promptu pozostaje po stronie operatora

## Scenariusz 9: Jawna identyfikowalność idei i projektu w wyniku
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha"
Kiedy operator uruchamia operację `IDEA -> PRD`
Wtedy wynik operacji jawnie wskazuje tożsamość idei źródłowej
Oraz wynik operacji jawnie wskazuje tożsamość aktywnego projektu

## Scenariusz 10: Brak efektów ubocznych na stanie idei podczas generowania promptu
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha" ze statusem `selected`
Kiedy operator uruchamia operację `IDEA -> PRD`
Wtedy treść idei i status idei pozostają bez zmian
Oraz generowanie promptu nie wykonuje niejawnych modyfikacji rejestru idei

## Scenariusz 11: Rejestrowanie śladu operacyjnego dla wygenerowania promptu
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha"
Kiedy operator uruchamia operację `IDEA -> PRD`
Wtedy zapisywany jest ślad operacyjny wskazujący wygenerowanie promptu PRD
Oraz ślad jest powiązany z ideą i projektem
