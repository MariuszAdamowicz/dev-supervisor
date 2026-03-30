# Funkcja: Rejestr Projektów

## Scenariusz 1: Rejestracja poprawnego projektu
Zakładając, że rejestr jest pusty
Kiedy operator rejestruje projekt o nazwie "Alpha" i lokalnej ścieżce/odniesieniu "/projects/alpha"
Wtedy tworzony jest nowy rekord projektu ze stabilną tożsamością
Oraz projekt jest widoczny na liście projektów jako aktywny
Oraz wynik operacji to jawny sukces

## Scenariusz 2: Rejestracja wielu projektów równolegle
Zakładając, że projekt "Alpha" istnieje z lokalną ścieżką/odniesieniem "/projects/alpha"
Kiedy operator rejestruje drugi projekt o nazwie "Beta" i lokalnej ścieżce/odniesieniu "/projects/beta"
Wtedy oba projekty istnieją w rejestrze jednocześnie
Oraz każdy projekt pozostaje jednoznacznie identyfikowalny
Oraz wynik operacji to jawny sukces

## Scenariusz 3: Odrzucenie rejestracji z brakującymi wymaganymi polami
Zakładając, że rejestr jest pusty
Kiedy operator rejestruje projekt z pustą nazwą lub pustą lokalną ścieżką/odniesieniem
Wtedy żaden projekt nie jest tworzony
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 4: Odrzucenie zduplikowanej aktywnej ścieżki/odniesienia
Zakładając, że aktywny projekt "Alpha" istnieje z lokalną ścieżką/odniesieniem "/projects/alpha"
Kiedy operator rejestruje kolejny aktywny projekt z lokalną ścieżką/odniesieniem "/projects/alpha"
Wtedy drugi projekt nie zostaje utworzony
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 5: Aktualizacja metadanych projektu przez jawne działanie operatora
Zakładając, że projekt "Alpha" istnieje z lokalną ścieżką/odniesieniem "/projects/alpha"
Kiedy operator aktualizuje nazwę projektu na "Alpha Renamed"
Wtedy ta sama tożsamość projektu zostaje zachowana
Oraz zaktualizowane metadane są widoczne w rejestrze
Oraz wynik operacji to jawny sukces

## Scenariusz 6: Odrzucenie aktualizacji dla nieistniejącego projektu
Zakładając, że rejestr nie zawiera projektu o tożsamości "P-404"
Kiedy operator żąda aktualizacji metadanych projektu "P-404"
Wtedy żaden stan projektu się nie zmienia
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 7: Archiwizacja projektu zachowuje tożsamość i historię
Zakładając, że aktywny projekt "Alpha" istnieje
Kiedy operator archiwizuje projekt "Alpha"
Wtedy status projektu zmienia się na zarchiwizowany
Oraz tożsamość projektu pozostaje bez zmian
Oraz historia projektu pozostaje zachowana
Oraz wynik operacji to jawny sukces

## Scenariusz 8: Reaktywacja zarchiwizowanego projektu zachowuje tożsamość i historię
Zakładając, że zarchiwizowany projekt "Alpha" istnieje
Kiedy operator reaktywuje projekt "Alpha"
Wtedy status projektu zmienia się na aktywny
Oraz tożsamość projektu pozostaje bez zmian
Oraz historia projektu pozostaje zachowana
Oraz wynik operacji to jawny sukces

## Scenariusz 9: Odrzucenie archiwizacji już zarchiwizowanego projektu
Zakładając, że projekt "Alpha" jest zarchiwizowany
Kiedy operator ponownie archiwizuje projekt "Alpha"
Wtedy żaden stan projektu się nie zmienia
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 10: Odrzucenie reaktywacji już aktywnego projektu
Zakładając, że projekt "Beta" jest aktywny
Kiedy operator ponownie reaktywuje projekt "Beta"
Wtedy żaden stan projektu się nie zmienia
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 11: Jawny wybór jednego aktywnego projektu roboczego
Zakładając, że aktywne projekty "Alpha" i "Beta" istnieją
Oraz żaden aktywny projekt roboczy nie jest wybrany
Kiedy operator wybiera "Alpha" jako aktywny projekt roboczy
Wtedy "Alpha" jest jedynym aktywnym projektem roboczym
Oraz informacja o aktywnym projekcie roboczym jest widoczna
Oraz wynik operacji to jawny sukces

## Scenariusz 12: Zamiana wyboru aktywnego projektu roboczego
Zakładając, że aktywne projekty "Alpha" i "Beta" istnieją
Oraz "Alpha" jest wybrany jako aktywny projekt roboczy
Kiedy operator wybiera "Beta" jako aktywny projekt roboczy
Wtedy "Beta" jest jedynym aktywnym projektem roboczym
Oraz "Alpha" nie jest już wybrany jako aktywny projekt roboczy
Oraz wynik operacji to jawny sukces

