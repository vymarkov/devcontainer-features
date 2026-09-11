#!/usr/bin/env bash
set -e

MOUNT_CURSOR_DIR="/mnt/cursor-dir"
USER_HOME="${_REMOTE_USER_HOME:-$HOME}"
USER_NAME="${_REMOTE_USER:-$(whoami)}"
CURSOR_DIR="${USER_HOME}/.cursor"

maybe_sudo() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

echo "Setting up Cursor Agent ~/.cursor persistence..."

if [ ! -d "${MOUNT_CURSOR_DIR}" ]; then
    echo "WARNING: Mount point ${MOUNT_CURSOR_DIR} not found; skipping ~/.cursor persistence"
    exit 0
fi

maybe_sudo chown -R "${USER_NAME}:${USER_NAME}" "${MOUNT_CURSOR_DIR}"

# Back up existing directory if it exists and is not already our symlink
if [ -d "${CURSOR_DIR}" ] && [ ! -L "${CURSOR_DIR}" ]; then
    echo "Backing up existing ~/.cursor to ~/.cursor.old/"
    if [ -d "${CURSOR_DIR}.old" ]; then
        maybe_sudo rm -rf "${CURSOR_DIR}.old"
    fi
    mv "${CURSOR_DIR}" "${CURSOR_DIR}.old"

    # If volume is empty, migrate previous contents into it
    if [ -z "$(ls -A "${MOUNT_CURSOR_DIR}" 2>/dev/null || true)" ]; then
        echo "Migrating existing ~/.cursor data to volume..."
        cp -a "${CURSOR_DIR}.old/." "${MOUNT_CURSOR_DIR}/"
    fi
fi

if [ -L "${CURSOR_DIR}" ]; then
    rm "${CURSOR_DIR}"
elif [ -e "${CURSOR_DIR}" ]; then
    maybe_sudo rm -rf "${CURSOR_DIR}"
fi

ln -s "${MOUNT_CURSOR_DIR}" "${CURSOR_DIR}"
# Ensure the remote user owns the symlink itself when created as root
if [ "$(id -u)" -eq 0 ] && [ -n "${USER_NAME}" ]; then
    chown -h "${USER_NAME}:${USER_NAME}" "${CURSOR_DIR}" || true
fi

echo "✓ ~/.cursor -> ${MOUNT_CURSOR_DIR}"
echo "Cursor Agent persistence setup complete."
