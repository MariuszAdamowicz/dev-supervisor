# Słownik

## Projekt

Nadzorowany projekt programistyczny zarządzany przez Dev Supervisor.

Projekt składa się z:
- idei
- funkcji
- specyfikacji (PRD, BDD)
- stanu walidacji
- śledzenia postępu

Projekt jest zazwyczaj mapowany na lokalne repozytorium, ale nie jest do niego ograniczony.

---

## Idea

Surowa, nieustrukturyzowana koncepcja lub potencjalna funkcja.

Charakterystyka:
- jeszcze niesprecyzowana
- niezatwierdzona do implementacji
- przechowywana w `ideas.md`
- może zostać awansowana do funkcji

---

## Funkcja

Zdefiniowana jednostka funkcjonalności z jasną odpowiedzialnością.

Charakterystyka:
- ma własną specyfikację (PRD)
- ma zdefiniowane zachowanie (BDD)
- ma powiązane testy
- przechodzi cykl życia od idei do implementacji

---

## PRD (Product Requirements Document)

Ustrukturyzowany opis tego, co funkcja lub system musi robić.

Zawiera:
- cel
- wejścia
- wyjścia
- reguły
- ograniczenia
- przypadki brzegowe

PRD definiuje kontrakt, ale nie egzekwuje zachowania.

---

## BDD (Behavior Driven Development)

Zestaw scenariuszy opisujących, jak system powinien się zachowywać.

Charakterystyka:
- zapisany jako scenariusze
- obejmuje happy path, przypadki brzegowe i porażki
- używany jako podstawa do generowania testów

BDD definiuje oczekiwane zachowanie.

---

## Test

Wykonywalna weryfikacja zachowania systemu.

Charakterystyka:
- wywodzona ze scenariuszy BDD
- egzekwuje poprawność
- zapobiega regresjom

Testy są ostatecznym źródłem prawdy dla zachowania.

---

## Śledzalność

Relacja między:
- regułami PRD
- scenariuszami BDD
- testami

Cel:
- zapewnić pokrycie
- wykrywać luki
- utrzymywać spójność

---

## Prompt

Ustrukturyzowana instrukcja używana do prowadzenia rozwoju wspomaganego AI.

Typy:
- planowanie
- generowanie PRD
- generowanie BDD
- generowanie testów
- implementacja
- debugowanie
- refaktoryzacja

Prompty są deterministyczne i świadome kontekstu.

---

## Szablon Promptu

Wielokrotnego użytku struktura do generowania promptów.

Przechowywana poza plikami projektu lub obok nich.

---

## Walidacja

Proces weryfikacji poprawności systemu przy użyciu:
- build
- testów
- lint

Walidacja określa gotowość funkcji lub projektu.

---

## Cykl życia funkcji

Sekwencja kroków, przez które przechodzi funkcja:

idea → PRD → BDD → testy → implementacja → walidacja → stabilizacja

---

## Stabilizacja

Proces:
- porządkowania kodu
- usuwania martwej logiki
- wyrównywania implementacji ze specyfikacją
- aktualizacji dokumentacji

---

## Operator

Człowiek używający Dev Supervisor.

Odpowiedzialności:
- podejmowanie decyzji
- wykonywanie promptów
- nadzorowanie workflow

---

## Supervisor

Sam Dev Supervisor.

Odpowiedzialności:
- strukturyzowanie procesu
- generowanie promptów
- śledzenie stanu
- utrzymywanie śledzalności

NIE:
- wykonuje kodu
- zastępuje osądu dewelopera

---

## Kontekst

Zestaw informacji przekazanych do AI w danym kroku.

Zasady:
- minimalny
- istotny
- ograniczony do funkcji

---

## Kod Współdzielony

Kod używany ponownie przez wiele funkcji.

Zlokalizowany w:
- Core/Domain
- Core/Shared
- Core/Providers
- Core/Routing

---

## Ekstrakcja

Proces przenoszenia zduplikowanej lub wielokrotnego użytku logiki do modułów współdzielonych.

Uruchamiany, gdy:
- podobna logika pojawi się więcej niż raz
