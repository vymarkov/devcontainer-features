
# pmx (Proxmox CLI) (pmx-cli)

Installs the pmx Proxmox CLI (VE / Backup Server / Datacenter Manager) via eget from fivetwenty-io/proxmox-cli release binaries.

## Example Usage

```json
"features": {
    "ghcr.io/vymarkov/devcontainer-features/pmx-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | pmx release tag to install (e.g. v0.6.1). Use 'latest' for the newest GitHub release. Bare semver (0.6.1) is accepted and normalized to v0.6.1. | string | v0.6.1 |

## Requirements

This Feature installs `pmx` with [`eget`](https://github.com/zyedidia/eget). It does **not** install eget itself.

Add the community eget Feature to your `devcontainer.json` so it is present before `pmx-cli` runs:

```jsonc
"features": {
    "ghcr.io/devcontainer-community/devcontainer-features/zyedidia-eget:1": {},
    "ghcr.io/vymarkov/devcontainer-features/pmx-cli:1": {
        "version": "v0.6.1"
    }
}
```

## Personas

After install, `pve`, `pbs`, and `pdm` are symlinks to `pmx` (persona mode based on `argv[0]`).


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/vymarkov/devcontainer-features/blob/main/src/pmx-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
