## Lifecycle feature (Playbook projection)

Cel:
Ten dokument jest projekcja operacyjna lifecycle OP typu Feature.
Kanoniczny lifecycle i guardy sa w layers/op/state-machines.md.

## Granice feature

Nowy feature:
- nowe zachowanie biznesowe
- nowa odpowiedzialnosc

Rozszerzenie feature:
- wariant istniejacego zachowania
- brak nowego kontekstu

Zasada:
Feature = jedna odpowiedzialnosc

Playbook projection:
idea -> feature(s) -> feature PRD -> UX contract -> BDD -> testy -> implementacja -> walidacja -> stabilizacja -> release-ready

## Interpretacja etapow

- idea: wpis w ideas.md
- feature(s): scoping idei
- feature PRD: kontrakt feature
- UX contract: kontrakt interakcji
- BDD: scenariusze zachowania
- testy: wykonywalna specyfikacja
- implementacja: dopasowanie kodu do testow
- walidacja: build + test + lint
- stabilizacja: cleanup + sync dokumentacji
- release-ready: gotowosc do OP Release

## Kroki

1. Idea
Wpisz pomysl do .ai/ideas.md.

2. Idea to Feature(s)
Podejmij decyzje operatorska o zakresie i odroczeniach.

2a. OP seed
Przed specyfikacja wykonaj mapowanie OP i triggerow:
- jakie OP beda modyfikowane
- jakie eventy zajda
- jakie PromptTask musza powstac

Szczegoly:
- layers/op/object-catalog.md
- layers/op/state-machines.md
- layers/op/trigger-rules.md

3. Spec
Utworz feature capsule:
- prd.md
- bdd.md
- tasks.md
- notes.md
- traceability.md

4. UX contract
Zdefiniuj stany, widocznosc i dostepnosc akcji.

5. BDD
Opisz scenariusze.

6. Testy
Wygeneruj lub popraw testy.

6a. Traceability
Powiaz reguly z prd z scenariuszami bdd.

7. Implementacja
Kod dopiero po scenariuszach i testach.

7a. Gate operatorski
Decyzje gate sa kanoniczne w OP Layer.
Operator podejmuje decyzje na podstawie review package.

8. Stabilizacja
Porownaj kod z prd i bdd, usun dead code, zaktualizuj notes i traceability.

9. Integration hardening
Sprawdz duplikacje, dryf dokumentacji i gotowosc UI.

10. Release handoff
Przekaz feature do OP Release/Deployment zgodnie z guardami OP.

## Lifecycle projektu

setup -> feature loop -> stabilizacja -> rozwoj

Szczegoly:
- workflow/setup.md
- workflow/daily-workflow.md
- workflow/session-closure.md
