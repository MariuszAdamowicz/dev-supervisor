# Funkcja: PRD to BDD Flow

## Scenariusz 1: Wygenerowanie promptu BDD na podstawie PRD
Zakładając, że aktywny projekt jest wybrany
Oraz dokument PRD nie jest pusty
Kiedy operator uruchamia operację `PRD -> BDD`
Wtedy generowany jest prompt BDD
Oraz wynik operacji to jawny sukces

## Scenariusz 2: Odrzucenie operacji bez aktywnego projektu
Zakładając, że nie wybrano aktywnego projektu
Kiedy operator uruchamia `PRD -> BDD`
Wtedy operacja kończy się jawną porażką z przyczyną

## Scenariusz 3: Odrzucenie operacji bez tytułu idei
Zakładając, że aktywny projekt jest wybrany
Kiedy operator uruchamia `PRD -> BDD` z pustym tytułem idei
Wtedy operacja kończy się jawną porażką z przyczyną

## Scenariusz 4: Odrzucenie operacji bez dokumentu PRD
Zakładając, że aktywny projekt jest wybrany
Kiedy operator uruchamia `PRD -> BDD` z pustym dokumentem PRD
Wtedy operacja kończy się jawną porażką z przyczyną

## Scenariusz 5: Odrzucenie operacji przy brakującym kontekście
Zakładając, że co najmniej jedno źródło kontekstu jest niedostępne
Kiedy operator uruchamia `PRD -> BDD`
Wtedy operacja kończy się jawną porażką z przyczyną

## Scenariusz 6: Prompt zawiera minimalny kontekst
Zakładając, że wszystkie źródła kontekstu są dostępne
Kiedy operator uruchamia `PRD -> BDD`
Wtedy prompt zawiera minimalny kontekst wymagany dla kroku

## Scenariusz 7: Determinizm promptu i fingerprintu
Zakładając, że dane wejściowe nie uległy zmianie
Kiedy operator uruchamia `PRD -> BDD` wielokrotnie
Wtedy prompt i fingerprint są równoważne

## Scenariusz 8: Brak automatycznego wykonania promptu
Zakładając, że operator uruchamia `PRD -> BDD`
Wtedy aplikacja generuje wyłącznie prompt
Oraz nie wysyła go do dostawcy AI

## Scenariusz 9: Zapis śladu operacyjnego
Zakładając, że operacja zakończyła się sukcesem
Kiedy operator uruchamia `PRD -> BDD`
Wtedy zapisywany jest ślad powiązany z ideą i projektem
