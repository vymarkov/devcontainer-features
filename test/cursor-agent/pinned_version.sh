#!/bin/bash

# Scenario: pinned Cursor Agent lab version via feature option.

set -e

source dev-container-features-test-lib

check "agent is on PATH" which agent
check "pinned VERSION file" bash -c "grep -qx '2026.09.08-6caf4ff' /usr/local/lib/cursor-agent/VERSION"
check "agent --version runs" bash -c "agent --version"

reportResults
