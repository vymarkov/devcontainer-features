
# Cursor Agent CLI (cursor-agent)

Installs the Cursor Agent CLI via eget from downloads.cursor.com and persists ~/.cursor across rebuilds.

## Example Usage

```json
"features": {
    "ghcr.io/vymarkov/devcontainer-features/cursor-agent:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | Cursor Agent CLI lab version (e.g. 2026.09.08-6caf4ff). Use 'latest' to scrape the version from https://cursor.com/install. | string | 2026.09.08-6caf4ff |

## Requirements

This Feature installs the Cursor Agent CLI with [`eget`](https://github.com/zyedidia/eget) from a direct `downloads.cursor.com` URL (there is no GitHub release). It does **not** install eget itself.

Add the community eget Feature to your `devcontainer.json` so it is present before `cursor-agent` runs:

```jsonc
"features": {
    "ghcr.io/devcontainer-community/devcontainer-features/zyedidia-eget:1": {},
    "ghcr.io/vymarkov/devcontainer-features/cursor-agent:1": {
        "version": "2026.09.08-6caf4ff"
    }
}
```

## Persistence

A named volume (`cursor-dir-${devcontainerId}`) is mounted at `/mnt/cursor-dir`. On container create, `~/.cursor` is symlinked to that mount so auth/config/state survive rebuilds. The CLI binary is reinstalled on every rebuild.

## Supported OS

Tested on Debian/Ubuntu (glibc). Cursor Agent CLI does **not** work on Alpine (musl).

## Version pin

Pass a lab version string such as `2026.09.08-6caf4ff`, or `latest` to scrape the current version from `https://cursor.com/install`.


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/vymarkov/devcontainer-features/blob/main/src/cursor-agent/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
