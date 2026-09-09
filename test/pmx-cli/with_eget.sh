#!/bin/bash

# Scenario: pmx-cli with zyedidia-eget present (default pinned v0.6.1).
# eget is required; installsAfter does not auto-install it.

set -e

source dev-container-features-test-lib

check "eget is on PATH" which eget
check "pmx is on PATH" which pmx
check "pve persona symlink exists" bash -c "test -L /usr/local/bin/pve"
check "pbs persona symlink exists" bash -c "test -L /usr/local/bin/pbs"
check "pdm persona symlink exists" bash -c "test -L /usr/local/bin/pdm"
check "pmx help runs" bash -c "pmx --help >/dev/null 2>&1 || pmx -h >/dev/null"

reportResults
