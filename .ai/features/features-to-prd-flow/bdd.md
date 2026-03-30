# Funkcja: Features to PRD Flow

## Scenariusz 1: Wygenerowanie promptu PRD na podstawie funkcjonalności
Zakładając, że aktywny projekt jest wybrany
Oraz lista funkcjonalności nie jest pusta
Kiedy operator uruchamia operację `FEATURES -> PRD`
Wtedy generowany jest prompt PRD
Oraz wynik operacji to jawny sukces

## Scenariusz 2: Odrzucenie operacji bez aktywnego projektu
Zakładając, że nie wybrano aktywnego projektu
Kiedy operator uruchamia `FEATURES -> PRD`
Wtedy operacja kończy się jawną porażką z przyczyną

## Scenariusz 3: Odrzucenie operacji bez tytułu idei
Zakładając, że aktywny projekt jest wybrany
Kiedy operator uruchamia `FEATURES -> PRD` z pustym tytułem idei
Wtedy operacja kończy się jawną porażką z przyczyną

## Scenariusz 4: Odrzucenie operacji bez funkcjonalności
Zakładając, że aktywny projekt jest wybrany
Kiedy operator uruchamia `FEATURES -> PRD` z pustą listą funkcjonalności
Wtedy operacja kończy się jawną porażką z przyczyną

## Scenariusz 5: Odrzucenie operacji przy brakującym kontekście
Zakładając, że co najmniej jedno źródło kontekstu jest niedostępne
Kiedy operator uruchamia `FEATURES -> PRD`
Wtedy operacja kończy się jawną porażką z przyczyną

## Scenariusz 6: Prompt zawiera minimalny kontekst
Zakładając, że wszystkie źródła kontekstu są dostępne
Kiedy operator uruchamia `FEATURES -> PRD`
Wtedy prompt zawiera minimalny kontekst wymagany dla kroku

## Scenariusz 7: Determinizm promptu i fingerprintu
Zakładając, że dane wejściowe nie uległy zmianie
Kiedy operator uruchamia `FEATURES -> PRD` wielokrotnie
Wtedy prompt i fingerprint są równoważne

## Scenariusz 8: Brak automatycznego wykonania promptu
Zakładając, że operator uruchamia `FEATURES -> PRD`
Wtedy aplikacja generuje wyłącznie prompt
Oraz nie wysyła go do dostawcy AI

## Scenariusz 9: Zapis śladu operacyjnego
Zakładając, że operacja zakończyła się sukcesem
Kiedy operator uruchamia `FEATURES -> PRD`
Wtedy zapisywany jest ślad powiązany z ideą i projektem
