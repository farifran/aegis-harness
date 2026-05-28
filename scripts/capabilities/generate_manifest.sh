#!/usr/bin/env bash
# =================================================
# AEGIS HARNESS — CAPABILITY MANIFEST GENERATOR
# =================================================
#
# Purpose:
# - materialize runtime-owned capability environments
# - expose explicit capability routing
# - transform declarative capability topology
#   into operational capability environments
#
# This script intentionally:
# - remains deterministic
# - remains mechanical
# - avoids semantic reasoning
# - avoids orchestration logic
#
# Runtime owns orchestration.
# This script materializes capability environments.
#
# =================================================
set -Eeuo pipefail
# =================================================
# INPUTS
# =================================================
MODE_NAME="${1:-}"
OUTPUT_PATH="${2:-}"
# =================================================
# ROOT PATHS
# =================================================
ROOT_DIR="$(pwd)"
CONFIG_FILE="$ROOT_DIR/.harness/config.sh"
# =================================================
# HELPERS
# =================================================
fatal() {
  printf '[AEGIS][MANIFEST][FATAL] %s\n' "$1"
  exit 1
}
log() {
  printf '[AEGIS][MANIFEST] %s\n' "$1"
}
# =================================================
# VALIDATION
# =================================================
[[ -n "$MODE_NAME" ]] \
  || fatal "Missing mode name"
[[ -n "$OUTPUT_PATH" ]] \
  || fatal "Missing output path"
[[ -f "$CONFIG_FILE" ]] \
  || fatal "Missing config.sh"
# =================================================
# CONFIG LOAD
# =================================================
source "$CONFIG_FILE"
# =================================================
# MODE VALIDATION
# =================================================
validate_mode_exists() {
  local found="false"
  for mode in "${AEGIS_ALL_MODES[@]}"; do
    if [[ "$mode" == "$MODE_NAME" ]]; then
      found="true"
      break
    fi
  done
  [[ "$found" == "true" ]] \
    || fatal "Unknown mode: $MODE_NAME"
}
# =================================================
# LOAD MODE TOPOLOGY
# =================================================
load_mode_capabilities() {
  local capability_var="AEGIS_MODE_CAPABILITIES_${MODE_NAME}[@]"
  MODE_CAPABILITIES=("${!capability_var:-}")
  [[ "${#MODE_CAPABILITIES[@]}" -gt 0 ]] \
    || fatal "Mode has no capability envelope"
}
load_execution_engine() {
  local engine_var="AEGIS_MODE_EXECUTION_ENGINE_${MODE_NAME}"
  MODE_EXECUTION_ENGINE="${!engine_var:-}"
  [[ -n "$MODE_EXECUTION_ENGINE" ]] \
    || fatal "Mode has no execution engine"
}
# =================================================
# CAPABILITY HANDLER RESOLUTION
# =================================================
resolve_capability_handler() {
  local capability="$1"
  local normalized
  normalized="$(
    printf '%s' "$capability" \
      | tr '.' '_' \
      | tr '[:lower:]' '[:upper:]'
  )"
  local handler_var
  handler_var="AEGIS_CAPABILITY_HANDLER_${normalized}"
  local handler="${!handler_var:-}"
  [[ -n "$handler" ]] \
    || fatal "No handler mapping for capability: $capability"
  printf '%s' "$handler"
}
# =================================================
# CAPABILITY CLASSIFICATION
# =================================================
classify_capability() {
  local capability="$1"
  for readonly in "${AEGIS_READONLY_CAPABILITIES[@]}"; do
    if [[ "$readonly" == "$capability" ]]; then
      printf 'readonly'
      return
    fi
  done
  printf 'mutation'
}
# =================================================
# CAPABILITY ENTRY EMISSION
# =================================================
emit_capability_entries() {
  local first="true"
  for capability in "${MODE_CAPABILITIES[@]}"; do
    local handler
    local classification
    handler="$(resolve_capability_handler "$capability")"
    classification="$(classify_capability "$capability")"
    if [[ "$first" == "false" ]]; then
      printf ',\n'
    fi
    first="false"
    cat <<EOF
    {
      "name": "$capability",
      "handler": "$handler",
      "classification": "$classification"
    }
EOF
  done
}
# =================================================
# MANIFEST MATERIALIZATION
# =================================================
materialize_manifest() {
  mkdir -p "$(dirname "$OUTPUT_PATH")"
  cat > "$OUTPUT_PATH" <<EOF
{
  "schema_version": "1.0",
  "mode": "$MODE_NAME",
  "execution_engine": "$MODE_EXECUTION_ENGINE",
  "grounding_model": "runtime_exposed_capabilities",
  "repository_awareness": "capability_bound",
  "continuity_model": "runtime_owned_ephemeral",
  "authority_model": {
    "runtime": "sovereign",
    "executor": "protocol_vm",
    "capabilities": "explicit_authority_surfaces",
    "model": "bounded_cognition"
  },
  "capabilities": [
$(emit_capability_entries)
  ],
  "protocol": {
    "single_json_payload": true,
    "runtime_owned_framing": true,
    "non_conversational_execution": true
  }
}
EOF
}
# =================================================
# EXECUTION
# =================================================
main() {
  validate_mode_exists
  load_mode_capabilities
  load_execution_engine
  log "Generating capability manifest..."
  log "Mode: $MODE_NAME"
  log "Execution engine: $MODE_EXECUTION_ENGINE"
  log "Capabilities:"
  for capability in "${MODE_CAPABILITIES[@]}"; do
    log "  - $capability"
  done
  materialize_manifest
  log "Manifest generated successfully"
  log "Output: $OUTPUT_PATH"
}
# =================================================
# ENTRYPOINT
# =================================================
main