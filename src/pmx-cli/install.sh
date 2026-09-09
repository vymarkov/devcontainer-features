#!/usr/bin/env bash
set -e

VERSION="${VERSION:-"v0.6.1"}"
REPO="fivetwenty-io/proxmox-cli"
BIN_DIR="/usr/local/bin"

echo "Activating feature 'pmx-cli'"

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if ! command -v eget >/dev/null 2>&1; then
    echo "ERROR: 'eget' is required but was not found on PATH." >&2
    echo "Add the eget Feature to your devcontainer.json (and keep installsAfter ordering):" >&2
    echo '  "ghcr.io/devcontainer-community/devcontainer-features/zyedidia-eget:1": {}' >&2
    exit 1
fi

normalize_tag() {
    local v="$1"
    if [ "${v}" = "latest" ]; then
        echo "latest"
        return
    fi
    if [[ "${v}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "v${v}"
        return
    fi
    echo "${v}"
}

TAG="$(normalize_tag "${VERSION}")"
echo "Installing pmx from ${REPO} (tag=${TAG}) via eget..."

# Select the platform .tar.gz (not .deb/.rpm). eget -a filters are AND'd
# substring matches; a leading '^' is an anti-match.
EGET_ARGS=(
    "${REPO}"
    --to "${BIN_DIR}"
    --file pmx
    --asset '.tar.gz'
)

if [ "${TAG}" != "latest" ]; then
    EGET_ARGS+=(-t "${TAG}")
fi

eget "${EGET_ARGS[@]}"

if [ ! -f "${BIN_DIR}/pmx" ]; then
    echo "ERROR: pmx binary not found at ${BIN_DIR}/pmx after eget" >&2
    ls -la "${BIN_DIR}" >&2 || true
    exit 1
fi

chmod 755 "${BIN_DIR}/pmx"

# Release archives ship only the pmx binary; personas are argv0-based symlinks.
for persona in pve pbs pdm; do
    ln -sfn pmx "${BIN_DIR}/${persona}"
done

if ! command -v pmx >/dev/null 2>&1; then
    echo "ERROR: pmx was not installed to PATH (${BIN_DIR})" >&2
    exit 1
fi

echo "Installed: $(command -v pmx)"
pmx --help >/dev/null 2>&1 || pmx -h >/dev/null 2>&1 || true
echo "(*) Done!"
