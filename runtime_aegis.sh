#!/usr/bin/env bash

# =========================================================
# AEGIS HARNESS — RUNTIME AUTHORITY
# =========================================================
#
# Version: 2.5
# Layer: Runtime Sovereignty
# Status: Operational Memory Hardened
#
# Responsibilities:
#
# - sovereign orchestration
# - disposable execution surface lifecycle
# - execution identity propagation
# - artifact promotion
# - runtime-owned epistemic handover lifecycle
# - runtime cleanup
# - capability environment cleanup
# - capability payload cleanup
# - runtime contract validation
# - policy enforcement
#
# The runtime intentionally owns:
#
# - orchestration
# - artifact promotion
# - epistemic handover lifecycle
# - persistence decisions
# - cleanup
# - execution sequencing
# - execution surface lifecycle
#
# The runtime intentionally does NOT:
#
# - reason semantically
# - interpret cognition
# - redesign architecture
# - mutate implicitly
#
# =========================================================

set -Eeuo pipefail

# =========================================================
# ROOT RESOLUTION
# =========================================================

readonly AEGIS_RUNTIME_ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)"

cd "${AEGIS_RUNTIME_ROOT}"

# =========================================================
# CONFIGURATION
# =========================================================

[[ -f ".harness/config.sh" ]] || {
  echo "[AEGIS][RUNTIME][FATAL] missing_config" >&2
  exit 1
}

source ".harness/config.sh"

# =========================================================
# EXECUTION IDENTITY
# =========================================================

export AEGIS_EXECUTION_ID="$(
  date +%s
)-$$"

export AEGIS_EXECUTION_TIMESTAMP="$(
  date -u +"%Y-%m-%dT%H:%M:%SZ"
)"

# =========================================================
# MODE
# =========================================================

readonly AEGIS_MODE="${1:-discovery}"
readonly AEGIS_SKILL_FILE=".skills/${AEGIS_MODE}.md"

# =========================================================
# EXECUTION SURFACE PATH
# =========================================================

export AEGIS_EXECUTION_SURFACE_PATH="${AEGIS_EXECUTION_SURFACE_ROOT}/${AEGIS_MODE}"

AEGIS_EXECUTION_SURFACE_ACTIVE="false"

# =========================================================
# LOGGING
# =========================================================

runtime_log() {
  echo "[AEGIS][RUNTIME] $*" >&2
}

runtime_warn() {
  echo "[AEGIS][RUNTIME][WARN] $*" >&2
}

runtime_fatal() {
  echo "[AEGIS][RUNTIME][FATAL] $*" >&2
  exit 1
}

readonly AEGIS_EPISTEMIC_HANDOVER_LIB="${AEGIS_RUNTIME_ROOT}/scripts/lib/epistemic_handover.sh"

[[ -f "${AEGIS_EPISTEMIC_HANDOVER_LIB}" ]] || {
  echo "[AEGIS][RUNTIME][FATAL] missing_epistemic_handover_library" >&2
  exit 1
}

source "${AEGIS_EPISTEMIC_HANDOVER_LIB}"

apply_default_investigation_input() {
  export AEGIS_INVESTIGATION_INPUT="${AEGIS_DEFAULT_INVESTIGATION_INPUT}"

  printf '%s\n' \
    "[AEGIS][RUNTIME]" \
    "No investigation input provided." \
    "Using default exploratory investigation." >&2
}

mode_requires_execution_surface() {
  local execution_engine="${AEGIS_EXECUTION_ENGINES[$AEGIS_MODE]:-}"

  [[ "${execution_engine}" == "aider" ]]
}

mode_starts_new_investigation() {
  [[ "${AEGIS_MODE}" == "discovery" ]]
}

