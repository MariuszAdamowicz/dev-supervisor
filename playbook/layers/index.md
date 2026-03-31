# Layer Model

Ten dokument formalizuje 3-warstwowy model systemu:

1. OP Layer (meta-model procesu)
2. Playbook Layer (konfiguracja i procedury)
3. Project Instance Layer (runtime projektu)

Zasada nadrzedna:
- warstwa nizsza NIE definiuje zasad warstwy wyzszej,
- warstwa wyzsza wykorzystuje kontrakty warstwy nizszej.

Przeplyw odpowiedzialnosci:
- OP Layer definiuje jezyk procesu,
- Playbook Layer mapuje ten jezyk na praktyke operatora,
- Project Instance Layer realizuje proces na konkretnym projekcie.

Dokumenty szczegolowe:
- op-layer.md
- playbook-layer.md
- project-instance-layer.md
- module-mapping.md
