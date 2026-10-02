## Requirements

This Feature installs Atuin with [`eget`](https://github.com/zyedidia/eget) from
[`atuinsh/atuin`](https://github.com/atuinsh/atuin) GitHub releases. It does
**not** install eget itself.

Add the community eget Feature to your `devcontainer.json`:

```jsonc
"features": {
    "ghcr.io/devcontainer-community/devcontainer-features/zyedidia-eget:1": {},
    "ghcr.io/vymarkov/devcontainer-features/atuin:1": {
        "version": "latest"
    }
}
```

## Persistence

A named volume (`atuin-data-${devcontainerId}`) is mounted at `/mnt/atuin-data`.
On container create, `~/.local/share/atuin` is symlinked to that mount so the
local history DB and session survive rebuilds.

## Auto login / sync (`onCreateCommand`)

When these environment variables are all set, the Feature logs in (if needed)
and runs `atuin sync`:

- `ATUIN_SYNC_ADDRESS`
- `ATUIN_USERNAME`
- `ATUIN_PASSWORD`
- `ATUIN_KEY`

Missing or incomplete vars only warn. An attempted login/sync that fails fails
container create.

## Shell integration

On create, `# atuin shell integration` + `eval "$(atuin init …)"` is appended
once to `~/.zshrc` and `~/.bashrc` when those files exist.