artifact_snapshot_investigation_input_from_handover() {

  local handover_file="$1"

  if ! handover_schema_is_valid "${handover_file}"; then
    return 0
  fi

  jq -r '
    if (
      (.artifact_snapshot | type == "object")
      and (.artifact_snapshot.investigation_input? | type == "string")
      and (.artifact_snapshot.investigation_input | length > 0)
    ) then
      .artifact_snapshot.investigation_input
    else
      empty
    end
  ' "${handover_file}" 2>/dev/null || true
}

resolve_runtime_investigation_input() {

  local current_investigation_input
  current_investigation_input="$({
    artifact_snapshot_investigation_input_from_handover "${AEGIS_EPISTEMIC_HANDOVER_FILE}"
  })"

  if mode_starts_new_investigation; then
    if [[ -n "${AEGIS_INVESTIGATION_INPUT:-}" ]]; then
      export AEGIS_INVESTIGATION_INPUT
      return 0
    fi

    apply_default_investigation_input
    return 0
  fi

  if [[ -n "${AEGIS_INVESTIGATION_INPUT:-}" ]] \
    && [[ -n "${current_investigation_input}" ]] \
    && [[ "${AEGIS_INVESTIGATION_INPUT}" != "${current_investigation_input}" ]]; then
    runtime_fatal "investigation_input_mismatch"
  fi

  if [[ -n "${AEGIS_INVESTIGATION_INPUT:-}" ]]; then
    export AEGIS_INVESTIGATION_INPUT
    return 0
  fi

  if [[ -n "${current_investigation_input}" ]]; then
    export AEGIS_INVESTIGATION_INPUT="${current_investigation_input}"
    return 0
  fi

  apply_default_investigation_input
}

# =========================================================
# CLEANUP
# =========================================================

cleanup_runtime() {

  set +e

  runtime_log "Starting runtime-owned cleanup..."

  if [[ "${AEGIS_RUNTIME_REMOVE_EXECUTION_SURFACE}" == "true" ]] \
    && [[ "${AEGIS_EXECUTION_SURFACE_ACTIVE}" == "true" ]]; then
    remove_runtime_owned_execution_surface_if_present
  fi

  remove_runtime_owned_capability_surfaces

  runtime_log "Runtime cleanup completed"

  set -e
}

trap cleanup_runtime EXIT
trap 'runtime_warn "Interrupted"; exit 130' INT TERM

# =========================================================
# EPISTEMIC HANDOVER
# =========================================================

handover_size_is_valid() {

  local handover_file="$1"
  local handover_size_bytes

  [[ -f "${handover_file}" ]] || return 1

  handover_size_bytes="$(
    wc -c < "${handover_file}"
  )"

  [[ "${handover_size_bytes}" -le "${AEGIS_EPISTEMIC_HANDOVER_MAX_BYTES}" ]]
}

runtime_owned_epistemic_handover_is_valid() {

  local handover_file="$1"

  [[ -f "${handover_file}" ]] \
    && handover_schema_is_valid "${handover_file}" \
    && handover_size_is_valid "${handover_file}"
}

assert_valid_runtime_owned_epistemic_handover() {

  local handover_file="$1"
  local invalid_error="$2"
  local size_error="$3"

  handover_schema_is_valid "${handover_file}" \
    || runtime_fatal "${invalid_error}"

  handover_size_is_valid "${handover_file}" \
    || runtime_fatal "${size_error}"
}

write_empty_epistemic_handover() {

  local handover_file="$1"

  write_runtime_owned_epistemic_handover \
    "${handover_file}" \
    'null' \
    "$(write_empty_epistemic_handover_state_json)"
}

epistemic_state_json_from_promoted_artifact() {

  local promoted_artifact_json="$1"
  local promoted_epistemic_state_json

  promoted_epistemic_state_json="$({
    printf '%s' "${promoted_artifact_json}" \
      | jq -c '
          if has("handover_attention") then
            .handover_attention
          else
            null
          end
        '
  })" || runtime_fatal "failed_to_extract_promoted_artifact_handover_attention"

  if [[ "${promoted_epistemic_state_json}" == "null" ]]; then
    write_empty_epistemic_handover_state_json
    return 0
  fi

  validate_epistemic_state_json "${promoted_epistemic_state_json}" \
    || runtime_fatal "invalid_promoted_artifact_handover_attention"

  printf '%s' "${promoted_epistemic_state_json}"
}

