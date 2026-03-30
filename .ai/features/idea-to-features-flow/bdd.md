# Funkcja: Idea to Features Flow

## Scenariusz 1: Wygenerowanie promptu FEATURES dla wybranej idei z aktywnego projektu
Zakładając, że projekt "Alpha" jest aktywny
Oraz idea "Project Registry" istnieje w projekcie "Alpha" i ma status `selected`
Kiedy operator uruchamia operację `IDEA -> FEATURES`
Wtedy generowany jest prompt gotowy do użycia przez operatora
Oraz wynik operacji to jawny sukces

## Scenariusz 2: Odrzucenie generowania FEATURES bez aktywnego projektu
Zakładając, że nie wybrano aktywnego projektu
Kiedy operator uruchamia operację `IDEA -> FEATURES`
Wtedy prompt nie jest generowany
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 3: Odrzucenie generowania FEATURES dla nieistniejącej idei
Zakładając, że projekt "Alpha" jest aktywny
Oraz idea "I-404" nie istnieje
Kiedy operator uruchamia operację `IDEA -> FEATURES` dla "I-404"
Wtedy prompt nie jest generowany
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 4: Odrzucenie generowania FEATURES dla idei spoza aktywnego projektu
Zakładając, że projekt "Alpha" jest aktywny
Oraz idea "Telemetry Export" należy do projektu "Beta"
Kiedy operator uruchamia operację `IDEA -> FEATURES`
Wtedy prompt nie jest generowany
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 5: Odrzucenie generowania FEATURES dla idei bez statusu `selected`
Zakładając, że projekt "Alpha" jest aktywny
Oraz idea "Project Registry" ma status `new`
Kiedy operator uruchamia operację `IDEA -> FEATURES`
Wtedy prompt nie jest generowany
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 6: Prompt FEATURES zawiera minimalny kontekst
Zakładając, że idea "Project Registry" ma status `selected`
Oraz źródła `overview`, `constraints`, `glossary` są dostępne
Kiedy operator uruchamia operację `IDEA -> FEATURES`
Wtedy prompt zawiera wyłącznie minimalny kontekst
Oraz wynik operacji to jawny sukces

## Scenariusz 7: Odrzucenie generowania FEATURES przy brakującym kontekście
Zakładając, że co najmniej jedno wymagane źródło kontekstu jest niedostępne
Kiedy operator uruchamia operację `IDEA -> FEATURES`
Wtedy prompt nie jest generowany
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 8: Deterministyczność promptu i listy funkcjonalności
Zakładając, że dane wejściowe nie uległy zmianie
Kiedy operator uruchamia operację `IDEA -> FEATURES` wielokrotnie
Wtedy prompt i lista funkcjonalności są równoważne między uruchomieniami

## Scenariusz 9: Brak automatycznego wykonania promptu przez aplikację
Zakładając, że operator uruchamia operację `IDEA -> FEATURES`
Wtedy aplikacja generuje wyłącznie prompt
Oraz aplikacja nie wysyła promptu do dostawcy AI

## Scenariusz 10: Jawna identyfikowalność idei i projektu w wyniku
Zakładając, że operacja `IDEA -> FEATURES` kończy się sukcesem
Wtedy wynik jawnie wskazuje idea_id
Oraz wynik jawnie wskazuje project_id

## Scenariusz 11: Brak efektów ubocznych i zapis śladu operacyjnego
Zakładając, że idea istnieje w aktywnym projekcie
Kiedy operator uruchamia operację `IDEA -> FEATURES`
Wtedy treść i status idei pozostają bez zmian
Oraz zapisany zostaje ślad operacyjny powiązany z ideą i projektem
