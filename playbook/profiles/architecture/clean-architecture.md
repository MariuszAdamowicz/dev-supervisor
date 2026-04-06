## Clean Architecture

## Model
- Entities
- Use Cases
- Interface Adapters
- Frameworks & Drivers

## Reguły
- zaleznosci kieruja sie do srodka (Dependency Rule)
- encje i use-case nie zaleza od frameworkow, UI, DB i transportu
- adaptery mapuja PortContract na implementacje techniczne
- przez granice przechodza DTO, nie typy frameworkowe
- wiring implementacji odbywa sie w jednym composition root
- testy UseCase/Entities dzialaja bez infrastruktury
- brak cykli zaleznosci miedzy komponentami jest wymaganiem bramki architektonicznej

## Projekcja na OP
- Feature musi byc powiazany z UseCase przed `Feature.implemented`
- kazda granica adapterowa ma PortContract.approved
- komponenty krytyczne przechodza `Component.checked -> Component.compliant`
