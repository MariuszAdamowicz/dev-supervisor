# Zasady architektoniczne w duchu Roberta C. Martina

Ten dokument jest praktyczną syntezą idei Roberta C. Martina z książek takich jak *Clean Architecture*, *Clean Code* i *Agile Software Development: Principles, Patterns, and Practices*.
Nie jest to katalog cytatów ani komplet wszystkich tez autora, tylko prosty zestaw reguł, których warto pilnować przy projektowaniu nowego systemu.

## 1. Nadrzędny cel architektury

1. Architektura ma zmniejszać koszt zmian.
2. Dobra architektura nie tylko "działa", ale pozwala zmieniać system bez chaosu.
3. Im łatwiej zmienić funkcję, dodać regułę biznesową i uruchomić testy, tym lepsza architektura.
4. Decyzje trudne do cofnięcia należy odkładać tak długo, jak to rozsądne.
5. Framework, baza danych i sposób wdrożenia to ważne decyzje techniczne, ale nadal są tylko szczegółami.

## 2. Jak Martin patrzy na system

Model czystej architektury można streścić tak:

- Encje: najtrwalsze reguły biznesowe.
- Przypadki użycia: logika aplikacyjna, czyli co system robi dla użytkownika.
- Adaptery interfejsów: tłumaczą świat zewnętrzny na model wewnętrzny i odwrotnie.
- Frameworki i sterowniki: web, UI, baza danych, kolejki, biblioteki, system operacyjny.

Najważniejsza reguła tego modelu:

- Zależności w kodzie mają kierować się do środka, w stronę logiki biznesowej.

## 3. Reguły podstawowe

1. Projektuj system wokół przypadków użycia, nie wokół frameworka.
2. Architektura ma "krzyczeć" domeną biznesową, a nie technologią.
3. Reguły biznesowe powinny być możliwe do uruchomienia bez UI, bez bazy i bez sieci.
4. To, że używasz Reacta, Swifta, Springa albo Postgresa, nie powinno definiować struktury domeny.
5. Kod odpowiedzialny za polityki biznesowe trzymaj bliżej centrum systemu.
6. Kod odpowiedzialny za szczegóły techniczne trzymaj na obrzeżach systemu.
7. Granice wyznaczaj tam, gdzie zmienia się tempo zmian albo odpowiedzialność.
8. Przechodząc przez granice, przekazuj proste dane, nie obiekty zależne od frameworka.
9. Architektura ma izolować to, co niestabilne, od tego, co trwałe.
10. Jeśli element można wymienić bez ruszania reguł biznesowych, jest we właściwym miejscu.

## 4. Reguła zależności

1. Kod wewnętrzny nie zna kodu zewnętrznego.
2. Domena nie zna bazy danych.
3. Domena nie zna warstwy webowej.
4. Domena nie zna frameworka UI.
5. Przypadki użycia nie powinny importować szczegółów infrastruktury.
6. To warstwy zewnętrzne zależą od wewnętrznych, a nie odwrotnie.
7. Integracje z bazą, API, plikami lub kolejkami ukrywaj za portami, interfejsami lub kontraktami.
8. Implementacje szczegółów podpinaj na krawędzi systemu, zwykle w composition root.

## 5. SOLID w prostych słowach

### SRP - Single Responsibility Principle

1. Moduł powinien mieć jeden główny powód do zmiany.
2. Jeśli jedna klasa zmienia się z powodów biznesowych, raportowych i technicznych naraz, jest źle podzielona.

### OCP - Open/Closed Principle

1. System powinien dać się rozszerzać bez przepisywania stabilnego kodu.
2. Nowe zachowania dodawaj przez nowe moduły, strategie lub adaptery, a nie przez rozrywanie sprawdzonego rdzenia.

### LSP - Liskov Substitution Principle

1. Jeśli coś jest podtypem czegoś innego, musi dać się użyć bez psucia oczekiwań.
2. Dziedziczenie bez zachowania kontraktu prowadzi do ukrytych błędów.

### ISP - Interface Segregation Principle

1. Lepiej mieć kilka małych interfejsów niż jeden gruby.
2. Klient nie powinien zależeć od metod, których nie używa.

### DIP - Dependency Inversion Principle

1. Logika wysokiego poziomu nie może zależeć od szczegółów niskiego poziomu.
2. Obie strony powinny zależeć od abstrakcji.
3. Baza danych jest pluginem do aplikacji, a nie jej centrum.

## 6. Zasady komponentów i modułów

Robert Martin opisuje też reguły na poziomie większych części systemu.

### Zasady spójności

1. REP: rzeczy używane razem powinny być wydawane razem.
2. CCP: rzeczy zmieniające się z tego samego powodu powinny być trzymane razem.
3. CRP: nie zmuszaj modułu do zależenia od rzeczy, których nie używa.

