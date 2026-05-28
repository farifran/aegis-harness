#!/usr/bin/env bash

set -Eeuo pipefail

readonly TARGET_FILE="${1:-}"

readonly EXECUTION_ID="${AEGIS_EXECUTION_ID:-unknown}"

readonly GENERATED_AT="$(
  date -u +"%Y-%m-%dT%H:%M:%SZ"
)"

fail() {

  local error_message="$1"

  jq -n \
    --arg capability "filesystem.read" \
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

[[ -n "${TARGET_FILE}" ]] \
  || fail "missing_target_file"

[[ -f "${TARGET_FILE}" ]] \
  || fail "file_not_found"

jq -n \
  --arg capability "filesystem.read" \
  --arg classification "readonly" \
  --arg execution_id "${EXECUTION_ID}" \
  --arg generated_at "${GENERATED_AT}" \
  --arg target "${TARGET_FILE}" \
  --rawfile content "${TARGET_FILE}" \
  '{
    success: true,
    capability: $capability,
    classification: $classification,
    execution_id: $execution_id,
    generated_at: $generated_at,
    payload: {
      target: $target,
      content: $content
    },
    error: null
  }'