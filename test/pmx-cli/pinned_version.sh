#!/bin/bash

# Scenario: install a pinned pmx release tag (v0.6.1).

set -e

source dev-container-features-test-lib

check "eget is on PATH" which eget
check "pmx is on PATH" which pmx
check "pve persona symlink exists" bash -c "test -L /usr/local/bin/pve"
check "pbs persona symlink exists" bash -c "test -L /usr/local/bin/pbs"
check "pdm persona symlink exists" bash -c "test -L /usr/local/bin/pdm"
check "pmx help runs" bash -c "pmx --help >/dev/null 2>&1 || pmx -h >/dev/null"

reportResults
