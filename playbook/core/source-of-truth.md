## 🧠 Ujednolicenie PRD i feature files

## 🧠 Źródła prawdy (Source of Truth)

Każdy element systemu ma jedno źródło prawdy:
- overview.md → czym jest produkt
- constraints.md → ograniczenia systemu
- feature/prd.md → wymagania feature
- feature/bdd.md → zachowanie feature
- testy → wykonywalna prawda

Elementy pomocnicze (NIE są źródłem prawdy):
- tasks.md → plan implementacji
- notes.md → decyzje i kontekst
- traceability.md → mapowanie

Zasada:
PRD < BDD < TESTY
Testy wygrywają zawsze.

Nie duplikuj feature speców jednocześnie w:
- `.ai/prd/features/...`
- i osobno w `Features/...`

To prowadzi do dryfu.

### Zalecany model
- globalny PRD trzymasz w `.ai/prd/`
- każdy feature trzymasz tylko w `.ai/features/<feature>/`

Czyli:
- `.ai/prd/overview.md` opisuje produkt
- `.ai/prd/constraints.md` opisuje ograniczenia
- `.ai/features/routing/prd.md` opisuje konkretny feature
- `.ai/features/routing/bdd.md` opisuje zachowanie feature
- `.ai/features/routing/traceability.md` wiąże reguły z testami

To jest prostsze, spójniejsze i bardziej AI-friendly.

### 🔥 Kluczowa zasada operacyjna

PRD NIE jest źródłem prawdy dla implementacji.

Źródło prawdy =  
👉 BDD + TESTY

PRD:
- definiuje kontrakt
- ale nie egzekwuje zachowania

Testy:
- egzekwują zachowanie
- blokują regresję
