#!/usr/bin/env bash

set -Eeuo pipefail

readonly ACTIVE_TASK_FILE="${1:-}"

readonly EXECUTION_ID="${AEGIS_EXECUTION_ID:-unknown}"

readonly GENERATED_AT="$(
  date -u +"%Y-%m-%dT%H:%M:%SZ"
)"

fail() {

  local error_message="$1"

  jq -n \
    --arg capability "runtime.read_active_task" \
    --arg classification "readonly" \
    --arg execution_id "${EXECUTION_ID}" \
    --arg generated_at "${GENERATED_AT}" \
    --arg error "${error_message}" \
    '{
      success: false,
      capability: $capability,
      classification: $classification,
      execution_id: $execution_id,
      generated_at: $generated_at,
      payload: null,
      error: $error
    }'

  exit 1
}

[[ -n "${ACTIVE_TASK_FILE}" ]] \
  || fail "missing_active_task_file"

[[ -f "${ACTIVE_TASK_FILE}" ]] \
  || fail "active_task_not_found"

jq -n \
  --arg capability "runtime.read_active_task" \
  --arg classification "readonly" \
  --arg execution_id "${EXECUTION_ID}" \
  --arg generated_at "${GENERATED_AT}" \
  --arg path "${ACTIVE_TASK_FILE}" \
  --rawfile content "${ACTIVE_TASK_FILE}" \
  '{
    success: true,
    capability: $capability,
    classification: $classification,
    execution_id: $execution_id,
    generated_at: $generated_at,
    payload: {
      path: $path,
      content: $content
    },
    error: null
  }'