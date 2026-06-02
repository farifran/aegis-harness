#!/usr/bin/env bash

# =========================================================
# AEGIS CAPABILITY — runtime.read_epistemic_handover
# =========================================================
#
# Classification:
# readonly
#
# Responsibilities:
#
# - bounded epistemic handover inspection
# - deterministic runtime evidence generation
# - schema validation
# - payload provenance emission
#
# This capability intentionally:
#
# - exposes only runtime-owned epistemic handover state;
# - avoids implicit repository inheritance;
# - remains runtime-bound to materialized runtime context;
# - does not discover context or hardcode fallback paths;
# - fails explicitly when runtime context is not initialized;
# - propagates execution identity;
# - enforces handover-size budgets.
#
# =========================================================

set -Eeuo pipefail

readonly AEGIS_RUNTIME_CAPABILITY_ROOT="$({
  cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd
})"

readonly AEGIS_EPISTEMIC_HANDOVER_LIB="${AEGIS_RUNTIME_CAPABILITY_ROOT}/scripts/lib/epistemic_handover.sh"

[[ -f "${AEGIS_EPISTEMIC_HANDOVER_LIB}" ]] || {
  echo "[AEGIS][CAPABILITY][FATAL] missing_epistemic_handover_library" >&2
  exit 1
}

source "${AEGIS_EPISTEMIC_HANDOVER_LIB}"

# =========================================================
# INPUTS
# =========================================================

readonly EPISTEMIC_HANDOVER_FILE="${1:-${AEGIS_EPISTEMIC_HANDOVER_FILE:-}}"
readonly REQUIRED_RUNTIME_CONTEXT='["AEGIS_EPISTEMIC_HANDOVER_FILE"]'

# =========================================================
# LIMITS
# =========================================================

readonly MAX_EPISTEMIC_HANDOVER_BYTES="${AEGIS_EPISTEMIC_HANDOVER_MAX_BYTES:-25000}"

# =========================================================
# EXECUTION IDENTITY
# =========================================================

readonly EXECUTION_ID="${AEGIS_EXECUTION_ID:-unknown}"

readonly GENERATED_AT="$(
  date -u +"%Y-%m-%dT%H:%M:%SZ"
)"

# =========================================================
# VALIDATION
# =========================================================

fail() {
  local error_type="$1"
  local target="${2:-${EPISTEMIC_HANDOVER_FILE:-}}"
  local required_context_json="${3:-[]}"

  jq -n \
    --arg capability "runtime.read_epistemic_handover" \
    --arg classification "readonly" \
    --arg execution_id "${EXECUTION_ID}" \
    --arg generated_at "${GENERATED_AT}" \
    --arg error_type "${error_type}" \
    --arg target "${target}" \
    --argjson required_context "${required_context_json}" \
    '{
      success: false,
      capability: $capability,
      classification: $classification,
      execution_id: $execution_id,
      generated_at: $generated_at,
      payload: null,
      error: (
        { type: $error_type }
        + (if $target != "" then { target: $target } else {} end)
        + (if ($required_context | length) > 0 then { required: $required_context } else {} end)
      )
    }'
}

normalize_epistemic_handover_json() {
  if handover_schema_is_valid "${EPISTEMIC_HANDOVER_FILE}"; then
    jq -c '.' "${EPISTEMIC_HANDOVER_FILE}"
    return 0
  fi

  return 1
}

if [[ -z "${EPISTEMIC_HANDOVER_FILE}" ]]; then
  fail "runtime_context_not_initialized" "" "${REQUIRED_RUNTIME_CONTEXT}"
  exit 1
fi

if [[ ! -f "${EPISTEMIC_HANDOVER_FILE}" ]]; then
  fail "epistemic_handover_not_found" "${EPISTEMIC_HANDOVER_FILE}"
  exit 1
fi

EPISTEMIC_HANDOVER_SIZE_BYTES="$(
  wc -c < "${EPISTEMIC_HANDOVER_FILE}"
)"

if [[ "${EPISTEMIC_HANDOVER_SIZE_BYTES}" -gt "${MAX_EPISTEMIC_HANDOVER_BYTES}" ]]; then
  fail "epistemic_handover_exceeds_max_bytes" "${EPISTEMIC_HANDOVER_FILE}"
  exit 1
fi

NORMALIZED_EPISTEMIC_HANDOVER_JSON="$({
  normalize_epistemic_handover_json
})" || {
  fail "invalid_epistemic_handover_schema" "${EPISTEMIC_HANDOVER_FILE}"
  exit 1
}

# =========================================================
# JSON EMISSION
# =========================================================

jq -n \
  --arg capability "runtime.read_epistemic_handover" \
  --arg classification "readonly" \
  --arg execution_id "${EXECUTION_ID}" \
  --arg generated_at "${GENERATED_AT}" \
  --arg path "${EPISTEMIC_HANDOVER_FILE}" \
  --argjson epistemic_handover_size_bytes "${EPISTEMIC_HANDOVER_SIZE_BYTES}" \
  --argjson max_epistemic_handover_bytes "${MAX_EPISTEMIC_HANDOVER_BYTES}" \
  --argjson handover "${NORMALIZED_EPISTEMIC_HANDOVER_JSON}" \
  '{
    success: true,
    capability: $capability,
    classification: $classification,
    execution_id: $execution_id,
    generated_at: $generated_at,
    payload: {
      path: $path,
      epistemic_handover_size_bytes: $epistemic_handover_size_bytes,
      max_epistemic_handover_bytes: $max_epistemic_handover_bytes,
      handover: $handover
    },
    error: null
  }'