#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_PATH="$(${SCRIPT_DIR}/mcp.sh --print-config-path 2>/dev/null || true)"

ROLE="${1:-}"
PREFERRED="${2:-}"

if [[ -z "${CONFIG_PATH}" || ! -f "${CONFIG_PATH}" ]]; then
  echo "[resolve] 缺少配置文件。" >&2
  echo "[resolve] 查找顺序: ${OPENCLAW_HOME:-$HOME/.openclaw}/config/mcporter.json -> ${OPENCLAW_HOME:-$HOME/.openclaw}/workspace/config/mcporter.json -> ${SKILL_DIR}/mcporter.json" >&2
  exit 1
fi

if [[ "${ROLE}" != "contacts" && "${ROLE}" != "chat" ]]; then
  echo "[resolve] 用法: scripts/resolve_server.sh <contacts|chat> [preferred-name]" >&2
  exit 1
fi

mcp() {
  "${SCRIPT_DIR}/mcp.sh" "$@"
}

is_server_ok() {
  local name="$1"
  local output
  output="$(mcp list "${name}" --schema --json 2>/dev/null || true)"
  echo "${output}" | jq -e '.status == "ok"' >/dev/null 2>&1
}

if [[ -n "${PREFERRED}" ]]; then
  if is_server_ok "${PREFERRED}"; then
    echo "${PREFERRED}"
    exit 0
  fi
  echo "[resolve] 指定服务不可用: ${PREFERRED}" >&2
  exit 1
fi

if [[ "${ROLE}" == "contacts" ]]; then
  CANDIDATES=("钉钉通讯录" "dingtalk-contacts" "contacts")
  PATTERN='search_user_by_key_word|search_user_by_mobile|get_dept_members|get_user_info|dept|user|contact'
  NAME_HINT='通讯录|contact|dept|user|org'
else
  CANDIDATES=("钉钉群聊" "dingtalk-chatgroup" "chatgroup" "groupchat")
  PATTERN='create_internal_org_group|group|chat'
  NAME_HINT='群聊|chat|group'
fi

for name in "${CANDIDATES[@]}"; do
  if is_server_ok "${name}"; then
    echo "${name}"
    exit 0
  fi
done

AUTO_NAME="$({
  mcp list --json 2>/dev/null \
  | jq -r --arg p "${PATTERN}" '
      .servers[]
      | select(.status == "ok")
      | select(any(.tools[]?; (.name | test($p; "i"))))
      | .name
    ' \
  | head -n 1
} || true)"

if [[ -n "${AUTO_NAME}" ]]; then
  echo "${AUTO_NAME}"
  exit 0
fi

CONFIG_HINT_NAME="$({
  jq -r --arg hint "${NAME_HINT}" '.mcpServers | keys[] | select(test($hint; "i"))' "${CONFIG_PATH}" | head -n 1
} || true)"

if [[ -n "${CONFIG_HINT_NAME}" ]]; then
  echo "${CONFIG_HINT_NAME}"
  exit 0
fi

echo "[resolve] 未找到可用的 ${ROLE} MCP 服务。" >&2
echo "[resolve] 请检查主配置目录或技能目录中的 mcporter.json 的 mcpServers 配置。" >&2
exit 1
