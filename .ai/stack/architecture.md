# Architecture

## App
Contains SwiftUI views, view models and app lifecycle glue.

## Core
Contains domain logic and reusable modules.

## Services
Contains integrations with external APIs.

## Rule
If logic is reused by more than one feature, it should not stay inside a feature-specific implementation.

