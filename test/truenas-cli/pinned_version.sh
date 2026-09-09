#!/bin/bash

# Scenario: install a pinned TrueNAS api_client tag.

set -e

source dev-container-features-test-lib

check "midclt is on PATH" which midclt
check "midclt help runs" bash -c "midclt -h >/dev/null 2>&1 || midclt --help >/dev/null"

reportResults
