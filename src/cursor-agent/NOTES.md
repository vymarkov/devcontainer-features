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
