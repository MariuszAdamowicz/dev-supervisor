# Funkcja: Gate Prompt Persistence

## Cel
Zapewnić trwały zapis wygenerowanych promptów gate'ów workflow do wybranego profilu storage (`file-ai` albo `sqlbase`) bez zmiany deterministycznej logiki generowania promptów.

## Wejścia
- Ścieżka projektu.
- Profil storage (`file-ai` lub `sqlbase`).
- Operacja gate (np. `IDEA -> FEATURES`).
- Tożsamość projektu i idei (jeśli dostępna).
- Tekst promptu wygenerowany przez gate.

## Wyjścia
- Plik promptu zapisany trwale.
- Jawny sukces albo jawna porażka zapisu.
- Ścieżka do zapisanego artefaktu.

## Reguły
- Zapis wykonywany wyłącznie dla operacji zakończonych sukcesem.
- Pusty prompt lub nieprawidłowa ścieżka projektu powodują jawną porażkę.
- Dla `file-ai` artefakty trafiają do `.ai/gates/<operation-slug>/`.
- Dla `sqlbase` artefakty trafiają do `State/gates/<operation-slug>/`.
- Zapis nie uruchamia żadnego dostawcy AI.

## Poza zakresem
- Migracja zapisów do relacyjnego schematu SQL.
- Wersjonowanie artefaktów ponad prosty timestamp i tożsamości.
