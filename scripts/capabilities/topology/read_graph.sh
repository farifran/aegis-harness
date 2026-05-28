# =================================================
# scripts/capabilities/topology/read_graph.sh
# =================================================

#!/usr/bin/env bash

set -Eeuo pipefail

CAPABILITY="topology.read_graph"

GRAPH_FILE=".harness/architecture_graph.json"

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

[[ -f "$GRAPH_FILE" ]] \
  || fatal "graph_not_found"

GRAPH_CONTENT="$(cat "$GRAPH_FILE")"

jq -n \
  --arg capability "$CAPABILITY" \
  --arg path "$GRAPH_FILE" \
  --argjson graph "$GRAPH_CONTENT" \
  '{
    success: true,
    capability: $capability,
    classification: "readonly",
    payload: {
      path: $path,
      graph: $graph
    },
    error: null
  }'