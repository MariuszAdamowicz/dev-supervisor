## Flutter + Dart Stack Profile

## Zakres
- aplikacja cross-platform: Flutter
- język: Dart
- testy: widget + integration

## Setup platform-specific
- skonfiguruj Flutter SDK
- skonfiguruj `flutter test` i `flutter analyze`
- skonfiguruj build profile dla target platform

## Script expectations
- `Scripts/build.sh` uruchamia `flutter build` dla targetu
- `Scripts/test.sh` uruchamia testy widget/integration
- `Scripts/lint.sh` uruchamia `flutter analyze` + format-check
