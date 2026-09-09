#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'truenas-cli' Feature with no options (default version=latest).
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md

set -e

source dev-container-features-test-lib

check "midclt is on PATH" which midclt
check "midclt help runs" bash -c "midclt -h >/dev/null 2>&1 || midclt --help >/dev/null"

reportResults
