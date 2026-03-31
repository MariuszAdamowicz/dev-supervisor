# Modular Playbook System

Ten playbook jest podzielony na moduly, aby utrzymac minimalny kontekst, spojne zrodla prawdy i przewidywalny workflow AI-driven development.

Canonical source:
- playbook/* w repozytorium dev-supervisor

Historyczne zrodlo referencyjne:
- operacyjny_playbook_v8.md (monolit)

## Jawny Model Warstw

Nadrzedny podzial systemu jest opisany w:
- layers/index.md

Warstwy nadrzedne:
1. OP Layer
2. Playbook Layer
3. Project Instance Layer

## Product Direction Guardrails

- dev-supervisor jest deterministic supervisor, nie agent AI.
- Proces jest operator-driven: czlowiek uruchamia prompty w zewnetrznym narzedziu.
- Operator podejmuje jawne decyzje na gate.
- System pozostaje local-first.
- System pozostaje tool-agnostic i provider-agnostic.

## Moduly Playbook Layer

### core
Reguly globalne i polityki operacyjne.

### workflow
Reguly uruchamiania pracy jako OP-driven entrypoints.

### experience
Projection OP -> UI/UX dla operatora.

### profiles
Nakladki konfiguracyjne dla kontekstu projektu i pracy.

### prompts
Kanoniczne prompty robocze per etap.

### templates
Gotowe wzorce plikow AI i skryptow.

### tooling
Warstwa wykonawcza Playbook Layer:
- tool registry
- action catalog
- OP -> Action -> Tool bindings

## Moduly OP Layer

### layers/op
Kanoniczna warstwa OP (event-driven):
- katalog OP
- maszyny stanow OP
- triggery event -> prompt task -> gate

Pliki kanoniczne:
- layers/op/object-catalog.md
- layers/op/state-machines.md
- layers/op/trigger-rules.md

## Example Configuration

- stack: macos-swiftui
- architecture: modular-monolith
- language: pl
- execution-style: iterative-tdd
- storage: file-ai

## How To Use

Moduly obowiazkowe:
- core/*
- workflow/*
- experience/*
- layers/op/*
- tooling/*
- jeden profil stack/*
- jeden profil architecture/*
- jeden profil language/*
- jeden profil execution-style/*
- jeden profil storage/*

Moduly kontekstowe:
- prompts/*
- templates/*
- opcjonalnie profil git-solo-no-pr.md

Sposob kompozycji:
1. Start od modelu warstw: layers/index.md
2. Wybierz i dolacz profile.
3. Domknij Product Gate (baseline produktu).
4. Wybierz entrypoint OP.
5. Wyznacz next_transition z OP Layer.
6. Wygeneruj projection OP -> UI/Prompt/Checklist.
7. Wyznacz Action i Tool plan z tooling/*.
8. Wykonaj akcje, walidacje i GateDecision.
9. Powtorz az do domkniecia celu runtime.

## Zasada wykonania

Playbook nie prowadzi recznego pipeline krok po kroku.
Playbook prowadzi operatora przez kolejne transitions wynikajace z OP Layer.
