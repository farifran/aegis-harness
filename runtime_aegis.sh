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

mode_requires_execution_surface() {
  local execution_engine="${AEGIS_EXECUTION_ENGINES[$AEGIS_MODE]:-}"

  [[ "${execution_engine}" == "aider" ]]
}

# =========================================================
# CLEANUP
# =========================================================

cleanup_runtime() {

  set +e

  runtime_log "Starting runtime-owned cleanup..."

  if [[ "${AEGIS_RUNTIME_REMOVE_EXECUTION_SURFACE}" == "true" ]] \
    && [[ "${AEGIS_EXECUTION_SURFACE_ACTIVE}" == "true" ]]; then

    if [[ -d "${AEGIS_EXECUTION_SURFACE_PATH:-}" ]]; then
      git worktree remove \
        --force \
        "${AEGIS_EXECUTION_SURFACE_PATH}" \
        >/dev/null 2>&1 || true
    fi

    git worktree prune \
      >/dev/null 2>&1 || true
  fi

  if [[ "${AEGIS_RUNTIME_REMOVE_CAPABILITY_ENV}" == "true" ]]; then
    rm -rf "${AEGIS_CAPABILITY_ENV_DIR}" \
      >/dev/null 2>&1 || true
  fi

  if [[ "${AEGIS_RUNTIME_REMOVE_CAPABILITY_PAYLOADS}" == "true" ]]; then
    rm -rf "${AEGIS_CAPABILITY_PAYLOAD_DIR}" \
      >/dev/null 2>&1 || true
  fi

  runtime_log "Runtime cleanup completed"

  set -e
}

trap cleanup_runtime EXIT
trap 'runtime_warn "Interrupted"; exit 130' INT TERM

# =========================================================
# EPISTEMIC HANDOVER
# =========================================================

handover_schema_is_valid() {

  local handover_file="$1"

  jq -e '
    type == "object"
    and ((keys | sort) == [
      "incomplete_observations",
      "insufficient_evidence",
      "observed_limitations",
      "uninspected_areas"
    ])
    and (.incomplete_observations | type == "array")
    and (.uninspected_areas | type == "array")
    and (.insufficient_evidence | type == "array")
    and (.observed_limitations | type == "array")
    and (
      [
        .incomplete_observations[],
        .uninspected_areas[],
        .insufficient_evidence[],
        .observed_limitations[]
      ] | all(type == "string")
    )
  ' "${handover_file}" >/dev/null 2>&1
}

handover_size_is_valid() {

  local handover_file="$1"
  local handover_size_bytes

  [[ -f "${handover_file}" ]] || return 1

  handover_size_bytes="$(
    wc -c < "${handover_file}"
  )"

  [[ "${handover_size_bytes}" -le "${AEGIS_EPISTEMIC_HANDOVER_MAX_BYTES}" ]]
}

write_empty_epistemic_handover() {

  local handover_file="$1"

  jq -n \
    '{
      incomplete_observations: [],
      uninspected_areas: [],
      insufficient_evidence: [],
      observed_limitations: []
    }' > "${handover_file}" \
    || runtime_fatal "failed_to_initialize_epistemic_handover: ${handover_file}"
}

prepare_runtime_owned_epistemic_handover() {

  local handover_file="$1"
  local last_good_handover_file="$2"

  local handover_is_valid="false"
  local last_good_handover_is_valid="false"

  if [[ -f "${handover_file}" ]] \
    && handover_schema_is_valid "${handover_file}" \
    && handover_size_is_valid "${handover_file}"; then
    handover_is_valid="true"
  fi

  if [[ -f "${last_good_handover_file}" ]] \
    && handover_schema_is_valid "${last_good_handover_file}" \
    && handover_size_is_valid "${last_good_handover_file}"; then
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

  if [[ "${last_good_handover_is_valid}" != "true" ]]; then
    cp \
      "${handover_file}" \
      "${last_good_handover_file}" \
      || runtime_fatal "failed_to_seed_last_good_epistemic_handover"
  fi

  handover_schema_is_valid "${handover_file}" \
    || runtime_fatal "invalid_epistemic_handover_runtime_state"

  handover_size_is_valid "${handover_file}" \
    || runtime_fatal "epistemic_handover_runtime_state_exceeds_max_bytes"

  handover_schema_is_valid "${last_good_handover_file}" \
    || runtime_fatal "invalid_last_good_epistemic_handover_runtime_state"

  handover_size_is_valid "${last_good_handover_file}" \
    || runtime_fatal "last_good_epistemic_handover_runtime_state_exceeds_max_bytes"
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
}

# =========================================================
# RESIDUE CLEANUP
# =========================================================

remove_stale_runtime_residue() {

  runtime_log "Removing stale execution-surface residue..."

  if [[ "${AEGIS_RUNTIME_REMOVE_EXECUTION_SURFACE}" == "true" ]] \
    && mode_requires_execution_surface; then

    if git worktree list | grep -q "${AEGIS_EXECUTION_SURFACE_PATH}"; then
      git worktree remove \
        --force \
        "${AEGIS_EXECUTION_SURFACE_PATH}" \
        >/dev/null 2>&1 || true
    fi

    git worktree prune \
      >/dev/null 2>&1 || true
  fi

  if [[ "${AEGIS_RUNTIME_REMOVE_CAPABILITY_ENV}" == "true" ]]; then
    rm -rf "${AEGIS_CAPABILITY_ENV_DIR}" \
      >/dev/null 2>&1 || true
  fi

  if [[ "${AEGIS_RUNTIME_REMOVE_CAPABILITY_PAYLOADS}" == "true" ]]; then
    rm -rf "${AEGIS_CAPABILITY_PAYLOAD_DIR}" \
      >/dev/null 2>&1 || true
  fi
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

  rm -rf "${AEGIS_CAPABILITY_ENV_DIR}" \
    >/dev/null 2>&1 || true

  rm -rf "${AEGIS_CAPABILITY_PAYLOAD_DIR}" \
    >/dev/null 2>&1 || true

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

  handover_schema_is_valid "${AEGIS_EPISTEMIC_HANDOVER_FILE}" \
    || runtime_fatal "invalid_epistemic_handover_after_mode_execution"

  handover_size_is_valid "${AEGIS_EPISTEMIC_HANDOVER_FILE}" \
    || runtime_fatal "epistemic_handover_after_mode_execution_exceeds_max_bytes"

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
  remove_stale_runtime_residue
  prepare_execution_surface
  prepare_runtime_owned_capability_surfaces
  materialize_runtime_owned_capability_manifest
  execute_mode
  promote_epistemic_handover
}

main "$@"