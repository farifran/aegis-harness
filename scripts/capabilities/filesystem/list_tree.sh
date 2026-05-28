#!/usr/bin/env bash

set -Eeuo pipefail

readonly TARGET_PATH="${1:-.}"

readonly EXECUTION_ID="${AEGIS_EXECUTION_ID:-unknown}"

readonly GENERATED_AT="$(
  date -u +"%Y-%m-%dT%H:%M:%SZ"
)"

fail() {

  local error_message="$1"

  jq -n \
    --arg capability "filesystem.list_tree" \
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

[[ -d "${TARGET_PATH}" ]] \
  || fail "directory_not_found"

TREE_OUTPUT="$(
  find "${TARGET_PATH}" \
    | sort
)"

jq -n \
  --arg capability "filesystem.list_tree" \
  --arg classification "readonly" \
  --arg execution_id "${EXECUTION_ID}" \
  --arg generated_at "${GENERATED_AT}" \
  --arg target "${TARGET_PATH}" \
  --arg tree "${TREE_OUTPUT}" \
  '{
    success: true,
    capability: $capability,
    classification: $classification,
    execution_id: $execution_id,
    generated_at: $generated_at,
    payload: {
      target: $target,
      tree: $tree
    },
    error: null
  }'