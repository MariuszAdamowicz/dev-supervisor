## 🧠 Git Workflow

### Zasady commitów
- commity małe i logiczne
- jeden commit = jedna zmiana
- brak mieszanych commitów

Przykłady:
feat: add routing fallback
fix: handle provider timeout
refactor: extract provider selector

### Zasady Pull Request
PR powinien zawierać:
- cel zmiany
- zakres
- powiązanie z feature (.ai/features/<feature>/)
- informację o testach
- ryzyka

Zasada:
PR ma być zrozumiały bez czytania całego kodu.

### Solo mode (no PR)
Tryb dla pojedynczego developera, gdy PR na platformie hostującej jest zbędny lub zablokowany.

Zasady:
- zachowaj branch `feat/<feature>` do izolacji pracy
- po local validation wykonaj merge lokalny do `main` bez etapu platformowego PR
- traktuj checklistę review jako self-review obowiązkowy przed merge
- nie merguj do `main` bez `build + test + lint`
- po merge usuń branch feature lokalnie i zdalnie

Minimalny flow:
```bash
git checkout main
git pull
git checkout -b feat/<feature>
# praca + commity
./Scripts/build.sh
./Scripts/test.sh
./Scripts/lint.sh
git checkout main
git merge --no-ff feat/<feature>
git push origin main
git branch -d feat/<feature>
git push origin --delete feat/<feature>
```

### 🎯 Cel

Git workflow ma być częścią procesu wytwórczego, a nie dodatkiem "na końcu".

Jego zadaniem jest zapewnić:
- bezpieczne wdrażanie feature
- izolację zmian
- łatwy review
- prosty rollback
- częstą integrację z `main`
- brak chaosu przy równoległych zmianach

---

### 🌿 Model branchingu

Zalecany model:
- `main` → jedyna długowieczna gałąź
- `feat/<feature>` → branch dla pojedynczego feature lub jednej spójnej zmiany

Przykłady:
- `feat/routing-fallback`
- `feat/provider-stats`
- `feat/menu-bar-settings`

Nie używaj na start:
- `develop`
- `release/*`
- rozbudowanego Gitflow

Dla tego typu projektu lepszy jest prosty model:
- mały branch
- szybki merge
- częsta synchronizacja z `main`

---

### 🔁 Lifecycle brancha

```text
idea → branch → PRD/BDD/tests → implementation → validate → PR → review → merge → delete
```

Interpretacja:
- idea → pomysł trafia do `ideas.md`
- branch → tworzysz `feat/<feature>`
- PRD/BDD/tests → doprecyzowujesz specyfikację zanim rozbudujesz kod
- implementation → pracujesz tylko w obrębie tego feature
- validate → uruchamiasz build + test + lint
- PR → przygotowujesz pull request
- review → sprawdzasz kod, architekturę i duplikację
- merge → scalasz do `main`
- delete → usuwasz branch po merge

---

### ✅ Zasady branchy

#### 1. Jeden feature = jeden branch

Nie mieszaj kilku feature w jednym branchu.

Jeżeli zmiana jest duża, podziel ją na:
- osobne PR-y
- albo osobne kroki w jednym feature, ale nadal trzymaj jedną odpowiedzialność brancha

#### 2. Branch ma być krótkożyjący

Nie trzymaj branchy tygodniami, jeśli da się tego uniknąć.

Im dłużej branch żyje:
- tym większe ryzyko konfliktów
- tym trudniejszy merge
- tym większa szansa, że AI zacznie dryfować względem aktualnego `main`

#### 3. Branch startuje z aktualnego `main`

Przed rozpoczęciem pracy:

```bash
 git checkout main
 git pull
 git checkout -b feat/<feature>
```

#### 4. Branch kończy się usunięciem

Po merge branch nie powinien żyć dalej.

---

### 🧪 Co musi być gotowe przed PR

Branch jest gotowy do Pull Request dopiero wtedy, gdy:
- PRD feature istnieje
- BDD istnieje
- testy istnieją lub zostały zaktualizowane
- build przechodzi
- testy przechodzą
- lint przechodzi
- nie ma martwego kodu
- nie ma niepotrzebnej duplikacji
- `notes.md` i `traceability.md` są zsynchronizowane

---

### 🔍 Co sprawdzać w review

Review to nie tylko „czy działa”.

Sprawdzaj:
- zgodność z `prd.md`
- zgodność z `bdd.md`
- czy testy pokrywają scenariusze
- czy nie pojawiła się duplikacja
- czy kod współdzielony nie powinien trafić do `Core/Shared`, `Core/Domain`, `Core/Providers` lub `Core/Routing`
- czy AI nie zmieniło plików niezwiązanych z feature
- czy zmiana nie wymaga dopisania nowej reguły operacyjnej do playbooka lub setupu
- czy nazwy są spójne z glossary i architekturą

---

### 🔁 Synchronizacja brancha z `main`

Jeżeli branch żyje dłużej i `main` się zmienił, zsynchronizuj branch przed merge.

Najprostszy model:

```bash
 git fetch origin
 git rebase origin/main
```

Jeśli projekt lub zespół woli merge zamiast rebase, też jest to akceptowalne — ważne, żeby branch nie odjechał od `main`.

Najważniejsza zasada:
- nie merguj starego brancha bez wcześniejszej synchronizacji

---

### 🚫 Czego nie robić

Nie rób:
- jednego brancha dla wielu niezależnych feature
- długowiecznych branchy bez synchronizacji
- merge bez PR
- merge mimo czerwonego builda
- merge mimo nieprzechodzących testów
- poprawiania konfliktów "na szybko" bez ponownego uruchomienia walidacji

W trybie solo-no-pr dodatkowo nie rób:
- pomijania self-review checklisty tylko dlatego, że nie ma PR
- bezpośrednich zmian na `main` bez brancha feature

---

### ✅ Definition of Done dla brancha feature

Branch można scalić, jeśli:
- feature jest zgodny ze specyfikacją
- BDD i testy opisują aktualne zachowanie
- build + test + lint przechodzą
- kod nie zawiera martwych fragmentów
- duplikacja została usunięta lub jawnie zapisana do extraction
- dokumentacja feature została zsynchronizowana
- branch jest gotowy do usunięcia po merge

---

### 🔥 Najkrótsza reguła operacyjna

```text
small branch → small diff → fast review → safe merge
```

Git workflow ma zmniejszać ryzyko i koszt zmian.
Nie ma być biurokracją.
