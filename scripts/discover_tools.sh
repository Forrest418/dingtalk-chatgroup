#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTACTS_SERVER="$(${SCRIPT_DIR}/resolve_server.sh contacts "${1:-}")"
CHAT_SERVER="$(${SCRIPT_DIR}/resolve_server.sh chat "${2:-}")"

print_tools() {
  local label="$1"
  local server="$2"
  local schema_json

  schema_json="$(${SCRIPT_DIR}/mcp.sh list "${server}" --schema --json)"
  echo "${schema_json}" | jq -e '.status == "ok" and (.tools | type == "array")' >/dev/null

  echo "=== ${label} (${server}) ==="
  echo "${schema_json}" | jq -r '.tools[]? | [.name, (.description // "")] | @tsv'
  echo
}

print_tools "通讯录工具" "${CONTACTS_SERVER}"
print_tools "群聊工具" "${CHAT_SERVER}"