artifact_snapshot_json_from_promoted_artifact() {

  local promoted_artifact_json="$1"

  printf '%s' "${promoted_artifact_json}" \
    | jq -c \
        --arg generated_at "${AEGIS_EXECUTION_TIMESTAMP}" \
        --arg investigation_input "${AEGIS_INVESTIGATION_INPUT}" '
        del(.handover_attention, .investigation_input)
        | . + {investigation_input: $investigation_input}
        | . + (if has("generated_at") then {} else {generated_at: $generated_at} end)
      '
}

write_runtime_owned_epistemic_handover() {

  local handover_file="$1"
  local artifact_snapshot_json="$2"
  local epistemic_state_json="$3"
  local tmp_handover_file

  tmp_handover_file="$(mktemp)"

  jq -n \
    --argjson artifact_snapshot "${artifact_snapshot_json}" \
    --argjson epistemic_state "${epistemic_state_json}" \
    '{
      artifact_snapshot: $artifact_snapshot,
      epistemic_state: $epistemic_state
    }' > "${tmp_handover_file}" \
    || runtime_fatal "failed_to_materialize_epistemic_handover"

  handover_size_is_valid "${tmp_handover_file}" \
    || runtime_fatal "epistemic_handover_runtime_state_exceeds_max_bytes"

  mv "${tmp_handover_file}" "${handover_file}" \
    || runtime_fatal "failed_to_commit_epistemic_handover"
}

normalize_runtime_owned_epistemic_handover() {

  local handover_file="$1"
  local artifact_snapshot_json
  local epistemic_state_json

  artifact_snapshot_json="$({
    artifact_snapshot_json_from_handover "${handover_file}"
  })" || runtime_fatal "invalid_epistemic_handover_runtime_state"

  epistemic_state_json="$({
    epistemic_state_json_from_handover "${handover_file}"
  })" || runtime_fatal "invalid_epistemic_handover_runtime_state"

  write_runtime_owned_epistemic_handover \
    "${handover_file}" \
    "${artifact_snapshot_json}" \
    "${epistemic_state_json}"
}

remove_runtime_owned_execution_surface_if_present() {

  if git worktree list | grep -q "${AEGIS_EXECUTION_SURFACE_PATH}" \
    || [[ -d "${AEGIS_EXECUTION_SURFACE_PATH:-}" ]]; then
    git worktree remove \
      --force \
      "${AEGIS_EXECUTION_SURFACE_PATH}" \
      >/dev/null 2>&1 || true
  fi

  git worktree prune \
    >/dev/null 2>&1 || true
}

remove_runtime_owned_capability_surfaces() {

  local respect_cleanup_policy="${1:-true}"

  if [[ "${respect_cleanup_policy}" != "false" ]] \
    && [[ "${AEGIS_RUNTIME_REMOVE_CAPABILITY_ENV}" != "true" ]]; then
    :
  else
    rm -rf "${AEGIS_CAPABILITY_ENV_DIR}" \
      >/dev/null 2>&1 || true
  fi

  if [[ "${respect_cleanup_policy}" != "false" ]] \
    && [[ "${AEGIS_RUNTIME_REMOVE_CAPABILITY_PAYLOADS}" != "true" ]]; then
    :
  else
    rm -rf "${AEGIS_CAPABILITY_PAYLOAD_DIR}" \
      >/dev/null 2>&1 || true
  fi
}

