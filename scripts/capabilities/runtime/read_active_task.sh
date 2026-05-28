# =================================================
# scripts/capabilities/runtime/read_active_task.sh
# =================================================

#!/usr/bin/env bash

set -Eeuo pipefail

CAPABILITY="runtime.read_active_task"

TASK_FILE=".harness/runtime/active_task.md"

fatal() {
  jq -n \
    --arg capability "$CAPABILITY" \
    --arg error "$1" \
    '{
      success: false,
      capability: $capability,
      classification: "readonly",
      payload: null,
      error: $error
    }'
  exit 1
}

[[ -f "$TASK_FILE" ]] \
  || fatal "active_task_not_found"

CONTENT="$(cat "$TASK_FILE")"

jq -n \
  --arg capability "$CAPABILITY" \
  --arg path "$TASK_FILE" \
  --arg content "$CONTENT" \
  '{
    success: true,
    capability: $capability,
    classification: "readonly",
    payload: {
      path: $path,
      content: $content
    },
    error: null
  }'