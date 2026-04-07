# Authz Permissions Correctas

## Stan obecny przed zmianami

Model OP i validation wspominaly `ActorRolePermission`, ale exec spec i bindings nie wymuszaly operacyjnego authz precheck dla realnych entrypointow.
Skutek:
- latwo bylo miec authz w teorii, a nie w runtime.

## CRUD dla punktu

Create:
- `ActorRolePermission` istnialo w katalogu OP, ale nie bylo wymuszane w baseline runtime.

Read:
- brak gwarancji, ze operator widzi swoj scope i przyczyne deny.

Update:
- permission revise/revoke bylo w FSM, ale bez twardego wpiecia w entrypointy runtime.

Remove:
- revoke bylo opisane, ale brakowalo deny-by-default i sciezki `Exception(authz)` na poziomie wykonawczym.

## Praktyki zewnetrzne

- OWASP Authorization Cheat Sheet: deny by default, validate on every request, tworz testy autoryzacyjne.
- NIST AC-6: least privilege.

Linki:
- https://cheatsheetseries.owasp.org/cheatsheets/Authorization_Cheat_Sheet.html
- https://cheatsheetseries.owasp.org/cheatsheets/Transaction_Authorization_Cheat_Sheet.html
- https://tsapps.nist.gov/publication/get_pdf.cfm?pub_id=933932

## Plan zmian

1. Dodac `policy-engine` jako narzedzie baseline.
2. Dodac authz precheck do exec spec i template execution.
3. Wymusic `ActorRolePermission` w baseline.
4. Dodac deny-by-default do validation contract.

## Czy plan domyka problem

Tak. Problemem byla nieobecnosc authz w runtime contract, nie brak samego OP. Po poprawce authz jest twarda czescia flow wykonawczego.

## Wprowadzone zmiany

- `playbook/tooling/tool-registry.md` ma `policy-engine`,
- `playbook/tooling/action-catalog.md` ma `authorize_transition`,
- `playbook/tooling/bindings.md` ma globalny runtime precheck,
- `playbook/runtime/playbook-exec.yaml` ma `authz_contract`, `policy-engine` contract i precheck steps `NP-03A` / `AI-01A`,
- `playbook/validation/playbook-contracts.md` wzmacnia `Permission contract`.

## Podsumowanie

Authz przestal byc deklaracja modelowa. Stal sie wymogiem wykonawczym i walidacyjnym, z deny-by-default i obowiazkiem sciezki odmowy.
