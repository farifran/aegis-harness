#!/usr/bin/env bash

# =========================================================
# AEGIS HARNESS — CAPABILITY MANIFEST GENERATOR
# =========================================================
#
# Version: 2.2
# Layer: Capability Topology
# Status: Hardened
#
# Responsibilities:
#
# - deterministic manifest generation
# - capability topology materialization
# - execution engine mapping
# - capability provenance
# - manifest integrity
# - topology serialization
#
# The manifest intentionally represents:
#
# - runtime-owned authority
# - capability envelopes
# - execution routing
# - bounded execution topology
#
# =========================================================

set -Eeuo pipefail

# =========================================================
# ROOT RESOLUTION
# =========================================================

readonly AEGIS_MANIFEST_ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
)"

cd "${AEGIS_MANIFEST_ROOT}"

# =========================================================
# CONFIGURATION
# =========================================================

[[ -f ".harness/config.sh" ]] || {
  echo "[AEGIS][MANIFEST][FATAL] missing_config" >&2
  exit 1
}

source ".harness/config.sh"

# =========================================================
# EXECUTION IDENTITY
# =========================================================

readonly AEGIS_MANIFEST_GENERATED_AT="$(
  date -u +"%Y-%m-%dT%H:%M:%SZ"
)"

readonly AEGIS_MANIFEST_EXECUTION_ID="${AEGIS_EXECUTION_ID:-manifest-standalone}"

# =========================================================
# LOGGING
# =========================================================

manifest_log() {
  echo "[AEGIS][MANIFEST] $*" >&2
}

manifest_warn() {
  echo "[AEGIS][MANIFEST][WARN] $*" >&2
}

manifest_fatal() {
  echo "[AEGIS][MANIFEST][FATAL] $*" >&2
  exit 1
}

# =========================================================
# VALIDATION
# =========================================================

validate_environment() {

  command -v jq >/dev/null 2>&1 \
    || manifest_fatal "missing_jq"

  command -v sha256sum >/dev/null 2>&1 \
    || manifest_fatal "missing_sha256sum"

  [[ "${#AEGIS_EXECUTION_ENGINES[@]}" -gt 0 ]] \
    || manifest_fatal "missing_execution_engines"

  [[ "${#AEGIS_CAPABILITY_HANDLERS[@]}" -gt 0 ]] \
    || manifest_fatal "missing_capability_registry"

  [[ "${#AEGIS_MODE_CAPABILITY_MAP[@]}" -gt 0 ]] \
    || manifest_fatal "missing_mode_capability_map"
}

validate_handler_registry() {

  local capability

  for capability in "${!AEGIS_CAPABILITY_HANDLERS[@]}"; do

    local handler
    handler="${AEGIS_CAPABILITY_HANDLERS[$capability]}"

    [[ -f "${handler}" ]] \
      || manifest_fatal "missing_handler_file: ${handler}"

  done
}

# =========================================================
# CAPABILITY CLASSIFICATION
# =========================================================

classify_capability() {

  local capability="$1"

  case "${capability}" in

    filesystem.*)
      echo "readonly"
      ;;

    topology.*)
      echo "readonly"
      ;;

    runtime.*)
      echo "readonly"
      ;;

    git.diff|git.status)
      echo "readonly"
      ;;

    *)
      echo "unknown"
      ;;
  esac
}

# =========================================================
# CAPABILITY ENVELOPE RESOLUTION
# =========================================================

resolve_mode_capabilities() {

  local mode="$1"

  local envelope_name
  envelope_name="${AEGIS_MODE_CAPABILITY_MAP[$mode]:-}"

  [[ -n "${envelope_name}" ]] \
    || manifest_fatal "missing_capability_envelope: ${mode}"

  declare -n RESOLVED_CAPABILITIES="${envelope_name}"

  [[ "${#RESOLVED_CAPABILITIES[@]}" -gt 0 ]] \
    || manifest_fatal "empty_capability_envelope: ${mode}"

  printf '%s\n' "${RESOLVED_CAPABILITIES[@]}"
}

# =========================================================
# MODE MANIFEST
# =========================================================

