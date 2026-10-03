#!/usr/bin/env bash
# Persist Atuin data, init shells, optionally login + sync from ATUIN_* env.
#
# Env (all four required for auto-login):
#   ATUIN_SYNC_ADDRESS
#   ATUIN_USERNAME
#   ATUIN_PASSWORD
#   ATUIN_KEY
#
# Missing/incomplete vars: warn and continue.
# Attempted login/sync failure: exit non-zero.

set -o pipefail

MOUNT_ATUIN_DATA="/mnt/atuin-data"
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"
USER_NAME="${_REMOTE_USER:-$(whoami)}"
ATUIN_DATA_DIR="${USER_HOME}/.local/share/atuin"
ATUIN_CONFIG="${XDG_CONFIG_HOME:-${USER_HOME}/.config}/atuin/config.toml"
ATUIN_INIT_MARKER='atuin shell integration'

maybe_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

warn() {
    echo "atuin feature: $*" >&2
}

fail() {
    echo "atuin feature: $*" >&2
    exit 1
}

run_as_user() {
    if [ "$(id -u)" -eq 0 ] && [ -n "${USER_NAME}" ] && [ "${USER_NAME}" != "root" ]; then
        # Preserve ATUIN_* and HOME for the target user.
        runuser -u "${USER_NAME}" -- env \
            HOME="${USER_HOME}" \
            ATUIN_SYNC_ADDRESS="${ATUIN_SYNC_ADDRESS:-}" \
            ATUIN_USERNAME="${ATUIN_USERNAME:-}" \
            ATUIN_PASSWORD="${ATUIN_PASSWORD:-}" \
            ATUIN_KEY="${ATUIN_KEY:-}" \
            "$@"
    else
        "$@"
    fi
}

vars_complete() {
    [ -n "${ATUIN_SYNC_ADDRESS:-}" ] \
        && [ -n "${ATUIN_USERNAME:-}" ] \
        && [ -n "${ATUIN_PASSWORD:-}" ] \
        && [ -n "${ATUIN_KEY:-}" ]
}

vars_any_set() {
    [ -n "${ATUIN_SYNC_ADDRESS:-}${ATUIN_USERNAME:-}${ATUIN_PASSWORD:-}${ATUIN_KEY:-}" ]
}

atuin_logged_in() {
    if run_as_user atuin status >/dev/null 2>&1; then
        return 0
    fi
    [ -f "${ATUIN_DATA_DIR}/session" ]
}

append_shell_init() {
    local file=$1
    local init_line=$2

    [ -f "$file" ] || return 0
    if grep -Fq "${ATUIN_INIT_MARKER}" "$file"; then
        return 0
    fi

    {
        printf '\n# %s\n' "${ATUIN_INIT_MARKER}"
        printf '%s\n' "${init_line}"
    } >>"$file"

    if [ "$(id -u)" -eq 0 ] && [ -n "${USER_NAME}" ]; then
        chown "${USER_NAME}:${USER_NAME}" "$file" || true
    fi
}

ensure_shell_init() {
    append_shell_init "${USER_HOME}/.zshrc" 'eval "$(atuin init zsh)"'
    append_shell_init "${USER_HOME}/.bashrc" 'eval "$(atuin init bash)"'
}

set_sync_address() {
    local address=$1
    local config_dir

    config_dir="$(dirname "${ATUIN_CONFIG}")"
    mkdir -p "${config_dir}"

    if [ ! -f "${ATUIN_CONFIG}" ]; then
        printf 'sync_address = "%s"\n' "${address}" >"${ATUIN_CONFIG}"
    elif grep -q '^sync_address[[:space:]]*=' "${ATUIN_CONFIG}"; then
        sed -i "s|^sync_address[[:space:]]*=.*|sync_address = \"${address}\"|" "${ATUIN_CONFIG}"
    else
        printf '\nsync_address = "%s"\n' "${address}" >>"${ATUIN_CONFIG}"
    fi

    if [ "$(id -u)" -eq 0 ] && [ -n "${USER_NAME}" ]; then
        chown -R "${USER_NAME}:${USER_NAME}" "${config_dir}" || true
    fi
}

