# Chaos Process Tests

Cel:
sprawdzic odpornosc procesu na bledy i niepewnosc operacyjna.

## Wstrzykiwane zaklocenia
1. `timeout.fired` dla PromptTask i SchedulerTimer.
2. `authz.denied` przed transition krytycznym.
3. `QualityEvidenceRecord.fail` po implementacji.
4. `deployment.failed` w Release flow.
5. `rollback.failed` po deployment fail.
6. gate `reject` dla transition gate-required.

## Oczekiwane zachowanie
- zawsze istnieje legalna sciezka recovery/rework/escalation,
- brak przejsc poza FSM,
- kazde zaklocenie ma ProcessEventRecord,
- brak utraty spojnosc OP graph,
- authz deny nie pozostawia czesciowo zapisanych zmian.

## Kryterium PASS
Kazdy test chaos:
1. konczy sie legalnym stanem,
2. nie narusza kontraktow safety,
3. zostawia pelny slad audytowy.
