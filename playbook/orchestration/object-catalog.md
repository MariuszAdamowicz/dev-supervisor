## Object Catalog (OP: Obiekt Procesu)

Cel: kazdy element procesu jest modelowany jako Obiekt Procesu (OP) z wlasnym cyklem zycia, CRUD i relacjami.

## Canonical typy OP

### OP: Project
- Rola: instancja projektu zarzadzana przez DS.
- CRUD: create (inicjalizacja), read (otwarcie), update (zmiana metadanych/profili), delete (usuniecie projektu).
- Kluczowe pola: `name`, `description`, `profiles`.

### OP: Idea
- Rola: luzna koncepcja biznesowa.
- CRUD: create/update/delete w backlogu idei.
- Kluczowe pola: `title`, `description`, `status`.

### OP: Feature
- Rola: jednostka implementacyjna wynikajaca z idei.
- CRUD: create (po scoping), update (spec/tests/code), archive (po stabilizacji).
- Kluczowe pola: `feature-id`, `scope`, `status`, `deferred-items`.

### OP: Term
- Rola: pojecie domenowe i UX.
- CRUD: create/update/deprecate.
- Kluczowe pola: `term`, `definition`, `status`, `source`, `aliases`.

### OP: UIComponent
- Rola: komponent interfejsu operatora lub produktu.
- CRUD: create/update/deprecate.
- Kluczowe pola: `component-id`, `purpose`, `entry-points`, `visibility-rules`.

### OP: UIScreen
- Rola: ekran/widok agregujacy komponenty.
- CRUD: create/update/deprecate.
- Kluczowe pola: `screen-id`, `state-binding`, `components`.

### OP: PromptTask
- Rola: zadanie wygenerowania promptu i/lub wykonania kroku przez operatora/AI.
- CRUD: create/complete/cancel.
- Kluczowe pola: `task-type`, `context`, `target-op`, `status`.

### OP: GateDecision
- Rola: jawna decyzja operatora po review package.
- CRUD: create (decyzja), read (audyt).
- Kluczowe pola: `gate-type`, `decision`, `reason`, `timestamp`.

### OP: Scenario
- Rola: scenariusz BDD i jego slad testowy.
- CRUD: create/update/archive.
- Kluczowe pola: `scenario-id`, `feature-id`, `test-links`, `status`.

## Relacje miedzy OP (minimalny graf)
- `Project -> Idea`
- `Idea -> Feature`
- `Feature -> Scenario`
- `Feature -> Term`
- `Term -> UIComponent`
- `UIComponent -> UIScreen`
- `Feature -> PromptTask`
- `PromptTask -> GateDecision`

## Zasada obowiazkowa
- Kazda zmiana w projekcie musi dac sie opisac jako operacja CRUD na co najmniej jednym OP.
- Brak mapowania zmiany do OP oznacza brak gotowosci do implementacji.
