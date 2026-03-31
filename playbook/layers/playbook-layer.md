# Playbook Layer

Rola:
- projekcja OP na prace operatora.

Zakres:
- profile konfiguracji,
- projection rules (OP -> UI/Prompt/Checklist),
- biblioteka promptow i templatek,
- polityki operacyjne i jakosciowe.

Moduly tej warstwy:
- ../core/*
- ../workflow/*
- ../experience/*
- ../profiles/*
- ../prompts/*
- ../templates/*

Kontrakt wobec OP Layer:
- nie duplikuje definicji OP,
- nie zmienia semantyki triggerow i gate,
- nie definiuje alternatywnych state transitions,
- wyznacza dzialanie operatora na bazie next_transition z OP.

Czego ta warstwa NIE robi:
- nie jest runtime storage projektu,
- nie jest implementacja kodu produktu,
- nie jest zrodlem semantyki procesu.
