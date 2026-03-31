# Playbook Layer

Rola:
- projekcja OP na metodologie pracy operatora.

Zakres:
- polityki procesu,
- workflow i checklisty,
- profile konfiguracji,
- warstwa UX dla operatora,
- biblioteka promptow i templatek.

Moduly tej warstwy:
- ../core/*
- ../workflow/*
- ../experience/*
- ../profiles/*
- ../prompts/*
- ../templates/*

Kontrakt wobec OP Layer:
- nie duplikuje definicji OP,
- nie zmienia semantyki triggerow,
- mapuje kroki operatora na przejscia OP.

Czego ta warstwa NIE robi:
- nie jest runtime storage projektu,
- nie jest implementacja kodu produktu.