prepare_runtime_owned_epistemic_handover() {

  local handover_file="$1"
  local last_good_handover_file="$2"

  local handover_is_valid="false"
  local last_good_handover_is_valid="false"

  if runtime_owned_epistemic_handover_is_valid "${handover_file}"; then
    handover_is_valid="true"
  fi

  if runtime_owned_epistemic_handover_is_valid "${last_good_handover_file}"; then
    last_good_handover_is_valid="true"
  fi

  if [[ "${handover_is_valid}" != "true" ]]; then

    if [[ "${last_good_handover_is_valid}" == "true" ]]; then
      cp \
        "${last_good_handover_file}" \
        "${handover_file}" \
        || runtime_fatal "failed_to_restore_epistemic_handover"
    else
      write_empty_epistemic_handover "${handover_file}"
    fi
  fi

  normalize_runtime_owned_epistemic_handover "${handover_file}"

  if [[ "${last_good_handover_is_valid}" != "true" ]]; then
    cp \
      "${handover_file}" \
      "${last_good_handover_file}" \
      || runtime_fatal "failed_to_seed_last_good_epistemic_handover"
  else
    normalize_runtime_owned_epistemic_handover "${last_good_handover_file}"
  fi

  assert_valid_runtime_owned_epistemic_handover \
    "${handover_file}" \
    "invalid_epistemic_handover_runtime_state" \
    "epistemic_handover_runtime_state_exceeds_max_bytes"

  assert_valid_runtime_owned_epistemic_handover \
    "${last_good_handover_file}" \
    "invalid_last_good_epistemic_handover_runtime_state" \
    "last_good_epistemic_handover_runtime_state_exceeds_max_bytes"
}

reset_runtime_owned_epistemic_handover_for_new_investigation() {

  if ! mode_starts_new_investigation; then
    return
  fi

  runtime_log "Resetting runtime-owned epistemic handover for new investigation boundary..."

  write_empty_epistemic_handover "${AEGIS_EPISTEMIC_HANDOVER_FILE}"

  cp \
    "${AEGIS_EPISTEMIC_HANDOVER_FILE}" \
    "${AEGIS_LAST_GOOD_EPISTEMIC_HANDOVER_FILE}" \
    || runtime_fatal "failed_to_reset_last_good_epistemic_handover"
}

# =========================================================
# VALIDATION
# =========================================================

validate_runtime_environment() {

  runtime_log "Initializing runtime..."

  local required_commands=(
    git
    jq
  )

  local command_name
  for command_name in "${required_commands[@]}"; do
    command -v "${command_name}" >/dev/null 2>&1 \
      || runtime_fatal "missing_dependency: ${command_name}"
  done

  local required_runtime_vars=(
    AEGIS_EXECUTION_SURFACE_ROOT
    AEGIS_RUNTIME_DIR
    AEGIS_CAPABILITY_ENV_DIR
    AEGIS_CAPABILITY_PAYLOAD_DIR
    AEGIS_EPISTEMIC_HANDOVER_FILE
    AEGIS_LAST_GOOD_EPISTEMIC_HANDOVER_FILE
    AEGIS_EPISTEMIC_HANDOVER_MAX_BYTES
    AEGIS_EVIDENCE_MAX_TOTAL_BYTES
    AEGIS_CAPABILITY_PAYLOAD_MAX_BYTES
    AEGIS_PROVIDER_MAX_RETRIES
    AEGIS_PROVIDER_RETRY_DELAY
    AEGIS_PROVIDER_CONNECT_TIMEOUT
    AEGIS_PROVIDER_RESPONSE_TIMEOUT
  )

  local runtime_var
  for runtime_var in "${required_runtime_vars[@]}"; do
    [[ -n "${!runtime_var:-}" ]] \
      || runtime_fatal "missing_runtime_variable: ${runtime_var}"
  done

  declare -p AEGIS_EXECUTION_ENGINES >/dev/null 2>&1 \
    || runtime_fatal "missing_execution_engine_registry"

  declare -p AEGIS_MODE_CAPABILITY_MAP >/dev/null 2>&1 \
    || runtime_fatal "missing_capability_envelope_registry"

  declare -p AEGIS_MODE_EVIDENCE_PROFILE >/dev/null 2>&1 \
    || runtime_fatal "missing_evidence_profile_registry"

  [[ -f "${AEGIS_SKILL_FILE}" ]] \
    || runtime_fatal "missing_skill_contract"

  [[ -n "${AEGIS_EXECUTION_ENGINES[$AEGIS_MODE]:-}" ]] \
    || runtime_fatal "unknown_mode"

  [[ -n "${AEGIS_MODE_EVIDENCE_PROFILE[$AEGIS_MODE]:-}" ]] \
    || runtime_fatal "missing_mode_evidence_profile"

  mkdir -p "${AEGIS_RUNTIME_DIR}"
  prepare_runtime_owned_epistemic_handover \
    "${AEGIS_EPISTEMIC_HANDOVER_FILE}" \
    "${AEGIS_LAST_GOOD_EPISTEMIC_HANDOVER_FILE}"

  resolve_runtime_investigation_input
}

