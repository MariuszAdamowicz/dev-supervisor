# Playbook Review Protocol v1 — Krok 2: Macierz Interferencji OP

Data UTC: 2026-04-03T22:18:00Z

## Źródła
- `playbook/layers/op/object-catalog.md`
- `playbook/layers/op/state-machines.md`
- `playbook/layers/op/trigger-rules.md`
- `playbook/tooling/bindings.md`

## Cel kroku
Jawnie zmapować interferencje między OP oraz wskazać, gdzie semantyka OP nie ma pokrycia operacyjnego w bindingach.

## Macierz interferencji (skrót operacyjny)

| OP | Wejścia (kto wpływa) | Wyjścia (na co wpływa) | Pokrycie bindingami |
|---|---|---|---|
| Project | operator-ui, GateDecision | baseline/runtime, Feature entrypoint | częściowe |
| Requirement | Project | Feature | brak |
| Constraint | Project | DecisionRecord, Feature | brak |
| DecisionRecord | Constraint, operator | Feature | brak |
| Idea | operator, Project | Feature, PromptTask | częściowe |
| Feature | Idea, Scenario, GateDecision, QualitySignal | Release, Term, PromptTask | częściowe |
| Scenario | Feature | testy, Feature.test-ready | częściowe |
| Term | Feature, operator | UIComponent, Scenario | częściowe |
| UIComponent | Term, operator | UIScreen, UX validation | częściowe |
| UIScreen | UIComponent, operator | UX gate | częściowe |
| PromptTask | Feature/Term/UI, AI runner | GateDecision, review package | częściowe |
| GateDecision | operator, review package | odblokowanie transition OP | częściowe |
| ActorRolePermission | operator/admin | autoryzacja akcji | brak egzekucji |
| Dependency | Feature | guardy release | częściowe |
| Risk | Feature/Quality | gate/rework/escalation | brak |
| Release | Feature.stabilized | Deployment | częściowe |
| Deployment | Release.approved | Rollback/Compensation | częściowe |
| Rollback | Deployment.failed | Compensation, zamknięcie incydentu | częściowe |
| QualitySignal | validation suite | GateDecision, Exception | częściowe |
| Exception | Quality/Timeout/Authz | Compensation, GateDecision | częściowe |
| Timeout | scheduler | Exception, GateDecision.defer | częściowe |
| Compensation | Exception/Timeout/Deployment.failed | zamknięcie błędu krytycznego | częściowe |
| ProcessEvent | wszystkie OP | audit trail | częściowe (format doprecyzowany tylko dla file-ai v1) |

## Luki krytyczne wykryte deterministycznie

1. Brak pełnego domknięcia lifecycle wielu OP w `bindings.md`:
- `Feature.stabilized -> Feature.released -> Feature.done`
- `Release.approved -> Release.published -> Release.closed`
- `Project.active -> Project.archived`
- `PromptTask.executed -> PromptTask.validated -> PromptTask.closed`
- `Scenario.approved -> Scenario.test-linked -> Scenario.passing`

2. Brak operacyjnego pokrycia OP z katalogu:
- `Requirement`, `Constraint`, `DecisionRecord`, `Risk`, `ActorRolePermission` (semantyka istnieje, brak workflow/bindingów wykonawczych).

3. Niejawny obszar decyzji gate:
- Playbook wymaga `decide_gate`, ale nie definiuje standardowego "Decision Envelope" (pełny zakres zmiany + dowody + ryzyka + skutki decyzji).

4. Interferencje OP są opisowe, ale nie kontraktowe:
- relacje w `object-catalog.md` są grafem statycznym, bez jawnych reguł propagacji stanu między OP (np. co dokładnie dzieje się z Feature po `Deployment.succeeded`).

5. Niespójność granularności transition:
- binding `Deployment.prepared -> Deployment.running -> Deployment.succeeded` scala dwa przejścia, podczas gdy model OP wymaga pojedynczych przejść z osobnym event/guard/audit.

## Analiza kroku: czy to był właściwy krok?
Tak. Bez jawnej macierzy interferencji nie da się deterministycznie ocenić, czy kolejne kroki użytkownika są legalne i kompletne.

## Analiza alternatywy: co mogło być inne?
Można było zacząć od testów end-to-end, ale bez macierzy interferencji wykryte problemy byłyby objawowe, nie przyczynowe.

## Dowód kroku
Artefakt: `playbook/review/protocol-v1/02-op-interference-matrix.md`

## Następny krok
Krok 3: Kontrakt "Decision Envelope" i lista gate-required transition z wymaganym pakietem dowodowym per gate.
