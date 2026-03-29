#!/bin/bash
set -e

SCHEME="DevSupervisor"

xcodebuild \
  test \
  -scheme "$SCHEME" \
  -destination 'platform=macOS,arch=arm64'
