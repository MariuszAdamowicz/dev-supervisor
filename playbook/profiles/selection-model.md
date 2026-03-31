## Model wyboru profili

Cel: uniknąć losowej konfiguracji projektu i wymusić spójny, powtarzalny setup playbooka.

## Dwie klasy profili

### 1. Solution Profiles (jak budujemy produkt)
- `stack/*`
- `architecture/*`

### 2. DS Operation Profiles (jak pracuje operator i DS)
- `language/*`
- `execution-style/*`
- `storage/*`

## Minimalny zestaw wyborów (MVP inicjalizacji)

Wymagane dokładnie po jednym:
- stack
- architecture
- language
- execution-style
- storage

## Zależności i reguły kompatybilności

### Reguły ogólne
- `stack` determinuje narzędzia build/test/lint i szablony skryptów.
- `architecture` determinuje podział modułów i reguły extraction.
- `execution-style` determinuje kolejność kroków implementacji, ale nie zmienia source-of-truth.
- `storage` determinuje lokalizację artefaktów procesu (`.ai/` lub SQLBase), ale nie zmienia lifecycle.
- `language` determinuje język dokumentacji i promptów operatora.

### Reguły konfliktów
- Brak `storage` = brak możliwości uruchomienia procesu.
- Brak `execution-style` = brak jednoznacznej pętli implementacyjnej.
- Jeśli `stack` wymaga narzędzi niedostępnych lokalnie, setup jest niekompletny.

### Reguły override
- Profile nie mogą nadpisywać `core/*`.
- Profile mogą uszczegóławiać `workflow/*` wyłącznie przez dodatki operacyjne.

## NFR Gate przed finalizacją wyboru architektury

Przed zatwierdzeniem profili operator zapisuje minimalne NFR:
- wydajność
- niezawodność
- bezpieczeństwo
- utrzymywalność
- obserwowalność

Jeśli NFR są niejawne lub sprzeczne, inicjalizacja nie przechodzi gate.

## Format zapisu wybranej konfiguracji

Rekomendowany plik: `.ai/playbook-profile.md`

Minimalna zawartość:
```text
stack: <wybrany-stack>
architecture: <wybrana-architektura>
language: <pl|en>
execution-style: <iterative-tdd|batch-feature|hybrid>
storage: <file-ai|sqlbase>
```

## Walidacja po wyborze

Po wyborze profili DS wykonuje:
1. kontrolę kompletności 5/5,
2. kontrolę kompatybilności,
3. bootstrap struktury `.ai/` lub SQLBase,
4. wygenerowanie checklisty setup.