build_mode_manifest() {

  local mode="$1"

  local engine
  engine="${AEGIS_EXECUTION_ENGINES[$mode]:-}"

  [[ -n "${engine}" ]] \
    || manifest_fatal "missing_execution_engine: ${mode}"

  local capabilities_temp
  capabilities_temp="$(mktemp)"

  echo "[" > "${capabilities_temp}"

  local first_capability="true"

  while IFS= read -r capability; do

    local handler
    handler="${AEGIS_CAPABILITY_HANDLERS[$capability]:-}"

    [[ -n "${handler}" ]] \
      || manifest_fatal "missing_handler_for_capability: ${capability}"

    local classification
    classification="$(classify_capability "${capability}")"

    if [[ "${first_capability}" == "false" ]]; then
      echo "," >> "${capabilities_temp}"
    fi

    first_capability="false"

    jq -n \
      --arg capability "${capability}" \
      --arg handler "${handler}" \
      --arg classification "${classification}" \
      '{
        capability: $capability,
        classification: $classification,
        handler: $handler
      }' \
      >> "${capabilities_temp}"

  done < <(
    resolve_mode_capabilities "${mode}"
  )

  echo "]" >> "${capabilities_temp}"

  jq empty "${capabilities_temp}" \
    >/dev/null 2>&1 \
    || manifest_fatal "invalid_capability_manifest"

  jq -n \
    --arg mode "${mode}" \
    --arg execution_engine "${engine}" \
    --slurpfile capabilities "${capabilities_temp}" \
    '{
      mode: $mode,
      execution_engine: $execution_engine,
      capabilities: $capabilities[0]
    }'

  rm -f "${capabilities_temp}"
}

# =========================================================
# MANIFEST HASH
# =========================================================

compute_manifest_hash() {

  local manifest_content="$1"

  echo "${manifest_content}" \
    | sha256sum \
    | awk '{print $1}'
}

# =========================================================
# GLOBAL MANIFEST
# =========================================================

generate_manifest() {

  local manifest_body
  manifest_body="$(mktemp)"

  echo "{" > "${manifest_body}"

  echo "\"schema_version\":\"2.2\"," >> "${manifest_body}"

  echo "\"runtime_model\":\"capability_grounded_execution\"," >> "${manifest_body}"

  echo "\"generated_at\":\"${AEGIS_MANIFEST_GENERATED_AT}\"," >> "${manifest_body}"

  echo "\"execution_id\":\"${AEGIS_MANIFEST_EXECUTION_ID}\"," >> "${manifest_body}"

  echo "\"modes\":{" >> "${manifest_body}"

  local first_mode="true"

  local mode

  for mode in "${!AEGIS_EXECUTION_ENGINES[@]}"; do

    if [[ "${first_mode}" == "false" ]]; then
      echo "," >> "${manifest_body}"
    fi

    first_mode="false"

    echo "\"${mode}\":" >> "${manifest_body}"

    build_mode_manifest "${mode}" \
      >> "${manifest_body}"

  done

  echo "}" >> "${manifest_body}"

  echo "}" >> "${manifest_body}"

  jq empty "${manifest_body}" \
    >/dev/null 2>&1 \
    || manifest_fatal "invalid_manifest_structure"

  local manifest_content
  manifest_content="$(cat "${manifest_body}")"

  local manifest_hash
  manifest_hash="$(
    compute_manifest_hash "${manifest_content}"
  )"

  jq -n \
    --arg schema_version "2.2" \
    --arg runtime_model "capability_grounded_execution" \
    --arg generated_at "${AEGIS_MANIFEST_GENERATED_AT}" \
    --arg execution_id "${AEGIS_MANIFEST_EXECUTION_ID}" \
    --arg manifest_hash "${manifest_hash}" \
    --slurpfile manifest "${manifest_body}" \
    '{
      schema_version: $schema_version,
      runtime_model: $runtime_model,
      generated_at: $generated_at,
      execution_id: $execution_id,
      manifest_hash: $manifest_hash,
      modes: $manifest[0].modes
    }'

  rm -f "${manifest_body}"
}

# =========================================================
# MAIN
# =========================================================

main() {

  manifest_log "Generating capability manifest..."

  validate_environment

  validate_handler_registry

  generate_manifest
}

main "$@"