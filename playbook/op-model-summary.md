# OP Model Summary

Cel:
zapisac aktualny, odchudzony model procesu po iteracjach redukcji
oraz uzasadnic, dlaczego obecny rdzen OP powinien byc traktowany jako
minimalny zdrowy zestaw dla DevSupervisor.

## 1. Aktywny rdzen OP

Aktualnie aktywne OP:
1. `Project`
2. `Requirement`
3. `Constraint`
4. `Idea`
5. `Feature`
6. `Scenario`
7. `UIComponent`
8. `UIScreen`
9. `UseCase`
10. `PortContract`
11. `Component`
12. `ChangeSet`
13. `DataSchema`

To sa byty, ktore jednoczesnie:
- opisuja stan projektu albo produktu,
- maja wlasny lifecycle i legalne przejscia,
- invaliduja downstream scope,
- musza byc czytane i korygowane przez DS jako kanoniczny stan projektu.

## 2. Co zostalo wydzielone z OP

Z modelu OP zostaly wydzielone:
- system records:
  - `GateDecisionRecord`
  - `ProcessEventRecord`
  - `QualityEvidenceRecord`
- controls:
  - `DecisionRecord`
  - `VerificationPolicy`
  - `AccessGrant`
  - `GlossaryEntry`
  - `RiskEntry`
  - `ExceptionCase`
  - `EnvironmentTarget`
  - `ReleaseBundle`
  - `DeploymentRun`
  - `PromptTask`
  - `RollbackAction`
  - `CompensationAction`
  - `MigrationAction`
  - `Repository`
  - `SchedulerTimer`
- graph relation:
  - `DependencyRelation`

Powod wydzielenia byl wspolny:
- nie sa to samodzielne artefakty produktu,
- sa to runtime handles, policy controls, recovery controls albo audit records,
- musza byc jawne i mutowalne, ale nie musza obciazac glownego katalogu OP.

## 3. Dlaczego ten rdzen ma sens

### `Project`
Kotwica parent linkage, baseline i ownership.

### `Requirement` i `Constraint`
To nie sa notatki. Oba byty zyja, rewiduja sie i invaliduja downstream.
Bez nich baseline szybko wraca do tekstow bez egzekucji procesowej.

### `Idea`
To lekki, ale nadal potrzebny byt discovery.
Chroni przed gubieniem odrzuconych lub odlozonych pomyslow
i daje trace do pochodzenia `Feature`.

### `Feature`
Glowna jednostka dostarczania zachowania.

### `Scenario`
Kotwica BDD i wykonywalnej semantyki zachowania.

### `UIComponent` i `UIScreen`
To potrzebny rdzen dla task-first projection i kontroli UX/invalidation.

### `UseCase`, `PortContract`, `Component`
To rdzen architektoniczny i granice aplikacji.
Bez nich playbook znowu zaczalby gubic boundary, DTO i dependency rules.

### `ChangeSet`
To nadal samodzielny pakiet pracy.
Spina pliki, traceability, commit scope i lane walidacyjne.
Nie powinien byc tylko control.

### `DataSchema`
Stan danych jest stanem projektu, nie tylko runtime policy.
Dlatego `DataSchema` zostaje, mimo ze `MigrationAction` zostalo wydzielone.

## 4. Co uznajemy teraz za granice dalszej redukcji

Na tym etapie dalsze ciecie nie powinno byc automatyczne.

Szczegolnie:
- `Idea` nie powinna byc redukowana, dopoki DS ma wspierac discovery i intake.
- `Constraint` nie powinien byc redukowany, dopoki ograniczenia maja byc egzekwowalne i invalidowac downstream.
- `ChangeSet` nie powinien byc redukowany, dopoki commit scope, traceability i walidacja zmiany sa first-class.
- `DataSchema` nie powinno byc redukowane, dopoki stan danych jest czescia stanu projektu.

## 5. Zasada na przyszlosc

Nowy byt powinien zostac OP tylko wtedy, gdy lacznie:
- reprezentuje stan projektu albo produktu,
- ma niezalezny lifecycle,
- ma CRUD z semantycznym remove,
- bierze udzial w propagacji downstream,
- musi byc widoczny dla operatora jako czesc kanonicznego stanu projektu.

Jesli byt jest glownie:
- audit trail,
- runtime handle,
- gate/policy control,
- relation edge,
- scheduler/recovery wrapper,

to powinien trafic do `records`, `controls` albo `relations`,
a nie do glownego katalogu OP.

## 6. Wniosek

Obecny model `13` OP jest najblizej minimalnego zdrowego rdzenia.
Jest juz znacznie lzejszy niz model poczatkowy,
ale nadal zachowuje stan produktu, architektury, UX, BDD, zmiany kodu i danych.

Dalsze iteracje powinny teraz bardziej koncentrowac sie na:
- relacjach i invalidation,
- schedulerze runtime,
- projection operatora,
- zgodnosci aplikacji z tym modelem,

a nie na dalszym mechanicznym zmniejszaniu liczby OP.
