# Navigation Model

## Model nawigacji
- Lewy panel: etapy procesu (timeline)
- Środek: aktywny krok
- Prawy panel: kontekst i artefakty (read-only + diff)

## Reguły nawigacji
- Domyślnie otwarty jest tylko aktywny krok.
- Przejście do kroku następnego jest możliwe dopiero po spełnieniu gate.
- Krok wcześniejszy jest zawsze dostępny do podglądu.
- Wejście w edycję kroku wcześniejszego pokazuje ostrzeżenie o invalidation downstream.

## Widoki minimalne
- Setup View
- Product Docs View
- Idea Registry View
- Feature Pipeline View (Features/PRD/UX/BDD/Tests/Implementation/Validation)
- Stabilization View
