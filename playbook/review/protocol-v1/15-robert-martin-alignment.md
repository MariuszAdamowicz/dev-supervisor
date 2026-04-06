# Robert Martin Rules Alignment (Rule-by-Rule)

Status: completed
Data: 2026-04-07
Zrodlo: `rules/robert-martin-architecture-rules.md`

## Metoda
1. Kazda zasada zostala sklasyfikowana jako `covered`, `partial` albo `missing`.
2. Dla `partial` i `missing` wykonano zmiany w OP Layer i Playbook Layer.
3. Wynik koncowy ponizej pokazuje stan po patchach.

## A. Cel architektury
1. Koszt zmian jako metryka jakosci: `covered` (`core/principles.md`).
2. Latwa modyfikowalnosc bez chaosu: `covered` (`core/principles.md`, `validation/playbook-contracts.md`).
3. Latwosc zmian reguly biznesowej i testow: `covered` (`workflow/checklists.md`, `validation/playbook-contracts.md`).
4. Odkladanie nieodwracalnych decyzji: `covered` (`core/principles.md`).
5. Framework/DB/deploy jako szczegoly: `covered` (`profiles/architecture/clean-architecture.md`).

## B. Model warstw i kierunek zaleznosci
1. Encje jako trwale reguly: `covered` (profile clean/hexagonal).
2. UseCase jako logika aplikacyjna: `covered` przez nowy OP `UseCase`.
3. Adaptery jako translacja granic: `covered` przez OP `PortContract` + profile architektury.
4. Frameworki i sterowniki na obrzezach: `covered` (profile architektury).
5. Zaleznosci do srodka: `covered` (kontrakty walidacyjne + checklisty).

## C. Reguly podstawowe (sekcja 3 dokumentu)
1. Use-case first: `covered` (core + nowe OP `UseCase`).
2. Architektura ma krzyczec domena: `covered` (profile architektury, checklista architektury).
3. Biznes dziala bez UI/DB/sieci: `covered` (Testability contract).
4. Technologia nie definiuje domeny: `covered` (core + profile).
5. Polityki blisko centrum: `covered` (Dependency rule contract).
6. Szczegoly na obrzezach: `covered` (clean/hexagonal).
7. Granice wg odpowiedzialnosci i zmian: `covered` (UseCase + PortContract + Component).
8. Przez granice przechodza proste dane: `covered` (PortContract DTO rule).
9. Izolacja niestabilnosci: `covered` (Component checks + contracts).
10. Wymienialnosc szczegolow: `covered` (PortContract + composition root).

## D. Regula zaleznosci (sekcja 4)
1. Kod wewnetrzny nie zna zewnetrznego: `covered`.
2. Domena nie zna bazy: `covered`.
3. Domena nie zna web: `covered`.
4. Domena nie zna UI frameworka: `covered`.
5. UseCase bez importu infrastruktury: `covered`.
6. Zewnetrzne zalezne od wewnetrznych: `covered`.
7. Integracje za portami/interfejsami/kontraktami: `covered`.
8. Podpiecie implementacji na krawedzi w composition root: `covered`.

## E. SOLID (sekcja 5)
1. SRP: `covered` (Component responsibility + negative rules).
2. OCP: `partial -> covered` (wzmocnione przez PortContract i use-case-first).
3. LSP: `partial` (monitorowane przez review i testy kontraktowe, bez osobnego OP).
4. ISP: `partial -> covered` (PortContract jako male kontrakty granic).
5. DIP: `covered` (dependency inversion + composition root contract).

## F. Zasady komponentow (sekcja 6)
1. REP: `partial` (egzekwowane przez Component responsibility i mapping).
2. CCP: `covered` (Component OP, odpowiedzialnosc i refactor-required).
3. CRP: `covered` (dependency checks + kontrakt granic).
4. ADP (brak cykli): `covered` (No-cycle contract + Component lifecycle).
5. SDP: `covered` (checklista architektury + component checks).
6. SAP: `covered` (component stability/abstraction fields + review package).

## G. Reguly kodu i testow (sekcje 7-8)
1. Nazwy domenowe i czytelnosc: `covered` (core/checklisty).
2. Jawna obsluga bledow i efekty uboczne na krawedzi: `covered`.
3. Brak global mutowalnych przeciekow i leakow formatu danych: `covered`.
4. Testy zachowania zamiast detali: `covered`.
5. Testowalnosc core bez infrastruktury: `covered` (Testability contract).

## H. Zasady praktyczne i sygnaly ostrzegawcze (sekcje 9-10)
1. Start od domeny/use-case: `covered`.
2. Modularny monolit jako domyslna strategia: `covered` (profil architecture).
3. Brak logiki biznesowej w kontrolerach/widokach/repo: `covered` (negatywne zasady + audyty).
4. DTO na granicach, adapter wymienialny: `covered`.
5. Brak cykli i DB-nie-jako-serce: `covered`.
6. Kazdy wazny use-case ma test niezalezny od infrastruktury: `covered`.

## Nowe OP dodane przez ten przeglad
1. `UseCase` - modeluje logike aplikacyjna niezalezna od frameworka.
2. `PortContract` - formalizuje granice rdzen <-> adapter i DTO.
3. `Component` - egzekwuje reguly zaleznosci (ADP/SDP/SAP).

## Zmodyfikowane warstwy playbooka
1. OP Layer: `object-catalog.md`, `state-machines.md`, `trigger-rules.md`.
2. Playbook core/profile: `core/principles.md`, `profiles/architecture/*.md`.
3. Workflow/validation/tooling: `workflow/setup.md`, `workflow/daily-workflow.md`, `workflow/checklists.md`, `validation/playbook-contracts.md`, `tooling/bindings.md`.

## Wniosek
Po patchach zasady Martina sa pokryte operacyjnie i audytowalnie: nie tylko jako opis, ale jako lifecycle, trigger, binding, guard i kontrakty walidacyjne.
