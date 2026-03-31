## Kotlin Android Stack Profile

## Zakres
- aplikacja Android: Kotlin
- UI: Jetpack Compose
- testy: unit + instrumented

## Setup platform-specific
- skonfiguruj Android SDK i Gradle wrapper
- skonfiguruj build wariantów przez CLI
- skonfiguruj testy unit i instrumented
- skonfiguruj lint/format (ktlint/detekt)

## Script expectations
- `Scripts/build.sh` uruchamia Gradle build
- `Scripts/test.sh` uruchamia testy unit/integration
- `Scripts/lint.sh` uruchamia detekt/ktlint
