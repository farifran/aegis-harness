#!/usr/bin/env bash

# =================================================
# AEGIS HARNESS — CAPABILITY
# filesystem.search_symbol
# =================================================
#
# Purpose:
# - deterministic readonly symbol inspection
# - runtime-grounded repository evidence
# - bounded structural search capability
#
# This capability intentionally:
# - avoids semantic interpretation
# - avoids assistant behavior
# - avoids authority claims
# - avoids implicit repository awareness
#
# The runtime owns:
# - capability exposure
# - query grounding
# - authority boundaries
#
# This capability only:
# - searches observable repository symbols
# - emits deterministic JSON payloads
#
# =================================================

set -Eeuo pipefail

# =================================================
# CONSTANTS
# =================================================

CAPABILITY="filesystem.search_symbol"

DEFAULT_QUERY="AEGIS"

# =================================================
# INPUTS
# =================================================

QUERY="${1:-$DEFAULT_QUERY}"

SEARCH_ROOT="${2:-.}"

# =================================================
# HELPERS
# =================================================

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

# =================================================
# VALIDATION
# =================================================

[[ -n "$QUERY" ]] \
  || fatal "missing_query"

[[ -d "$SEARCH_ROOT" ]] \
  || fatal "search_root_not_found"

# =================================================
# SEARCH EXECUTION
# =================================================

execute_search() {

  grep -RIn \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude-dir=.harness/runtime/capability_payloads \
    --exclude-dir=.harness/runtime/capability_env \
    "$QUERY" \
    "$SEARCH_ROOT" \
    || true
}

# =================================================
# RESULT MATERIALIZATION
# =================================================

RESULTS="$(
  execute_search
)"

RESULT_COUNT="$(
  printf '%s\n' "$RESULTS" \
    | grep -c . \
    || true
)"

# =================================================
# OUTPUT
# =================================================

jq -n \
  --arg capability "$CAPABILITY" \
  --arg query "$QUERY" \
  --arg search_root "$SEARCH_ROOT" \
  --arg results "$RESULTS" \
  --argjson result_count "${RESULT_COUNT:-0}" \
  '{
    success: true,
    capability: $capability,
    classification: "readonly",
    payload: {
      query: $query,
      search_root: $search_root,
      result_count: $result_count,
      results: $results
    },
    error: null
  }'