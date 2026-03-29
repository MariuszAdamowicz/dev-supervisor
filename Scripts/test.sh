#!/bin/bash
set -e

SCHEME=${1:-DevSupervisor}

xcodebuild \
  clean test \
  -scheme "$SCHEME" \
  -destination 'platform=macOS'
