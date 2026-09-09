
# TrueNAS CLI (truenas-cli)

Installs the official TrueNAS websocket API client (midclt) for calling TrueNAS middleware from a remote host.

## Example Usage

```json
"features": {
    "ghcr.io/vymarkov/devcontainer-features/truenas-cli:1": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| version | TrueNAS api_client git tag to install (e.g. TS-25.10.7). Use 'latest' for the newest non-beta tag. | string | latest |

## TrueNAS CLI (`midclt`)

This Feature installs the official TrueNAS websocket API client from [`truenas/api_client`](https://github.com/truenas/api_client). The installed command is `midclt`.

> Note: This is **not** the interactive on-box TrueNAS Shell CLI (`cli` / [`truenas/midcli`](https://github.com/truenas/midcli)). That tool is tightly coupled to TrueNAS OS. For remote development containers, `midclt` is the supported client.

### Version pinning

Set `version` to a TrueNAS `api_client` git tag that matches your TrueNAS release (for example `TS-25.10.7`). Using `latest` installs the newest non-beta `TS-*` tag.

### Remote usage example

```bash
midclt --uri ws://<TRUENAS_IP>/api/current -K <api-key> call system.info
```


---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/vymarkov/devcontainer-features/blob/main/src/truenas-cli/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._
