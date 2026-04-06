## Hexagonal Architecture (Ports & Adapters)

## Model
- domena i use-case jako rdzeń
- porty wejściowe/wyjściowe
- adaptery technologiczne na obrzeżach

## Reguły
- domena zna tylko porty, nie zna adapterów
- testy domeny działają bez zależności infrastrukturalnych
- adaptery mogą być wymieniane bez zmiany rdzenia
- porty sa kontraktami (PortContract) i operuja na DTO
- implementacje adapterow sa podpinane w composition root
- brak cykli miedzy komponentami jest wymagany
