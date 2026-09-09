#!/usr/bin/env bash
set -e

VERSION="${VERSION:-"latest"}"
REPO_URL="https://github.com/truenas/api_client.git"

echo "Activating feature 'truenas-cli'"

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* 2>/dev/null | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

check_packages() {
    if ! dpkg -s "$@" >/dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

# midclt requires Python >= 3.10 and Git for pip installs from GitHub.
check_packages ca-certificates curl git python3 python3-pip python3-venv

# Prefer distro pipx; fall back to pip if the package is unavailable.
if ! command -v pipx >/dev/null 2>&1; then
    if apt-cache show pipx >/dev/null 2>&1; then
        check_packages pipx
    else
        python3 -m pip install --break-system-packages pipx || python3 -m pip install pipx
    fi
fi

# Ensure pipx-installed binaries are on PATH for all users.
export PIPX_BIN_DIR="${PIPX_BIN_DIR:-/usr/local/bin}"
export PIPX_HOME="${PIPX_HOME:-/usr/local/pipx}"
mkdir -p "${PIPX_BIN_DIR}" "${PIPX_HOME}"
# Some pipx packages expect ensurepath; we set dirs explicitly instead.
python3 -m pipx ensurepath >/dev/null 2>&1 || true

resolve_latest_tag() {
    # Prefer the newest non-beta TrueNAS stable tag (TS-*).
    local tag
    tag="$(
        git ls-remote --tags --refs "${REPO_URL}" 'TS-*' \
            | awk '{print $2}' \
            | sed 's#refs/tags/##' \
            | grep -Ev 'BETA|RC|alpha|beta|rc' \
            | sort -V \
            | tail -n1
    )"
    if [ -z "${tag}" ]; then
        echo "Unable to resolve a stable TrueNAS api_client tag from ${REPO_URL}" >&2
        exit 1
    fi
    echo "${tag}"
}

if [ "${VERSION}" = "latest" ]; then
    VERSION="$(resolve_latest_tag)"
    echo "Resolved latest stable TrueNAS api_client tag: ${VERSION}"
fi

SPEC="git+${REPO_URL}@${VERSION}"
echo "Installing TrueNAS api_client (${VERSION}) via pipx..."

# Force reinstall so rebuilding the feature with a different version works cleanly.
if pipx list --short 2>/dev/null | grep -q '^truenas-api-client '; then
    pipx uninstall truenas-api-client >/dev/null 2>&1 || true
fi
# Package name on older tags may differ; also clear midclt if previously installed under another name.
if command -v midclt >/dev/null 2>&1 && ! pipx list --short 2>/dev/null | grep -qi 'truenas'; then
    echo "Found existing midclt; continuing with pipx install."
fi

pipx install --force "${SPEC}"

# Symlink into /usr/local/bin if pipx put the binary elsewhere.
if ! command -v midclt >/dev/null 2>&1; then
    if [ -x "${PIPX_HOME}/venvs/truenas-api-client/bin/midclt" ]; then
        ln -sf "${PIPX_HOME}/venvs/truenas-api-client/bin/midclt" /usr/local/bin/midclt
    elif [ -x "${PIPX_HOME}/venvs/truenas_api_client/bin/midclt" ]; then
        ln -sf "${PIPX_HOME}/venvs/truenas_api_client/bin/midclt" /usr/local/bin/midclt
    else
        echo "midclt was not found on PATH after install." >&2
        pipx list || true
        exit 1
    fi
fi

# Clean up
rm -rf /var/lib/apt/lists/*

echo "TrueNAS CLI client installed:"
midclt -h | head -n 5 || midclt --help | head -n 5
echo "Done installing 'truenas-cli' (midclt ${VERSION})."
