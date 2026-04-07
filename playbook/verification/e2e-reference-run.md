# E2E Reference Run

Cel:
zweryfikowac playbook na realnym mini-projekcie (niewielki zakres, pelny proces).

## Zakres referencyjny
- 1 Project
- 1 Idea
- 1 Feature
- 2-3 Scenario
- co najmniej 1 Requirement, 1 Constraint, 1 DecisionRecord
- co najmniej 1 UseCase, 1 PortContract, 1 Component
- co najmniej 1 ActorRolePermission
- co najmniej 1 artefakt `.ai/ux/*` powstaly z runtime

## Procedura
1. Setup projektu i baseline gate.
2. Przejscie Feature przez spec/test/implement/stabilize/release.
3. Co najmniej jedna sciezka non-happy (request_changes albo defer).
4. Co najmniej jeden incydent operacyjny (deployment.failed lub timeout.fired).
5. Domkniecie do Feature.done lub jawne zatrzymanie z decyzja GateDecision.

## Evidence wymagane
- ProcessEvent log
- GateDecision log
- Review packages dla gate-required transitions
- Wyniki build/test/lint (lane kontraktowy i lane binarny aplikacji)
- Runtime snapshot przed i po runie
- provenance metadata dla kazdego dowodu
- evidence class rozrozniajaca fixture od real runtime capture

## Kryterium PASS
- brak silent transitions
- brak nielegalnych przejsc FSM
- komplet audytu i decyzji gate
- legalny final state dla wszystkich zmienianych OP
- lane binarny aplikacji (build/test/lint) ma status pass
- istnieje co najmniej jeden dowod klasy `runtime-capture`
