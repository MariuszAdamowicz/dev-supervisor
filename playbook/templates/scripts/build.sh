#!/bin/bash
set -e

SCHEME="DevSupervisor"

xcodebuild \
  -scheme "$SCHEME" \
  -configuration Debug \
  build 2>&1 | tee build.log

grep -E "error:" build.log || true