## Scenariusz 13: Blokowanie operacji na poziomie funkcji, gdy nie wybrano projektu
Zakładając, że aktywne projekty istnieją
Oraz żaden aktywny projekt roboczy nie jest wybrany
Kiedy żądana jest operacja na poziomie funkcji
Wtedy operacja jest zablokowana lub jawnie odrzucona
Oraz odpowiedź zawiera jawny błąd

## Scenariusz 14: Izolacja projektu w nadzorowanych danych
Zakładając, że projekty "Alpha" i "Beta" istnieją
Oraz każdy projekt ma własne idee, funkcje, postęp i metadane
Kiedy operator przegląda dane ograniczone do projektu "Alpha"
Wtedy widoczne są tylko dane "Alpha" w tym zakresie
Oraz dane "Beta" nie są uwzględnione w tym zakresie

## Scenariusz 15: Zachowanie listy, gdy nie istnieją żadne projekty
Zakładając, że rejestr jest pusty
Kiedy operator żąda listy projektów
Wtedy zwracana jest jawna pusta lista
Oraz żaden projekt nie jest tworzony niejawnie

## Scenariusz 16: Odrzucenie archiwizacji dla nieistniejącego projektu
Zakładając, że rejestr nie zawiera projektu o tożsamości "P-404"
Kiedy operator żąda archiwizacji projektu "P-404"
Wtedy żaden stan projektu się nie zmienia
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 17: Jawna porażka, gdy zarejestrowana ścieżka/odniesienie jest niedostępna
Zakładając, że projekt "Alpha" jest zarejestrowany z lokalną ścieżką/odniesieniem "/projects/alpha"
Oraz lokalna ścieżka/odniesienie jest obecnie niedostępna
Kiedy operator wykonuje operację, która wymaga tej ścieżki/odniesienia
Wtedy nie zachodzi żadna cicha zmiana stanu
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 18: Odrzucenie wyboru nieistniejącego projektu
Zakładając, że rejestr nie zawiera projektu o tożsamości "P-404"
Kiedy operator wybiera projekt "P-404" jako aktywny projekt roboczy
Wtedy żaden projekt nie jest wybrany jako aktywny projekt roboczy
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 19: Odrzucenie wyboru zarchiwizowanego projektu
Zakładając, że projekt "Alpha" istnieje i jest zarchiwizowany
Kiedy operator wybiera "Alpha" jako aktywny projekt roboczy
Wtedy żaden projekt nie jest wybrany jako aktywny projekt roboczy
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 20: Odrzucenie aktualizacji wprowadzającej zduplikowaną aktywną ścieżkę/odniesienie
Zakładając, że aktywny projekt "Alpha" istnieje z lokalną ścieżką/odniesieniem "/projects/alpha"
Oraz aktywny projekt "Beta" istnieje z lokalną ścieżką/odniesieniem "/projects/beta"
Kiedy operator aktualizuje projekt "Beta", aby używał lokalnej ścieżki/odniesienia "/projects/alpha"
Wtedy aktualizacja nie jest zastosowana
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 21: Aktualizacja lokalnej ścieżki/odniesienia projektu na nową unikalną wartość
Zakładając, że aktywny projekt "Alpha" istnieje z lokalną ścieżką/odniesieniem "/projects/alpha"
Kiedy operator aktualizuje projekt "Alpha", aby używał lokalnej ścieżki/odniesienia "/projects/alpha-new"
Wtedy ta sama tożsamość projektu zostaje zachowana
Oraz zaktualizowana lokalna ścieżka/odniesienie jest widoczna w rejestrze
Oraz wynik operacji to jawny sukces

## Scenariusz 22: Lista zawiera razem projekty aktywne i zarchiwizowane
Zakładając, że projekt "Alpha" jest aktywny
Oraz projekt "Beta" istnieje i jest zarchiwizowany
Kiedy operator żąda listy projektów
Wtedy lista zawiera zarówno projekty aktywne, jak i zarchiwizowane
Oraz nie jest wykonywana żadna niejawna zmiana stanu

## Scenariusz 23: Odrzucenie reaktywacji, gdy ścieżka/odniesienie koliduje z innym aktywnym projektem
Zakładając, że projekt "Alpha" istnieje i jest aktywny z lokalną ścieżką/odniesieniem "/projects/alpha"
Oraz projekt "Beta" istnieje i jest zarchiwizowany z lokalną ścieżką/odniesieniem "/projects/alpha"
Kiedy operator reaktywuje projekt "Beta"
Wtedy projekt "Beta" pozostaje zarchiwizowany
Oraz wynik operacji to jawna porażka z podaniem przyczyny
