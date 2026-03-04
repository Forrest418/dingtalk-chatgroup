# Configuration

## Goal

Use one `mcporter.json` in skill root and include both required MCP servers.

## Required file

- `./mcporter.json`

## Template

```json
{
  "mcpServers": {
    "钉钉通讯录": {
      "type": "streamable-http",
      "url": "https://mcp-gw.dingtalk.com/server/<contactsServerId>?key=<contactsKey>"
    },
    "钉钉群聊": {
      "type": "streamable-http",
      "url": "https://mcp-gw.dingtalk.com/server/<chatServerId>?key=<chatKey>"
    }
  }
}
```

## Verify

```bash
./scripts/preflight.sh
```

Expected:

- contacts server: ok
- chat server: ok
