---
name: dingtalk-chatgroup
description: 钉钉群组协作技能（项目群/部门群/临时协作群）。当用户提到“建群/拉群/项目群/部门群/协作群/加成员/按关键词找人建群”时使用。技能联合“钉钉通讯录 + 钉钉群聊”两个 MCP，先查人再建群；用户只需维护技能目录下 mcporter.json。
homepage: https://mcp.dingtalk.com
metadata:
  openclaw:
    emoji: "💬"
    requires:
      bins: ["mcporter", "jq"]
---

# DingTalk ChatGroup

Use this skill to quickly create DingTalk collaboration groups by combining two MCP servers:

- Contacts MCP: find user IDs by keyword/mobile/department
- ChatGroup MCP: create internal org group with selected members

## User-Maintained Config (Only)

Users only need one file in skill root:

- `mcporter.json` (contains both contacts and chatgroup MCP entries)

At runtime resolve servers with:

```bash
CONTACTS_SERVER="$(scripts/resolve_server.sh contacts)"
CHAT_SERVER="$(scripts/resolve_server.sh chat)"
```

## Execution Policy

- Always call via `scripts/mcp.sh` (never raw `mcporter`).
- Run `scripts/preflight.sh` before first use.
- Discover tools before execution:
  - `scripts/discover_tools.sh`
- For write actions (create group), require explicit user confirmation.
- Prefer preview flow: list members first, then create.

## Common Workflow

### 1) Preview group members by keywords

```bash
scripts/create_group.sh --name "项目协作群" --keywords "王,李"
```

### 2) Create group after confirmation

```bash
scripts/create_group.sh --name "项目协作群" --keywords "王,李" --confirm
```

### 3) Create group with explicit user IDs

```bash
scripts/create_group.sh --name "部门协作群" --members "239979,014118" --confirm
```

## Output Guidelines

- Always show member `userId` list before creation.
- If details are available, show `name | userId | dept` preview.
- On success, return full MCP response (group identifiers if provided).

## References

- Config setup: `references/configuration.md`
- Tool discovery: `references/tool-discovery.md`
- Usage examples: `README.md`
