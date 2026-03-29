# Constraints

## Platform
- macOS only

## UI
- SwiftUI only
- no web UI
- no Electron
- no embedded browser as primary UI

## Language
- Swift for app and core by default
- additional language only if explicitly approved

## API
- local API only in v1
- localhost exposure only

## Persistence
- prefer SQLite or lightweight local persistence
- avoid introducing server-side infrastructure

## Architecture
- prefer simple modular monolith first
- XPC is optional and only after in-process version is stable

## Quality
- every feature must have executable tests
- every change must pass build, test and lint