persist_atuin_data() {
    echo "Setting up Atuin data persistence..."

    if [ ! -d "${MOUNT_ATUIN_DATA}" ]; then
        warn "mount point ${MOUNT_ATUIN_DATA} not found; skipping persistence"
        mkdir -p "${ATUIN_DATA_DIR}"
        if [ "$(id -u)" -eq 0 ] && [ -n "${USER_NAME}" ]; then
            chown -R "${USER_NAME}:${USER_NAME}" "$(dirname "${ATUIN_DATA_DIR}")" || true
        fi
        return 0
    fi

    maybe_sudo chown -R "${USER_NAME}:${USER_NAME}" "${MOUNT_ATUIN_DATA}"
    mkdir -p "$(dirname "${ATUIN_DATA_DIR}")"

    # Back up existing directory if it exists and is not already our symlink
    if [ -d "${ATUIN_DATA_DIR}" ] && [ ! -L "${ATUIN_DATA_DIR}" ]; then
        echo "Backing up existing Atuin data to ${ATUIN_DATA_DIR}.old/"
        if [ -d "${ATUIN_DATA_DIR}.old" ]; then
            maybe_sudo rm -rf "${ATUIN_DATA_DIR}.old"
        fi
        mv "${ATUIN_DATA_DIR}" "${ATUIN_DATA_DIR}.old"

        if [ -z "$(ls -A "${MOUNT_ATUIN_DATA}" 2>/dev/null || true)" ]; then
            echo "Migrating existing Atuin data to volume..."
            cp -a "${ATUIN_DATA_DIR}.old/." "${MOUNT_ATUIN_DATA}/"
        fi
    fi

    if [ -L "${ATUIN_DATA_DIR}" ]; then
        rm "${ATUIN_DATA_DIR}"
    elif [ -e "${ATUIN_DATA_DIR}" ]; then
        maybe_sudo rm -rf "${ATUIN_DATA_DIR}"
    fi

    ln -s "${MOUNT_ATUIN_DATA}" "${ATUIN_DATA_DIR}"
    if [ "$(id -u)" -eq 0 ] && [ -n "${USER_NAME}" ]; then
        chown -h "${USER_NAME}:${USER_NAME}" "${ATUIN_DATA_DIR}" || true
    fi

    echo "✓ ${ATUIN_DATA_DIR} -> ${MOUNT_ATUIN_DATA}"
}

maybe_login() {
    if ! vars_complete; then
        if vars_any_set; then
            warn "incomplete ATUIN_* config; skipping login (need ATUIN_SYNC_ADDRESS, ATUIN_USERNAME, ATUIN_PASSWORD, ATUIN_KEY)"
        else
            warn "ATUIN_* not configured; skipping login"
        fi
        return 0
    fi

    if atuin_logged_in; then
        echo "atuin feature: already logged in; skipping login"
        return 0
    fi

    echo "atuin feature: logging in as ${ATUIN_USERNAME}..."
    run_as_user atuin login -u "${ATUIN_USERNAME}" -p "${ATUIN_PASSWORD}" -k "${ATUIN_KEY}" \
        || fail "login failed"
}

maybe_sync() {
    if ! atuin_logged_in; then
        return 0
    fi

    echo "atuin feature: syncing..."
    run_as_user atuin sync || fail "sync failed"
}

main() {
    if ! command -v atuin >/dev/null 2>&1; then
        warn "atuin not on PATH; skipping"
        return 0
    fi

    persist_atuin_data
    ensure_shell_init

    if [ -n "${ATUIN_SYNC_ADDRESS:-}" ]; then
        set_sync_address "${ATUIN_SYNC_ADDRESS}"
    fi

    maybe_login
    maybe_sync

    echo "Atuin feature setup complete."
}

main "$@"
