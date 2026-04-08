# Risk Contracts (kanoniczne)

Cel:
opisac mutowalne wpisy rejestru ryzyka,
ktore nie sa samodzielnymi OP, ale maja jawny status,
resolution path, blocker projection i audit.

Risk control nie jest:
- OP z pelnym lifecycle produktu,
- system recordem append-only,
- ukryta notatka w review package albo TODO.

Risk control jest:
- mutowalnym wpisem rejestru ryzyka dla feature, changeset, release albo runtime,
- bytem queryable po scope, criticality i statusie,
- nosnikiem decyzji `mitigate|accept|escalate` i blockerem dla delivery.

## Kontrakt wspolny risk control

Kazdy risk control ma pola:
- `risk_id`
- `subject_ref`
- `risk_class`
- `probability`
- `impact`
- `criticality`
- `status`
- `owner`
- `created_at`
- `updated_at`
- `reason`

Pola opcjonalne:
- `mitigation_plan`
- `waiver_ref`
- `evidence_refs`
- `replacement_ref`

Reguly:
- risk control musi byc zapisany w runtime index i reverse lookup po `subject_ref`,
- mutacja risk control wymaga `ProcessEventRecord`,
- brak reverse lookup uniewaznia projection blockerow delivery,
- risk control nie moze byc schowany przed operatorem, gdy ma status `escalated` albo `criticality=high|critical`.

## RiskEntry

Rola:
opisuje pojedynczy wpis rejestru ryzyka
powiazany z konkretnym scope procesu albo produktu.

Punkty odniesienia:
- NIST RMF: ryzyko wymaga jawnej odpowiedzi i ciaglej decyzji zarzadczej, nie tylko identyfikacji.
- OWASP Risk Rating: ocena ryzyka wymaga jawnej metodologii likelihood/impact i traktowania residual risk jako swiadomej decyzji.

### Statusy

- `identified`: ryzyko zostalo wykryte, ale nie ma jeszcze oceny.
- `assessed`: ryzyko ma ocene i czeka na resolution path.
- `mitigated`: zaplanowane lub wykonane srodki redukujace ryzyko sa zaakceptowane.
- `accepted`: residual risk zostal jawnie zaakceptowany.
- `escalated`: ryzyko wymaga decyzji operatorskiej albo blokuje delivery.
- `closed`: ryzyko zostalo domkniete i nie blokuje juz scope.

### CRUD semantics

Create:
- tworz `RiskEntry`, gdy feature, release, environment albo architektura ujawnia nowe ryzyko,
- create wymaga `subject_ref`, `risk_class`, `probability`, `impact` i wstepnego `criticality`.

Read:
- runtime musi umiec pytac:
  - `jakie ryzyka sa otwarte dla danego scope`,
  - `czy istnieje escalated risk blokujacy release`,
  - `jakie ryzyka zostaly accepted zamiast mitigated`.

Update:
- dozwolone sa tylko status changes:
  - `identified -> assessed`
  - `assessed -> mitigated | accepted | escalated`
  - `mitigated -> closed`
  - `accepted -> closed`
  - `escalated -> closed | escalated`
- update wymaga `reason`, `actor`, `ProcessEventRecord`
  i odswiezenia blocker projection dla impacted scope.

Remove:
- hard delete po pojawieniu sie audytu jest zabronione,
- semantyczne usuniecie = `closed`,
- `closed` wymaga jawnego reason i trace, czy closure nastapilo przez mitigation, acceptance czy resolution po escalation.

### Propagation

- `identified`:
  - wymaga oceny i nie powinno byc ignorowane przy kolejnych gate.
- `assessed`:
  - wymaga jawnej decyzji `mitigate|accept|escalate`.
- `mitigated`:
  - moze odblokowac delivery po closure, jesli nie ma innych blockerow.
- `accepted`:
  - nie blokuje dalej delivery, ale musi pozostac widoczne jako residual risk.
- `escalated`:
  - blokuje `ReleaseBundle.approved` albo inny krytyczny gate do czasu jawnej decyzji/closure.
- `closed`:
  - nie blokuje scope, ale pozostaje w audycie i evidence.

## Invariants

- `RiskEntry` musi wskazywac `subject_ref`, `probability`, `impact` i `criticality`,
- `assessed` bez jawnego `mitigation_plan` albo `reason` jest invalid,
- `escalated` bez blocker projection dla delivery scope jest invalid,
- `closed` bez `ProcessEventRecord` i jawnego reason jest invalid,
- risk control nie moze zniknac z indeksu po pojawieniu sie audytu.

## Zrodla praktyk

Linki:
- https://csrc.nist.gov/projects/risk-management
- https://owasp.org/www-community/OWASP_Risk_Rating_Methodology
