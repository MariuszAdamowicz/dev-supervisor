## State Machines (per OP)

## OP: Project
```text
created -> configured -> active -> archived
```

Przejscia:
- `created -> configured`: wybrane profile + zapis konfiguracji.
- `configured -> active`: Product Baseline Gate zatwierdzony.
- `active -> archived`: decyzja operatora o zamknieciu projektu.

## OP: Idea
```text
captured -> scoped -> converted | dropped
```

Przejscia:
- `captured -> scoped`: wykonano idea -> feature(s).
- `scoped -> converted`: utworzono co najmniej jeden feature.
- `scoped -> dropped`: decyzja operatora o odrzuceniu.

## OP: Feature
```text
drafted -> specified -> ux-aligned -> scenario-ready -> test-ready -> implemented -> stabilized -> done
```

Przejscia:
- `drafted -> specified`: gotowe `prd.md`.
- `specified -> ux-aligned`: gotowy UX contract.
- `ux-aligned -> scenario-ready`: gotowe `bdd.md`.
- `scenario-ready -> test-ready`: testy wygenerowane/zaktualizowane.
- `test-ready -> implemented`: implementacja zgodna z testami.
- `implemented -> stabilized`: cleanup + docs sync.
- `stabilized -> done`: gate operatora `approve`.

## OP: Term
```text
proposed -> approved -> deprecated
```

Przejscia:
- `proposed -> approved`: zatwierdzenie operatora.
- `approved -> deprecated`: termin zastapiony/usuniety.

## OP: UIComponent
```text
proposed -> mapped -> implemented -> verified -> deprecated
```

Przejscia:
- `proposed -> mapped`: komponent osadzony w mapie UI/UX.
- `mapped -> implemented`: kod komponentu dodany.
- `implemented -> verified`: testy i visibility rules przechodza.

## OP: PromptTask
```text
created -> ready -> executed -> closed | cancelled
```

Przejscia:
- `created -> ready`: kontekst minimalny zbudowany.
- `ready -> executed`: operator uruchomil prompt.
- `executed -> closed`: wynik zwalidowany i powiazany z OP.

## OP: GateDecision
```text
recorded
```

Wartosci decyzji:
- `approve`
- `request_changes`
- `defer`
- `reject`

## Regula spojnosci stanu
- Stan OP nizszego poziomu nie moze wyprzedzac OP nadrzednego.
- Przyklad: `UIComponent=implemented` przy `Feature=specified` jest niedozwolone.