### Zasady zależności między komponentami

1. ADP: zależności między komponentami nie mogą tworzyć cykli.
2. SDP: zależ od komponentów bardziej stabilnych niż ty sam.
3. SAP: im bardziej stabilny komponent, tym bardziej powinien być abstrakcyjny.

Prosto mówiąc:

1. Moduły mają być spójne wewnętrznie.
2. Moduły nie mogą się zapętlać.
3. Najstabilniejsze elementy systemu powinny być najczystsze i najmniej zależne od szczegółów.

## 7. Reguły kodu wspierające dobrą architekturę

1. Nazwy mają mówić prawdę o domenie.
2. Funkcje i klasy mają być małe na tyle, by dało się je zrozumieć bez śledztwa.
3. Duplikacja logiki to sygnał, że granice odpowiedzialności są źle ustawione.
4. Obsługa błędów ma być jawna.
5. Efekty uboczne trzymaj przy krawędziach systemu.
6. Globalny mutowalny stan niszczy przewidywalność i testowalność.
7. Format danych z bazy lub API nie powinien przeciekać do domeny.
8. Testy powinny chronić zachowanie systemu, a nie przypadkowe szczegóły implementacji.
9. Architektura powinna być widoczna w strukturze katalogów i nazwach modułów.
10. Jeśli biznes wymaga prawdziwej reguły, ta reguła nie może siedzieć tylko w kontrolerze albo widoku.

## 8. Testowalność jako miernik jakości architektury

1. Jeśli reguły biznesowe da się testować bez stawiania całego środowiska, architektura jest zdrowa.
2. Testy jednostkowe powinny obejmować encje i przypadki użycia.
3. Testy integracyjne powinny sprawdzać adaptery i połączenia ze światem zewnętrznym.
4. Im więcej logiki wymaga prawdziwej bazy albo prawdziwego UI, tym większe sprzężenie.
5. Trudność testowania bardzo często oznacza błąd architektoniczny, a nie tylko brak testów.

## 9. Zasady praktyczne, których sam bym pilnował jako architekt

1. Zacząłbym od modelu domeny i przypadków użycia, nie od wyboru frameworka.
2. Rdzeń systemu trzymałbym w modułach bez zależności od UI, HTTP, ORM i konkretnej bazy.
3. Każde połączenie ze światem zewnętrznym zamknąłbym za interfejsem lub portem.
4. Wymusiłbym jednokierunkowe zależności między warstwami.
5. Pilnowałbym braku cykli między modułami.
6. Trzymałbym logikę biznesową poza kontrolerami, widokami i repozytoriami.
7. Używałbym DTO do przekraczania granic, zamiast przepychać obiekty frameworkowe przez cały system.
8. Wprowadzałbym nową warstwę tylko wtedy, gdy naprawdę redukuje sprzężenie albo koszt zmian.
9. Domyślnie budowałbym modularny monolit, a nie mikroserwisy na start.
10. Nie pozwoliłbym, żeby schema bazy danych dyktowała model domeny.
11. Każdy ważny przypadek użycia musiałby mieć test niezależny od infrastruktury.
12. Każdy adapter zewnętrzny musiałby dać się wymienić bez ruszania rdzenia.
13. Kompozycję zależności zrobiłbym w jednym jawnym miejscu.
14. Oddzielałbym polityki od szczegółów technicznych przy każdej większej decyzji.
15. Utrzymywałbym architekturę prostą tak długo, jak długo prostota nie przeszkadza w rozwoju.

## 10. Sygnały ostrzegawcze

1. Kontrolery zawierają logikę biznesową.
2. Encje importują framework albo ORM.
3. Każda zmiana wymaga dotykania wielu niepowiązanych modułów.
4. Moduły zależą od siebie nawzajem.
5. Test reguły biznesowej wymaga prawdziwej bazy, prawdziwej sieci albo prawdziwego UI.
6. Struktura katalogów mówi głównie o technologii, a prawie nic o domenie.
7. Repozytoria decydują o regułach biznesowych.
8. Baza danych jest traktowana jak serce systemu zamiast jako wymienialny szczegół.
9. Mikroserwisy pojawiają się zanim pojawi się realna potrzeba niezależnego wdrażania.

## 11. Krótkie podsumowanie

Najprostsza wersja myśli Martina brzmi tak:

1. Najważniejsze jest biznesowe serce systemu.
2. Wszystko inne jest dodatkiem do tego serca.
3. Zależności mają iść do środka.
4. Szczegóły techniczne mają być wymienne.
5. Kod ma być podzielony według odpowiedzialności i powodów do zmiany.
6. Dobra architektura to taka, która pozwala system bezpiecznie rozwijać przez lata.
