## TrueNAS CLI (`midclt`)

This Feature installs the official TrueNAS websocket API client from [`truenas/api_client`](https://github.com/truenas/api_client). The installed command is `midclt`.

> Note: This is **not** the interactive on-box TrueNAS Shell CLI (`cli` / [`truenas/midcli`](https://github.com/truenas/midcli)). That tool is tightly coupled to TrueNAS OS. For remote development containers, `midclt` is the supported client.

### Version pinning

Set `version` to a TrueNAS `api_client` git tag that matches your TrueNAS release (for example `TS-25.10.7`). Using `latest` installs the newest non-beta `TS-*` tag.

### Remote usage example

```bash
midclt --uri ws://<TRUENAS_IP>/api/current -K <api-key> call system.info
```