# =========================================================
# RESIDUE CLEANUP
# =========================================================

remove_stale_runtime_residue() {

  runtime_log "Removing stale execution-surface residue..."

  if [[ "${AEGIS_RUNTIME_REMOVE_EXECUTION_SURFACE}" == "true" ]] \
    && mode_requires_execution_surface; then
    remove_runtime_owned_execution_surface_if_present
  fi

  remove_runtime_owned_capability_surfaces
}

# =========================================================
# EXECUTION SURFACE
# =========================================================

prepare_execution_surface() {

  if ! mode_requires_execution_surface; then
    runtime_log "Skipping disposable execution surface for mode without execution-surface requirements..."
    return
  fi

  runtime_log "Preparing disposable execution surface..."

  mkdir -p "${AEGIS_EXECUTION_SURFACE_ROOT}"

  git worktree add \
    --force \
    --detach \
    "${AEGIS_EXECUTION_SURFACE_PATH}" \
    HEAD \
    >/dev/null

  [[ -d "${AEGIS_EXECUTION_SURFACE_PATH}" ]] \
    || runtime_fatal "failed_to_materialize_execution_surface"

  AEGIS_EXECUTION_SURFACE_ACTIVE="true"
}

# =========================================================
# CAPABILITY SURFACES
# =========================================================

prepare_runtime_owned_capability_surfaces() {

  runtime_log "Preparing runtime-owned capability surfaces..."

  remove_runtime_owned_capability_surfaces false

  mkdir -p "${AEGIS_CAPABILITY_ENV_DIR}"
  mkdir -p "${AEGIS_CAPABILITY_PAYLOAD_DIR}"

  [[ -d "${AEGIS_CAPABILITY_ENV_DIR}" ]] \
    || runtime_fatal "failed_to_prepare_capability_environment"

  [[ -d "${AEGIS_CAPABILITY_PAYLOAD_DIR}" ]] \
    || runtime_fatal "failed_to_prepare_capability_payload_directory"
}

# =========================================================
# CAPABILITY MANIFEST
# =========================================================

materialize_runtime_owned_capability_manifest() {

  runtime_log "Generating runtime-owned capability manifest..."

  export AEGIS_CAPABILITY_MANIFEST="$(
    bash scripts/capabilities/generate_manifest.sh
  )"

  [[ -n "${AEGIS_CAPABILITY_MANIFEST}" ]] \
    || runtime_fatal "missing_runtime_owned_capability_manifest"

  printf '%s\n' "${AEGIS_CAPABILITY_MANIFEST}" \
    | jq empty \
      >/dev/null 2>&1 \
    || runtime_fatal "invalid_runtime_owned_capability_manifest"
}

# =========================================================
# EXECUTION
# =========================================================

