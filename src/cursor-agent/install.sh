#!/usr/bin/env bash
set -e

VERSION="${VERSION:-"2026.09.08-6caf4ff"}"
INSTALL_ROOT="/usr/local/lib/cursor-agent"
BIN_DIR="/usr/local/bin"
FEATURE_SHARE="/usr/local/share/cursor-agent-feature"

echo "Activating feature 'cursor-agent'"

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

if ! command -v curl >/dev/null 2>&1; then
    echo "ERROR: 'curl' is required but was not found on PATH." >&2
    exit 1
fi

# Cursor Agent CLI requires glibc; Alpine / musl will not work.
if [ -f /etc/alpine-release ]; then
    echo "WARNING: Cursor Agent CLI does not work on Alpine (musl). Continuing install, but expect runtime failures." >&2
fi

resolve_arch() {
    local arch
    arch="$(uname -m)"
    case "${arch}" in
        x86_64 | amd64) echo "x64" ;;
        aarch64 | arm64) echo "arm64" ;;
        *)
            echo "ERROR: Unsupported architecture: ${arch}" >&2
            exit 1
            ;;
    esac
}

resolve_version() {
    local v="$1"
    if [ "${v}" != "latest" ]; then
        echo "${v}"
        return
    fi

    echo "Resolving latest Cursor Agent CLI version from https://cursor.com/install ..." >&2
    local install_script version
    install_script="$(curl -fsSL https://cursor.com/install)"
    version="$(printf '%s\n' "${install_script}" | sed -n 's|.*downloads\.cursor\.com/lab/\([^/]*\)/.*|\1|p' | head -n1)"
    if [ -z "${version}" ]; then
        echo "ERROR: Could not parse latest version from https://cursor.com/install" >&2
        exit 1
    fi
    echo "${version}"
}

ARCH="$(resolve_arch)"
RESOLVED_VERSION="$(resolve_version "${VERSION}")"
DOWNLOAD_URL="https://downloads.cursor.com/lab/${RESOLVED_VERSION}/linux/${ARCH}/agent-cli-package.tar.gz"

echo "Installing Cursor Agent CLI ${RESOLVED_VERSION} (${ARCH}) via eget..."
echo "Download URL: ${DOWNLOAD_URL}"

TMP_DIR="$(mktemp -d)"
cleanup() {
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

(
    cd "${TMP_DIR}"
    eget "${DOWNLOAD_URL}" --download-only
)

ARCHIVE="${TMP_DIR}/agent-cli-package.tar.gz"
if [ ! -f "${ARCHIVE}" ]; then
    # Fallback: accept whatever .tar.gz eget wrote in the temp dir
    ARCHIVE="$(find "${TMP_DIR}" -maxdepth 1 -type f -name '*.tar.gz' | head -n1)"
fi
if [ -z "${ARCHIVE}" ] || [ ! -f "${ARCHIVE}" ]; then
    echo "ERROR: eget did not produce a .tar.gz archive in ${TMP_DIR}" >&2
    ls -la "${TMP_DIR}" >&2 || true
    exit 1
fi

rm -rf "${INSTALL_ROOT}"
mkdir -p "${INSTALL_ROOT}"
tar --strip-components=1 -xzf "${ARCHIVE}" -C "${INSTALL_ROOT}"

if [ ! -f "${INSTALL_ROOT}/cursor-agent" ]; then
    echo "ERROR: cursor-agent binary not found at ${INSTALL_ROOT}/cursor-agent after extract" >&2
    ls -la "${INSTALL_ROOT}" >&2 || true
    exit 1
fi

chmod 755 "${INSTALL_ROOT}/cursor-agent"
ln -sfn "${INSTALL_ROOT}/cursor-agent" "${BIN_DIR}/cursor-agent"
ln -sfn "${INSTALL_ROOT}/cursor-agent" "${BIN_DIR}/agent"

# Install persistence helper for onCreateCommand
mkdir -p "${FEATURE_SHARE}"
cp "$(dirname "$0")/oncreate.sh" "${FEATURE_SHARE}/oncreate.sh"
chmod 755 "${FEATURE_SHARE}/oncreate.sh"

# Record installed version for consumers / debugging
printf '%s\n' "${RESOLVED_VERSION}" >"${INSTALL_ROOT}/VERSION"
printf '%s\n' "${RESOLVED_VERSION}" >"${FEATURE_SHARE}/VERSION"

if ! command -v agent >/dev/null 2>&1; then
    echo "ERROR: agent was not installed to PATH (${BIN_DIR})" >&2
    exit 1
fi

echo "Installed: $(command -v agent) ($(command -v cursor-agent))"
agent --version || true
echo "(*) Done!"
