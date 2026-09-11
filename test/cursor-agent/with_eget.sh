#!/bin/bash

# Scenario: cursor-agent with zyedidia-eget present (pinned lab version).
# eget is required; installsAfter does not auto-install it.

set -e

source dev-container-features-test-lib

check "eget is on PATH" which eget
check "agent is on PATH" which agent
check "cursor-agent is on PATH" which cursor-agent
check "cursor-agent symlink exists" bash -c "test -L /usr/local/bin/cursor-agent"
check "agent symlink exists" bash -c "test -L /usr/local/bin/agent"
check "install tree exists" bash -c "test -f /usr/local/lib/cursor-agent/cursor-agent"
check "agent --version runs" bash -c "agent --version"
check "VERSION file recorded" bash -c "test -s /usr/local/lib/cursor-agent/VERSION"
check "oncreate helper installed" bash -c "test -x /usr/local/share/cursor-agent-feature/oncreate.sh"

reportResults
