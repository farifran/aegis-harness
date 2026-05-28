#!/usr/bin/env bash

set -Eeuo pipefail

readonly GRAPH_FILE=".harness/architecture_graph.json"

readonly EXECUTION_ID="${AEGIS_EXECUTION_ID:-unknown}"

readonly GENERATED_AT="$(
  date -u +"%Y-%m-%dT%H:%M:%SZ"
)"

fail() {

  local error_message="$1"

  jq -n \
    --arg capability "topology.read_graph" \
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

[[ -f "${GRAPH_FILE}" ]] \
  || fail "missing_architecture_graph"

jq empty "${GRAPH_FILE}" \
  >/dev/null 2>&1 \
  || fail "invalid_architecture_graph"

jq -n \
  --arg capability "topology.read_graph" \
  --arg classification "readonly" \
  --arg execution_id "${EXECUTION_ID}" \
  --arg generated_at "${GENERATED_AT}" \
  --slurpfile graph "${GRAPH_FILE}" \
  '{
    success: true,
    capability: $capability,
    classification: $classification,
    execution_id: $execution_id,
    generated_at: $generated_at,
    payload: {
      graph: $graph[0]
    },
    error: null
  }'