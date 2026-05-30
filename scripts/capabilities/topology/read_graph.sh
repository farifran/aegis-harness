#!/usr/bin/env bash

# =========================================================
# AEGIS CAPABILITY — topology.read_graph
# =========================================================
#
# Classification:
# readonly
#
# Responsibilities:
#
# - bounded topology inspection
# - deterministic graph evidence generation
# - payload provenance emission
# - bounded output truncation
#
# This capability intentionally:
#
# - exposes only architecture topology evidence;
# - avoids implicit repository inheritance;
# - propagates execution identity;
# - enforces evidence-size budgets.
#
# =========================================================

set -Eeuo pipefail

# =========================================================
# INPUTS
# =========================================================

readonly GRAPH_FILE="${1:-.harness/architecture_graph.json}"

# =========================================================
# LIMITS
# =========================================================

readonly MAX_GRAPH_BYTES="${AEGIS_TOPOLOGY_GRAPH_MAX_BYTES:-100000}"

# =========================================================
# VALIDATION
# =========================================================

fail() {
  local error_type="$1"
  local target="${2:-}"

  jq -n \
    --arg capability "topology.read_graph" \
    --arg classification "readonly" \
    --arg execution_id "${AEGIS_EXECUTION_ID:-unknown}" \
    --arg generated_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
    --arg error_type "${error_type}" \
    --arg target "${target}" \
    '{
      success: false,
      capability: $capability,
      classification: $classification,
      execution_id: $execution_id,
      generated_at: $generated_at,
      payload: null,
      error: {
        type: $error_type,
        target: $target
      }
    }'
}

if [[ ! -f "${GRAPH_FILE}" ]]; then
  fail "file_not_found" "${GRAPH_FILE}"
  exit 1
fi

if ! jq empty "${GRAPH_FILE}" >/dev/null 2>&1; then
  fail "invalid_json" "${GRAPH_FILE}"
  exit 1
fi

# =========================================================
# PAYLOAD GENERATION
# =========================================================

TMP_GRAPH_FILE="$(mktemp)"
cleanup() {
  rm -f "${TMP_GRAPH_FILE}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

if ! cat "${GRAPH_FILE}" > "${TMP_GRAPH_FILE}"; then
  fail "read_failure" "${GRAPH_FILE}"
  exit 1
fi

GRAPH_SIZE_BYTES="$(
  wc -c < "${TMP_GRAPH_FILE}"
)"

TRUNCATED="false"

if [[ "${GRAPH_SIZE_BYTES}" -gt "${MAX_GRAPH_BYTES}" ]]; then
  head -c "${MAX_GRAPH_BYTES}" "${TMP_GRAPH_FILE}" > "${TMP_GRAPH_FILE}.bounded"
  printf '\n[AEGIS][TRUNCATED]\n' >> "${TMP_GRAPH_FILE}.bounded"
  mv "${TMP_GRAPH_FILE}.bounded" "${TMP_GRAPH_FILE}"
  TRUNCATED="true"
fi

# =========================================================
# JSON EMISSION
# =========================================================

jq -n \
  --arg capability "topology.read_graph" \
  --arg classification "readonly" \
  --arg execution_id "${AEGIS_EXECUTION_ID:-unknown}" \
  --arg generated_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  --arg target "${GRAPH_FILE}" \
  --argjson graph_size_bytes "${GRAPH_SIZE_BYTES}" \
  --argjson max_graph_bytes "${MAX_GRAPH_BYTES}" \
  --argjson truncated "${TRUNCATED}" \
  --rawfile graph "${TMP_GRAPH_FILE}" \
  '{
    success: true,
    capability: $capability,
    classification: $classification,
    execution_id: $execution_id,
    generated_at: $generated_at,
    payload: {
      target: $target,
      graph_size_bytes: $graph_size_bytes,
      max_graph_bytes: $max_graph_bytes,
      truncated: $truncated,
      graph: $graph
    },
    error: null
  }'