execute_mode() {

  runtime_log "Executing mode: ${AEGIS_MODE}"

  local execution_output
  local artifact_payload

  execution_output="$(
    bash scripts/execute_mode.sh \
      "${AEGIS_SKILL_FILE}" \
      "${AEGIS_MODE}" \
      "${AEGIS_EPISTEMIC_HANDOVER_FILE}"
  )"

  echo "${execution_output}"

  echo "${execution_output}" | grep -q "${AEGIS_ARTIFACT_BEGIN_MARKER}" \
    || runtime_fatal "missing_artifact"

  echo "${execution_output}" | grep -q "${AEGIS_ARTIFACT_END_MARKER}" \
    || runtime_fatal "missing_artifact"

  artifact_payload="$(
    echo "${execution_output}" \
      | sed -n '/AEGIS_ARTIFACT_BEGIN/,/AEGIS_ARTIFACT_END/p' \
      | sed '1d;$d'
  )"

  [[ -n "${artifact_payload}" ]] \
    || runtime_fatal "empty_artifact_payload"

  echo "${artifact_payload}" \
    | jq empty \
      >/dev/null 2>&1 \
    || runtime_fatal "invalid_promoted_artifact_json"

  echo "${artifact_payload}" \
    | jq -e 'type == "object"' \
      >/dev/null 2>&1 \
    || runtime_fatal "invalid_promoted_artifact_shape"

  export AEGIS_PROMOTED_ARTIFACT_PAYLOAD="$({
    printf '%s\n' "${artifact_payload}" | jq -c '.'
  })"

  [[ -n "${AEGIS_PROMOTED_ARTIFACT_PAYLOAD}" ]] \
    || runtime_fatal "failed_to_compact_promoted_artifact"

  runtime_log "Promoting validated artifact..."

  echo "${AEGIS_ARTIFACT_BEGIN_MARKER}"
  echo "${artifact_payload}"
  echo "${AEGIS_ARTIFACT_END_MARKER}"

  runtime_log "Execution completed successfully"
}

# =========================================================
# EPISTEMIC HANDOVER
# =========================================================

promote_epistemic_handover() {

  runtime_log "Updating epistemic handover..."

  [[ -n "${AEGIS_PROMOTED_ARTIFACT_PAYLOAD:-}" ]] \
    || runtime_fatal "missing_promoted_artifact_for_handover"

  local epistemic_state_json
  local artifact_snapshot_json

  epistemic_state_json="$({
    epistemic_state_json_from_promoted_artifact "${AEGIS_PROMOTED_ARTIFACT_PAYLOAD}"
  })" || runtime_fatal "invalid_epistemic_handover_after_mode_execution"

  artifact_snapshot_json="$({
    artifact_snapshot_json_from_promoted_artifact "${AEGIS_PROMOTED_ARTIFACT_PAYLOAD}"
  })" || runtime_fatal "failed_to_materialize_artifact_snapshot"

  write_runtime_owned_epistemic_handover \
    "${AEGIS_EPISTEMIC_HANDOVER_FILE}" \
    "${artifact_snapshot_json}" \
    "${epistemic_state_json}"

  assert_valid_runtime_owned_epistemic_handover \
    "${AEGIS_EPISTEMIC_HANDOVER_FILE}" \
    "invalid_epistemic_handover_after_mode_execution" \
    "epistemic_handover_after_mode_execution_exceeds_max_bytes"

  cp \
    "${AEGIS_EPISTEMIC_HANDOVER_FILE}" \
    "${AEGIS_LAST_GOOD_EPISTEMIC_HANDOVER_FILE}" \
    || runtime_fatal "failed_to_promote_epistemic_handover"
}

# =========================================================
# MAIN
# =========================================================

main() {

  validate_runtime_environment
  reset_runtime_owned_epistemic_handover_for_new_investigation
  remove_stale_runtime_residue
  prepare_execution_surface
  prepare_runtime_owned_capability_surfaces
  materialize_runtime_owned_capability_manifest
  execute_mode
  promote_epistemic_handover
}

main "$@"