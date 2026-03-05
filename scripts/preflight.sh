#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_PATH="$(${SCRIPT_DIR}/mcp.sh --print-config-path 2>/dev/null || true)"
CONTACTS_SERVER="$(${SCRIPT_DIR}/resolve_server.sh contacts)"
CHAT_SERVER="$(${SCRIPT_DIR}/resolve_server.sh chat)"

if ! command -v mcporter >/dev/null 2>&1; then
  echo "[preflight] missing binary: mcporter" >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[preflight] missing binary: jq" >&2
  exit 2
fi

if [[ -z "${CONFIG_PATH}" || ! -f "${CONFIG_PATH}" ]]; then
  echo "[preflight] missing config file." >&2
  echo "[preflight] search order: ${OPENCLAW_HOME:-$HOME/.openclaw}/config/mcporter.json -> ${OPENCLAW_HOME:-$HOME/.openclaw}/workspace/config/mcporter.json -> ${SKILL_DIR}/mcporter.json" >&2
  exit 1
fi

check_server() {
  local server="$1"
  local tmp_json tmp_err tool_count

  tmp_json="$(mktemp)"
  tmp_err="$(mktemp)"
  trap 'rm -f "${tmp_json}" "${tmp_err}"' RETURN

  if ! "${SCRIPT_DIR}/mcp.sh" list "${server}" --schema --json >"${tmp_json}" 2>"${tmp_err}"; then
    echo "[preflight] server check failed for '${server}'" >&2
    cat "${tmp_err}" >&2 || true
    return 1
  fi

  if ! jq -e '.status == "ok" and (.tools | type == "array")' "${tmp_json}" >/dev/null 2>&1; then
    echo "[preflight] invalid schema response for '${server}'" >&2
    cat "${tmp_json}" >&2 || true
    return 1
  fi

  tool_count="$(jq '.tools | length' "${tmp_json}")"
  echo "[preflight] ok: server=${server}, tools=${tool_count}"
}

echo "[preflight] mcporter version: $(mcporter --version)"
echo "[preflight] config path: ${CONFIG_PATH}"
echo "[preflight] contacts server: ${CONTACTS_SERVER}"
echo "[preflight] chat server: ${CHAT_SERVER}"

check_server "${CONTACTS_SERVER}"
check_server "${CHAT_SERVER}"
