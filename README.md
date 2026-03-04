# dingtalk-chatgroup

## 配置

将以下 JSON 保存为 `mcporter.json`，放到技能目录根路径。

示例：

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
