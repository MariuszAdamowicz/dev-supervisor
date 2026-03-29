## macOS + SwiftUI Stack Profile

## ⚙️ Skrypty

### Setup platform-specific
- stwórz bazowy projekt SwiftUI (można użyć Xcode jako generatora projektu)
- uruchom pierwsze buildy przez CLI
- ustaw pełne Xcode jako active developer directory
- uruchom xcodebuild -runFirstLaunch
- zainstaluj narzędzia lint/format (swiftlint, swiftformat)
- ustal i skonfiguruj schemat Xcode używany przez CLI (xcodebuild)
- wygeneruj i skonfiguruj jawny plik .xctestplan używany przez schemat testowy
- usuń lub wyłącz nieużywane test targets (np. UI tests) z Test Plan

### `Scripts/build.sh`
```bash
#!/bin/bash
set -e

SCHEME="DevSupervisor"

xcodebuild \
  -scheme "$SCHEME" \
  -configuration Debug \
  build 2>&1 | tee build.log

grep -E "error:" build.log || true
```

### `Scripts/test.sh`
```bash
#!/bin/bash
set -e

SCHEME="DevSupervisor"

xcodebuild \
  test \
  -scheme "$SCHEME" \
  -destination 'platform=macOS,arch=arm64'
```

### `Scripts/lint.sh`
```bash
#!/bin/bash
set -e
swiftlint
swiftformat .
```

## 🧹 Linter i formatowanie

### SwiftLint
Instalacja:
```bash
brew install swiftlint
```

Przykładowy `.swiftlint.yml`:
```yaml
opt_in_rules:
  - force_unwrapping
  - empty_count
  - explicit_init
disabled_rules:
  - line_length
```

### SwiftFormat
Instalacja:
```bash
brew install swiftformat
```

Uruchamianie:
```bash
swiftformat .
```

### Zasada
Każda iteracja AI powinna kończyć się:
- build
- test
- lint

### Zasada użycia skryptów
AI powinno używać tych skryptów jako jedynego wejścia do walidacji.
Nie polegaj na luźnym opisywaniu błędów — przekazuj pełny output ze skryptów.

### Notes
- Signing: skonfiguruj zgodnie z profilem projektu, ale trzymaj poza logiką feature.
- Script expectations: `build.sh`, `test.sh`, `lint.sh` są kontraktem walidacji dla AI.

## Setup Checklist Addendum (macos-swiftui)

```text
[ ] skonfigurowany SwiftLint
[ ] skonfigurowany SwiftFormat
[ ] pierwsza appka SwiftUI buduje się przez CLI
[ ] ustawione pełne Xcode jako active developer directory
[ ] uruchomione xcodebuild -runFirstLaunch
[ ] ustalony schemat Xcode używany przez CLI
[ ] utworzony i przypisany .xctestplan
[ ] wyłączone nieużywane test targets z Test Plan
```
