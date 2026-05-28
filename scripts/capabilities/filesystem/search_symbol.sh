#!/usr/bin/env bash

set -Eeuo pipefail

readonly SYMBOL_QUERY="${1:-}"

readonly EXECUTION_ID="${AEGIS_EXECUTION_ID:-unknown}"

readonly GENERATED_AT="$(
  date -u +"%Y-%m-%dT%H:%M:%SZ"
)"

fail() {

  local error_message="$1"

  jq -n \
    --arg capability "filesystem.search_symbol" \
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

[[ -n "${SYMBOL_QUERY}" ]] \
  || fail "missing_symbol_query"

SEARCH_RESULTS="$(
  grep -Rni \
    --exclude-dir=node_modules \
    --exclude-dir=.git \
    "${SYMBOL_QUERY}" . || true
)"

jq -n \
  --arg capability "filesystem.search_symbol" \
  --arg classification "readonly" \
  --arg execution_id "${EXECUTION_ID}" \
  --arg generated_at "${GENERATED_AT}" \
  --arg query "${SYMBOL_QUERY}" \
  --arg results "${SEARCH_RESULTS}" \
  '{
    success: true,
    capability: $capability,
    classification: $classification,
    execution_id: $execution_id,
    generated_at: $generated_at,
    payload: {
      query: $query,
      results: $results
    },
    error: null
  }'