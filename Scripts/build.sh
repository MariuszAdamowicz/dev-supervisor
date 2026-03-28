#!/bin/bash
set -e
xcodebuild build 2>&1 | tee build.log
grep -E "error:" build.log || true

