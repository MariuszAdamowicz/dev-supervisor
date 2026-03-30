# Funkcja: Rejestr Idei

## Scenariusz 1: Utworzenie idei dla aktywnego projektu z poprawnym tytułem
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz rejestr idei dla projektu "Alpha" jest pusty
Kiedy operator tworzy ideę z tytułem "Offline mode" i opisem "Support offline workflow"
Wtedy tworzony jest nowy rekord idei ze stabilną tożsamością
Oraz idea należy do projektu "Alpha"
Oraz status idei to `new`
Oraz wynik operacji to jawny sukces

## Scenariusz 2: Obsługa wielu idei w ramach jednego projektu
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz projekt "Alpha" ma już ideę "Offline mode"
Kiedy operator tworzy kolejną ideę z tytułem "Bulk import"
Wtedy obie idee istnieją jednocześnie w rejestrze idei projektu "Alpha"
Oraz każda idea pozostaje jednoznacznie identyfikowalna
Oraz wynik operacji to jawny sukces

## Scenariusz 3: Odrzucenie tworzenia idei, gdy nie wybrano aktywnego projektu
Zakładając, że nie wybrano aktywnego projektu
Kiedy operator tworzy ideę z tytułem "Offline mode"
Wtedy żadna idea nie zostaje utworzona
Oraz operacja jest zablokowana lub jawnie odrzucona
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 4: Odrzucenie tworzenia idei z pustym tytułem
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Kiedy operator tworzy ideę z pustym tytułem
Wtedy żadna idea nie zostaje utworzona
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 5: Aktualizacja treści idei przez jawne działanie operatora
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha"
Kiedy operator aktualizuje tytuł idei "Offline mode" na "Offline-first mode" i opis na "Prioritize no-network use"
Wtedy ta sama tożsamość idei zostaje zachowana
Oraz zaktualizowana treść idei jest widoczna w projekcie "Alpha"
Oraz wynik operacji to jawny sukces

## Scenariusz 6: Odrzucenie aktualizacji dla nieistniejącej idei
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz projekt "Alpha" nie zawiera idei o tożsamości "I-404"
Kiedy operator żąda aktualizacji treści idei "I-404"
Wtedy żaden stan idei się nie zmienia
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 7: Zmiana statusu idei na deferred
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha" ze statusem `new`
Kiedy operator zmienia status idei "Offline mode" na `deferred`
Wtedy status idei "Offline mode" to `deferred`
Oraz wynik operacji to jawny sukces

## Scenariusz 8: Wybranie jednej idei jako kandydata do PRD
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha" ze statusem `new`
Kiedy operator zmienia status idei "Offline mode" na `selected`
Wtedy status idei "Offline mode" to `selected`
Oraz projekt "Alpha" ma jawny wskaźnik wybranego kandydata do PRD
Oraz wynik operacji to jawny sukces

## Scenariusz 9: Odrzucenie drugiej idei ze statusem selected w tym samym projekcie
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha" ze statusem `selected`
Oraz idea "Bulk import" istnieje w projekcie "Alpha" ze statusem `new`
Kiedy operator zmienia status idei "Bulk import" na `selected`
Wtedy status idei "Bulk import" pozostaje `new`
Oraz tylko jedna idea ma status `selected` w projekcie "Alpha"
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 10: Odrzucenie nieprawidłowej wartości statusu idei
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje w projekcie "Alpha"
Kiedy operator zmienia status idei "Offline mode" na "in-progress"
Wtedy status idei "Offline mode" nie ulega zmianie
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 11: Odrzucenie zmiany statusu dla nieistniejącej idei
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz projekt "Alpha" nie zawiera idei o tożsamości "I-404"
Kiedy operator zmienia status idei "I-404" na `deferred`
Wtedy żaden stan idei się nie zmienia
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 12: Odrzucenie aktualizacji i zmian statusu, gdy nie wybrano aktywnego projektu
Zakładając, że nie wybrano aktywnego projektu
Oraz rekordy idei istnieją w innych projektach
Kiedy operator żąda aktualizacji idei lub zmiany statusu
Wtedy żaden stan idei się nie zmienia
Oraz operacja jest zablokowana lub jawnie odrzucona
Oraz wynik operacji to jawna porażka z podaniem przyczyny

## Scenariusz 13: Lista idei ograniczona wyłącznie do aktywnego projektu
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz projekt "Alpha" ma ideę "Offline mode"
Oraz projekt "Beta" ma ideę "Telemetry export"
Kiedy operator żąda listy idei dla aktywnego projektu
Wtedy lista zawiera wyłącznie idee z projektu "Alpha"
Oraz żadna idea z projektu "Beta" nie jest uwzględniona

## Scenariusz 14: Listowanie idei zwraca jawną pustą listę
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz projekt "Alpha" nie ma żadnych idei
Kiedy operator żąda listy idei dla aktywnego projektu
Wtedy zwracana jest jawna pusta lista
Oraz żadna idea nie jest tworzona niejawnie

## Scenariusz 15: Wybór kandydata do PRD jest jawny i śledzalny
Zakładając, że projekt "Alpha" jest wybrany jako aktywny projekt
Oraz idea "Offline mode" istnieje ze statusem `new`
Kiedy operator jawnie wybiera ideę "Offline mode" jako kandydata do PRD
Wtedy status idei "Offline mode" zmienia się na `selected`
Oraz zmiana wyboru jest śledzalna jako jawna zmiana stanu
Oraz wynik operacji to jawny sukces

## Scenariusz 16: Zachowanie izolacji projektów przy dostępie do idei
Zakładając, że projekt "Alpha" i projekt "Beta" istnieją
Oraz projekt "Alpha" jest wybrany jako aktywny projekt
Oraz projekt "Beta" zawiera ideę "Telemetry export"
Kiedy operator wykonuje operacje w zakresie projektu "Alpha"
Wtedy dane idei z projektu "Beta" nie są dostępne w tym zakresie
Oraz nie jest wykonywana żadna mutacja idei między projektami
