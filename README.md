# dingtalk-chatgroup

快速组建钉钉协作群（项目群、部门群、临时群）。

## 1. 配置

在技能目录放置 `mcporter.json`（必须同时包含通讯录 MCP 和群聊 MCP）：

```json
{
  "mcpServers": {
    "钉钉通讯录": {
      "type": "streamable-http",
      "url": "https://mcp-gw.dingtalk.com/server/24df90b55a0ad6430c421b78b84160d0e83975e82292a9118479a5f5f3a1dc69?key=32178756f2385c8a5e655cbd1f7e93b7"
    },
    "钉钉群聊": {
      "type": "streamable-http",
      "url": "https://mcp-gw.dingtalk.com/server/78b0e4c279ec56e31a086ff53f502dbcfba52fe891ce2e403992579e56532be5?key=b07364f5e9bc5bcf1e9671912263b07c"
    }
  }
}
```

## 2. 验证

```bash
./scripts/preflight.sh
./scripts/discover_tools.sh
```

## 3. 使用

仅预览成员（不建群）：

```bash
./scripts/create_group.sh --name "营销项目群" --keywords "王,李"
```

确认创建群：

```bash
./scripts/create_group.sh --name "营销项目群" --keywords "王,李" --confirm
```

按 userId 直接建群：

```bash
./scripts/create_group.sh --name "部门协作群" --members "239979,014118" --confirm
```

## 4. 渠道联调与调试

检查网关状态：

```bash
openclaw gateway status --json
```

查看网关日志（含钉钉插件日志）：

```bash
tail -n 200 ~/.openclaw/logs/gateway.log
```

技能预检失败时，优先检查：

- `mcporter.json` 是否在技能目录
- 两个 MCP URL/key 是否可用
- 当前会话是否为旧缓存（可新开会话重试）

## 5. 注意

- 默认预览，不会直接建群；必须加 `--confirm` 才执行创建。
- `mcporter.json` 含敏感 key，请勿提交到公共仓库。
