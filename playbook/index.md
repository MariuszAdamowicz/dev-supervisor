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
Reguly globalne i niezmienne fundamenty procesu.

### workflow
Procedury wykonywania pracy.

### experience
Warstwa UX/interaction orchestration dla operatora.

### profiles
Nakladki konfiguracyjne dla konkretnego kontekstu.

### prompts
Kanoniczne prompty robocze per etap.

### templates
Gotowe wzorce plikow AI i skryptow.

## Moduly OP Layer

### orchestration
Warstwa obiektow procesu i regul reakcji (event-driven):
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
2. Start od core/ jako zasad nadrzednych.
3. Wybierz i dolacz profile.
4. Domknij Product Gate (overview.md, constraints.md, glossary.md + decyzja operatora).
5. Zdefiniuj UX orchestration w experience/*.
6. Realizuj prace przez workflow/daily-workflow.md.
7. Uzywaj promptow kanonicznych z prompts/*.
8. Kazda iteracje zamykaj review package i decyzja operatora.
9. Zamykaj iteracje checklistami i workflow/session-closure.md.

## Zaktualizowany Lifecycle

idea -> feature(s) -> PRD -> UX contract -> BDD -> tests -> implementation -> validation -> stabilization

Szczegoly lifecycle:
- core/feature-lifecycle.md
