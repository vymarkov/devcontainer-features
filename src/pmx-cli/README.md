
# pmx (Proxmox CLI) (pmx-cli)

Installs the pmx Proxmox CLI (VE / Backup Server / Datacenter Manager) via eget from fivetwenty-io/proxmox-cli release binaries.

## Example Usage

```json
"features": {
    "ghcr.io/devcontainer-community/devcontainer-features/zyedidia-eget:1": {},
    "ghcr.io/vymarkov/devcontainer-features/pmx-cli:1": {
        "version": "v0.6.1"
    }
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | pmx release tag to install (e.g. v0.6.1). Use 'latest' for the newest GitHub release. Bare semver (0.6.1) is accepted and normalized to v0.6.1. | string | v0.6.1 |

## pmx CLI

This Feature installs [`fivetwenty-io/proxmox-cli`](https://github.com/fivetwenty-io/proxmox-cli) using `eget`. It requires the [`zyedidia-eget`](https://github.com/devcontainer-community/devcontainer-features/tree/main/src/zyedidia-eget) Feature to be present (`installsAfter` only orders install; it does not pull eget automatically).

Persona symlinks `pve`, `pbs`, and `pdm` are created next to `pmx`.

```bash
pmx --help
pve --help
```


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/vymarkov/devcontainer-features/blob/main/src/pmx-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
