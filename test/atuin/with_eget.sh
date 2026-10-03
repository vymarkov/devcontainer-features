#!/bin/bash

# Scenario: atuin with zyedidia-eget present (latest release).
# eget is required; installsAfter does not auto-install it.

set -e

source dev-container-features-test-lib

check "eget is on PATH" which eget
check "atuin is on PATH" which atuin
check "atuin --version runs" bash -c "atuin --version"
check "oncreate helper installed" bash -c "test -x /usr/local/share/atuin-feature/oncreate.sh"
check "VERSION file recorded" bash -c "test -s /usr/local/share/atuin-feature/VERSION"

reportResults
