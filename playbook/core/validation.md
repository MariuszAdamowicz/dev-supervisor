## 🧪 Testy jako specyfikacja

## 🧠 Strategia testów

Poziomy:
- Unit → większość
- Integration → przepływy
- UI → minimum

Zasada:
Im niżej, tym lepiej. Unikaj nadmiaru testów UI.

Tak — przy zmianie feature testy powinny być potraktowane jako część specyfikacji.

### Zasada
Jeśli zmienia się feature:
1. najpierw zmień `prd.md`
2. potem zmień `bdd.md`
3. potem zmień testy
4. dopiero potem zmień kod

Nie odwrotnie.

### Dlaczego
Bo inaczej stara implementacja zacznie „ciągnąć” stare założenia.

### Czy usuwać stare testy?
Tak, jeśli opisują już nieprawdziwe zachowanie.  
Nie trzymaj testów dla starej logiki, jeśli ta logika nie ma dalej obowiązywać.

### Czy generować testy od nowa?
Często tak.  
Jeśli zmiana jest większa, lepiej:
- usunąć nieaktualne scenariusze
- napisać nowe `bdd.md`
- wygenerować nowy zestaw testów
- zostawić tylko te testy, które nadal opisują prawdziwe wymagania

---

## 🧠 Obsługa błędów i logowanie

Każdy feature powinien:
- mieć scenariusze błędów w BDD
- logować błędy
- nie ukrywać failure

Zasada:
Każdy failure path musi być opisany, testowany i logowany.

---

## Build/Test/Lint Loop

Każda iteracja AI powinna kończyć się:
- build
- test
- lint

### Zasada użycia skryptów
AI powinno używać skryptów jako jedynego wejścia do walidacji.
Nie polegaj na luźnym opisywaniu błędów — przekazuj pełny output ze skryptów.

Uruchom:
```text
./Scripts/build.sh
./Scripts/test.sh
./Scripts/lint.sh
```

Implementacje skryptów: `templates/scripts/`.
Konfiguracja narzędzi Swift/Xcode: `profiles/stack/macos-swiftui.md`.
