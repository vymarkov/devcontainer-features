#!/usr/bin/env bash
set -e

VERSION="${VERSION:-"latest"}"
REPO="atuinsh/atuin"
BIN_DIR="/usr/local/bin"
FEATURE_SHARE="/usr/local/share/atuin-feature"

echo "Activating feature 'atuin'"

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
echo "Installing atuin from ${REPO} (tag=${TAG}) via eget..."

# Prefer the glibc client tarball. eget -a filters are AND'd substring matches;
# a leading '^' is an anti-match.
EGET_ARGS=(
    "${REPO}"
    --to "${BIN_DIR}"
    --file atuin
    --asset 'unknown-linux-gnu.tar.gz'
    --asset '^sha256'
    --asset '^atuin-server'
)

if [ "${TAG}" != "latest" ]; then
    EGET_ARGS+=(-t "${TAG}")
fi

eget "${EGET_ARGS[@]}"

if [ ! -f "${BIN_DIR}/atuin" ]; then
    echo "ERROR: atuin binary not found at ${BIN_DIR}/atuin after eget" >&2
    ls -la "${BIN_DIR}" >&2 || true
    exit 1
fi

chmod 755 "${BIN_DIR}/atuin"

mkdir -p "${FEATURE_SHARE}"
cp "$(dirname "$0")/oncreate.sh" "${FEATURE_SHARE}/oncreate.sh"
chmod 755 "${FEATURE_SHARE}/oncreate.sh"

printf '%s\n' "${TAG}" >"${FEATURE_SHARE}/VERSION"

if ! command -v atuin >/dev/null 2>&1; then
    echo "ERROR: atuin was not installed to PATH (${BIN_DIR})" >&2
    exit 1
fi

echo "Installed: $(command -v atuin)"
atuin --version || true
echo "(*) Done!"
