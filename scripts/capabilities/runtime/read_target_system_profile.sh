#!/usr/bin/env bash

# =========================================================
# AEGIS CAPABILITY — runtime.read_target_system_profile
# =========================================================
#
# Classification:
# readonly
#
# Responsibilities:
#
# - bounded target-system profile inspection
# - schema normalization
# - payload provenance emission
# - explicit absence handling
#
# This capability intentionally:
#
# - exposes only target-system declarations;
# - keeps profile semantics constitutional;
# - remains runtime-bound to materialized runtime context;
# - does not discover context or hardcode fallback paths;
# - fails explicitly when runtime context is not initialized;
# - propagates execution identity;
# - enforces profile-size budgets.
#
# =========================================================

set -Eeuo pipefail

# =========================================================
# INPUTS
# =========================================================

readonly TARGET_SYSTEM_PROFILE_FILE="${1:-${AEGIS_TARGET_SYSTEM_PROFILE_FILE:-}}"
readonly REQUIRED_RUNTIME_CONTEXT='["AEGIS_TARGET_SYSTEM_PROFILE_FILE"]'

# =========================================================
# LIMITS
# =========================================================

readonly MAX_TARGET_SYSTEM_PROFILE_BYTES="${AEGIS_TARGET_SYSTEM_PROFILE_MAX_BYTES:-25000}"
readonly EMPTY_TARGET_SYSTEM_PROFILE_JSON='{"characteristics":{},"constraints":{},"preferences":{}}'

# =========================================================
# EXECUTION IDENTITY
# =========================================================

readonly EXECUTION_ID="${AEGIS_EXECUTION_ID:-unknown}"

readonly GENERATED_AT="$(
  date -u +"%Y-%m-%dT%H:%M:%SZ"
)"

# =========================================================
# JSON EMISSION
# =========================================================

fail() {
  local error_type="$1"
  local target="${2:-${TARGET_SYSTEM_PROFILE_FILE:-}}"
  local required_context_json="${3:-[]}"

  jq -n \
    --arg capability "runtime.read_target_system_profile" \
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

emit_success() {
  local present="$1"
  local profile_size_bytes="$2"
  local profile_json="$3"

  jq -n \
    --arg capability "runtime.read_target_system_profile" \
    --arg classification "readonly" \
    --arg execution_id "${EXECUTION_ID}" \
    --arg generated_at "${GENERATED_AT}" \
    --arg path "${TARGET_SYSTEM_PROFILE_FILE}" \
    --argjson present "${present}" \
    --argjson target_system_profile_size_bytes "${profile_size_bytes}" \
    --argjson max_target_system_profile_bytes "${MAX_TARGET_SYSTEM_PROFILE_BYTES}" \
    --argjson profile "${profile_json}" \
    '{
      success: true,
      capability: $capability,
      classification: $classification,
      execution_id: $execution_id,
      generated_at: $generated_at,
      payload: {
        path: $path,
        present: $present,
        target_system_profile_size_bytes: $target_system_profile_size_bytes,
        max_target_system_profile_bytes: $max_target_system_profile_bytes,
        profile: $profile
      },
      error: null
    }'
}

# =========================================================
# VALIDATION AND NORMALIZATION
# =========================================================

normalize_profile_json() {
  local parser_status=0
  local normalized_json=""

  command -v node >/dev/null 2>&1 || {
    fail "missing_node_runtime" "${TARGET_SYSTEM_PROFILE_FILE}"
    exit 1
  }

  normalized_json="$({
    node --input-type=module - "${TARGET_SYSTEM_PROFILE_FILE}" <<'EOF'
import fs from 'node:fs';
import process from 'node:process';
import { createRequire } from 'node:module';

const profilePath = process.argv[2];

let yaml;
try {
  const require = createRequire(import.meta.url);
  yaml = require('js-yaml');
} catch {
  process.exit(20);
}

let parsed;
try {
  const raw = fs.readFileSync(profilePath, 'utf8');
  parsed = raw.trim() === '' ? {} : yaml.load(raw);
} catch {
  process.exit(21);
}

if (parsed == null) {
  parsed = {};
}

if (typeof parsed !== 'object' || Array.isArray(parsed)) {
  process.exit(22);
}

const allowedKeys = ['characteristics', 'constraints', 'preferences'];
const allowedSet = new Set(allowedKeys);
const unknownKeys = Object.keys(parsed).filter((key) => !allowedSet.has(key));

if (unknownKeys.length > 0) {
  process.exit(23);
}

const normalized = {};

for (const key of allowedKeys) {
  const value = parsed[key];

  if (value == null) {
    normalized[key] = {};
    continue;
  }

  if (typeof value !== 'object' || Array.isArray(value)) {
    process.exit(24);
  }

  normalized[key] = value;
}

process.stdout.write(JSON.stringify(normalized));
EOF
  } 2>/dev/null)" || parser_status=$?

  if [[ "${parser_status}" -ne 0 ]]; then
    case "${parser_status}" in
      20)
        fail "missing_js_yaml_dependency" "${TARGET_SYSTEM_PROFILE_FILE}"
        ;;
      21)
        fail "invalid_target_system_profile_yaml" "${TARGET_SYSTEM_PROFILE_FILE}"
        ;;
      *)
        fail "invalid_target_system_profile_schema" "${TARGET_SYSTEM_PROFILE_FILE}"
        ;;
    esac
    exit 1
  fi

  printf '%s' "${normalized_json}"
}

if [[ -z "${TARGET_SYSTEM_PROFILE_FILE}" ]]; then
  fail "runtime_context_not_initialized" "" "${REQUIRED_RUNTIME_CONTEXT}"
  exit 1
fi

if [[ ! -f "${TARGET_SYSTEM_PROFILE_FILE}" ]]; then
  emit_success "false" "0" "${EMPTY_TARGET_SYSTEM_PROFILE_JSON}"
  exit 0
fi

TARGET_SYSTEM_PROFILE_SIZE_BYTES="$(
  wc -c < "${TARGET_SYSTEM_PROFILE_FILE}"
)"

if [[ "${TARGET_SYSTEM_PROFILE_SIZE_BYTES}" -gt "${MAX_TARGET_SYSTEM_PROFILE_BYTES}" ]]; then
  fail "target_system_profile_exceeds_max_bytes" "${TARGET_SYSTEM_PROFILE_FILE}"
  exit 1
fi

NORMALIZED_TARGET_SYSTEM_PROFILE_JSON="$(
  normalize_profile_json
)"

emit_success \
  "true" \
  "${TARGET_SYSTEM_PROFILE_SIZE_BYTES}" \
  "${NORMALIZED_TARGET_SYSTEM_PROFILE_JSON}"