# Przegląd Produktu

## Podsumowanie

Dev Supervisor to lokalna aplikacja desktopowa, która nadzoruje i strukturyzuje workflowy rozwoju oprogramowania wspomaganego AI w wielu projektach.

To nie jest agent AI.
To deterministyczny supervisor procesu, który pomaga operatorowi zarządzać:
- konfiguracją projektu
- ideami
- funkcjami
- specyfikacjami
- testami
- promptami
- walidacją
- śledzeniem postępu

Aplikacja ma ograniczać chaos, dryf kontekstu i niespójność w rozwoju wspomaganym AI.

---

## Główne cele

- Zapewnić ustrukturyzowany i powtarzalny workflow dla rozwoju oprogramowania wspomaganego AI
- Nadzorować wiele projektów z jednej lokalnej aplikacji
- Egzekwować separację między:
  - ideami
  - specyfikacjami
  - scenariuszami BDD
  - testami
  - implementacją
- Utrzymywać śledzalność między wymaganiami, scenariuszami, testami i implementacją
- Generować ustrukturyzowane prompty dla różnych etapów pracy
- Śledzić stan walidacji i postęp w projektach oraz funkcjach
- Zmniejszać obciążenie poznawcze operatora

---

## Kluczowe możliwości

### 1. Zarządzanie projektami
- tworzenie i inicjalizacja projektów
- zarządzanie strukturą projektu
- śledzenie statusu projektu
- obsługa wielu projektów

### 2. Zarządzanie ideami
- przechowywanie idei per projekt
- przenoszenie idei do przepływu definiowania funkcji
- oddzielenie idei od implementacji

### 3. Zarządzanie funkcjami
- tworzenie i zarządzanie cyklem życia funkcji
- śledzenie statusu funkcji
- łączenie funkcji ze specyfikacjami i walidacją

### 4. Zarządzanie specyfikacjami
- zarządzanie PRD funkcji
- zarządzanie scenariuszami BDD
- utrzymywanie śledzalności między regułami i scenariuszami

### 5. Generowanie promptów
- generowanie promptów do:
  - planowania
  - tworzenia PRD
  - tworzenia BDD
  - generowania testów
  - implementacji
  - debugowania
  - refaktoryzacji
- umożliwienie przechowywania szablonów promptów poza plikami projektu

### 6. Śledzenie walidacji
- rejestrowanie statusu build/test/lint
- pokazywanie, czy funkcja jest gotowa do przejścia dalej
- wspieranie ciągłości między sesjami

### 7. Widoczność postępu
- pokazywanie stanu cyklu życia funkcji
- pokazywanie postępu na poziomie projektu
- pokazywanie kompletności specyfikacji
- pokazywanie gotowości walidacyjnej
- opcjonalne wyprowadzanie metryk postępu ze stanu scenariuszy/testów

### 8. Wsparcie śledzalności
- łączenie reguł PRD ze scenariuszami BDD
- łączenie scenariuszy z testami
- uwidacznianie luk

---

## Poza zakresem (faza początkowa)

- bezpośrednie wykonywanie promptów przez dostawcę AI
- pełne zastąpienie IDE
- architektura cloud-first
- współdzielona edycja w czasie rzeczywistym
- głęboka semantyczna analiza kodu
- automatyczna modyfikacja kodu bez kontroli operatora

---

## Zasady projektowe

### Deterministyczna kontrola
Aplikacja musi pozostać deterministyczna i sterowana przez operatora.

### Niezależność od narzędzi
System musi wspierać różne stosy technologiczne, różne strategie promptów i różnych dostawców AI bez ścisłego sprzęgania z którymkolwiek z nich.

### Local First
Aplikacja powinna działać jako lokalny supervisor desktopowy z lokalnym stanem i lokalną persystencją.

### Rozwój sterowany specyfikacją
Preferowany workflow to:
idea → PRD → BDD → testy → implementacja → walidacja

### Śledzalność na pierwszym miejscu
Istotne reguły powinny pozostać śledzalne między:
- PRD
- BDD
- testami

### Workflow przyrostowy
Aplikacja powinna prowadzić pracę małymi, kontrolowanymi krokami zamiast dużych, niejednoznacznych skoków.

---

## Model przechowywania danych

Aplikacja używa lokalnej bazy danych do utrzymywania stanu procesu, metadanych operacyjnych i danych nadzoru projektu.

Baza danych nie ma zastępować plików projektu jako źródła prawdy dla specyfikacji.
Zamiast tego:
- pliki projektu pozostają źródłem prawdy dla artefaktów projektu
- lokalna baza danych przechowuje stan operacyjny, referencje i metadane nadzoru

---

## Użytkownicy docelowi

- solo deweloperzy pracujący z workflowami wspomaganymi AI
- inżynierowie zarządzający wieloma lokalnymi projektami
- deweloperzy, którzy chcą ścisłej kontroli procesu podczas pracy z AI

---

## Granice produktu

Aplikacja:
- nadzoruje proces
- śledzi stan
- generuje prompty
- utrzymuje referencje
- pomaga operatorowi zachować kontrolę

Aplikacja nie:
- zastępuje osądu inżynierskiego
- nie zarządza środowiskiem wykonawczym kodu
- nie wymusza jednego dostawcy AI ani jednego stosu
- nie staje się sama silnikiem implementacyjnym

---

## Kryteria sukcesu

System jest sukcesem, jeśli:
- projekty mogą być inicjalizowane w sposób spójny
- praca nad funkcjami przebiega powtarzalnym flow
- generowanie promptów zmniejsza wysiłek operatora
- stan walidacji jest widoczny przez cały czas
- luki śledzalności są łatwe do wykrycia
- wiele projektów może być nadzorowanych bez chaosu
