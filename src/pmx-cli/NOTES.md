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
