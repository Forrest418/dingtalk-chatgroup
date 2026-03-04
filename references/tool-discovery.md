# Tool Discovery

## Goal

Confirm tool names for both servers at runtime.

## Commands

```bash
./scripts/discover_tools.sh
```

Current known tools in this deployment:

- Contacts:
  - `search_user_by_key_word`
  - `search_user_by_mobile`
  - `get_user_info_by_user_ids`
  - `search_dept_by_keyword`
  - `get_dept_members_by_deptId`
- ChatGroup:
  - `create_internal_org_group`

## Safety

- Build member preview first.
- Create group only after explicit user confirmation.
