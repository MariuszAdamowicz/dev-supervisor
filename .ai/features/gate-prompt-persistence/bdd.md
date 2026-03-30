# Funkcja: Gate Prompt Persistence

## Scenariusz 1: Zapis promptu dla profilu file-ai
Zakładając, że istnieje poprawna ścieżka projektu
Oraz profil storage to `file-ai`
Kiedy aplikacja zapisuje prompt operacji gate
Wtedy prompt jest zapisany w katalogu `.ai/gates/...`
Oraz wynik operacji to jawny sukces

## Scenariusz 2: Zapis promptu dla profilu sqlbase
Zakładając, że istnieje poprawna ścieżka projektu
Oraz profil storage to `sqlbase`
Kiedy aplikacja zapisuje prompt operacji gate
Wtedy prompt jest zapisany w katalogu `State/gates/...`
Oraz wynik operacji to jawny sukces

## Scenariusz 3: Odrzucenie zapisu dla pustego promptu
Zakładając, że tekst promptu jest pusty
Kiedy aplikacja uruchamia zapis
Wtedy operacja kończy się jawną porażką z przyczyną

## Scenariusz 4: Automatyczne wywołanie persystencji po udanym gate
Zakładając, że gate kończy się sukcesem
Kiedy aplikacja otrzymuje wynik z promptem
Wtedy uruchamiany jest zapis promptu do storage projektu
