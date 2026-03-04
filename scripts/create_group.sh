#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTACTS_SERVER="$(${SCRIPT_DIR}/resolve_server.sh contacts)"
CHAT_SERVER="$(${SCRIPT_DIR}/resolve_server.sh chat)"

GROUP_NAME=""
KEYWORDS=""
MEMBERS=""
CONFIRM="false"

usage() {
  cat <<USAGE
用法:
  scripts/create_group.sh --name "项目群名称" [--keywords "王,李"] [--members "239979,014118"] [--confirm]

说明:
  - 默认是预览模式，不会真正创建群。
  - 传入 --confirm 后才会执行 create_internal_org_group。
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      GROUP_NAME="${2:-}"
      shift 2
      ;;
    --keywords)
      KEYWORDS="${2:-}"
      shift 2
      ;;
    --members)
      MEMBERS="${2:-}"
      shift 2
      ;;
    --confirm)
      CONFIRM="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[create_group] unknown arg: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "${GROUP_NAME}" ]]; then
  echo "[create_group] --name 必填。" >&2
  usage
  exit 1
fi

if [[ -z "${KEYWORDS}" && -z "${MEMBERS}" ]]; then
  echo "[create_group] 至少提供 --keywords 或 --members 之一。" >&2
  exit 1
fi

declare -a IDS=()

if [[ -n "${MEMBERS}" ]]; then
  IFS=',' read -r -a direct_ids <<< "${MEMBERS}"
  for id in "${direct_ids[@]}"; do
    id_trim="$(echo "${id}" | xargs)"
    if [[ -n "${id_trim}" ]]; then
      IDS+=("${id_trim}")
    fi
  done
fi

if [[ -n "${KEYWORDS}" ]]; then
  IFS=',' read -r -a words <<< "${KEYWORDS}"
  for w in "${words[@]}"; do
    kw="$(echo "${w}" | xargs)"
    [[ -z "${kw}" ]] && continue

    out="$(${SCRIPT_DIR}/mcp.sh call "${CONTACTS_SERVER}.search_user_by_key_word(keyWord: \"${kw}\")" --output json)"
    while IFS= read -r uid; do
      [[ -n "${uid}" ]] && IDS+=("${uid}")
    done < <(echo "${out}" | jq -r '.userId[]? // .result[]?.userId? // empty')
  done
fi

if [[ ${#IDS[@]} -eq 0 ]]; then
  echo "[create_group] 未解析到任何 userId。" >&2
  exit 1
fi

IDS_JSON="$(printf '%s\n' "${IDS[@]}" | awk 'NF' | sort -u | jq -R . | jq -s .)"
COUNT="$(echo "${IDS_JSON}" | jq 'length')"

echo "[create_group] group: ${GROUP_NAME}"
echo "[create_group] members(userId): ${COUNT}"
echo "${IDS_JSON}" | jq -r '.[]' | sed 's/^/  - /'

# 尝试回显成员姓名，便于人工确认
if [[ "${COUNT}" -gt 0 ]]; then
  info="$(${SCRIPT_DIR}/mcp.sh call "${CONTACTS_SERVER}.get_user_info_by_user_ids(user_id_list: ${IDS_JSON})" --output json || true)"
  if [[ -n "${info}" ]]; then
    echo "[create_group] members(detail):"
    echo "${info}" | jq -r '.result[]? | "  - \(.orgEmployeeModel.orgUserName // "")\t\(.orgEmployeeModel.orgUserId // "")\t\((.orgEmployeeModel.depts[0].deptName // ""))"' || true
  fi
fi

if [[ "${CONFIRM}" != "true" ]]; then
  echo "[create_group] 预览模式完成。加 --confirm 才会真正创建群。"
  exit 0
fi

GROUP_NAME_JSON="$(jq -Rn --arg v "${GROUP_NAME}" '$v')"

echo "[create_group] 正在创建群..."
${SCRIPT_DIR}/mcp.sh call "${CHAT_SERVER}.create_internal_org_group(groupName: ${GROUP_NAME_JSON}, groupMembers: ${IDS_JSON})" --output json
