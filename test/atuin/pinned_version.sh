#!/bin/bash

# Scenario: atuin with pinned semver (normalized to vX.Y.Z for eget).

set -e

source dev-container-features-test-lib

check "atuin is on PATH" which atuin
check "atuin --version runs" bash -c "atuin --version"
check "VERSION file records pin" bash -c "grep -E 'v?18\\.23\\.0|latest' /usr/local/share/atuin-feature/VERSION"
check "oncreate helper installed" bash -c "test -x /usr/local/share/atuin-feature/oncreate.sh"

reportResults
