#!/usr/bin/env bash

# =========================================================
# AEGIS HARNESS — RUNTIME AUTHORITY
# =========================================================
#
# Version: 2.5
# Layer: Runtime Sovereignty
# Status: Grounding Selective
#
# Responsibilities:
#
# - sovereign orchestration
# - disposable execution lifecycle
# - execution identity propagation
# - worktree lifecycle
# - runtime cleanup
# - continuity promotion
# - topology validation
# - policy coercion
#
# The runtime intentionally owns:
#
# - orchestration
# - continuity
# - persistence decisions
# - cleanup
# - execution sequencing
# - worktree lifecycle
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
# WORKTREE
# =========================================================

export AEGIS_WORKTREE_PATH="${AEGIS_WORKTREE_ROOT}/${AEGIS_MODE}"

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

# =========================================================
# CLEANUP
# =========================================================

cleanup_runtime() {

  set +e

  runtime_log "Starting runtime cleanup..."

  if [[ "${AEGIS_RUNTIME_REMOVE_WORKTREE}" == "true" ]]; then

    if [[ -d "${AEGIS_WORKTREE_PATH:-}" ]]; then
      git worktree remove \
        --force \
        "${AEGIS_WORKTREE_PATH}" \
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
    AEGIS_WORKTREE_ROOT
    AEGIS_RUNTIME_DIR
    AEGIS_CAPABILITY_ENV_DIR
    AEGIS_CAPABILITY_PAYLOAD_DIR
    AEGIS_ACTIVE_TASK_FILE
    AEGIS_LAST_GOOD_TASK_FILE
    AEGIS_GROUNDING_MAX_TOTAL_BYTES
    AEGIS_GROUNDING_MAX_PAYLOAD_BYTES
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

  declare -p AEGIS_MODE_GROUNDING_PROFILE >/dev/null 2>&1 \
    || runtime_fatal "missing_grounding_profile_registry"

  [[ -f "${AEGIS_SKILL_FILE}" ]] \
    || runtime_fatal "missing_skill_contract"

  [[ -n "${AEGIS_EXECUTION_ENGINES[$AEGIS_MODE]:-}" ]] \
    || runtime_fatal "unknown_mode"

  [[ -n "${AEGIS_MODE_GROUNDING_PROFILE[$AEGIS_MODE]:-}" ]] \
    || runtime_fatal "missing_mode_grounding_profile"

  mkdir -p "${AEGIS_RUNTIME_DIR}"
  touch "${AEGIS_ACTIVE_TASK_FILE}"
  touch "${AEGIS_LAST_GOOD_TASK_FILE}"
}

# =========================================================
# RESIDUE CLEANUP
# =========================================================

remove_stale_runtime_residue() {

  runtime_log "Removing stale runtime residue..."

  if [[ "${AEGIS_RUNTIME_REMOVE_WORKTREE}" == "true" ]]; then

    if git worktree list | grep -q "${AEGIS_WORKTREE_PATH}"; then
      git worktree remove \
        --force \
        "${AEGIS_WORKTREE_PATH}" \
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

  runtime_log "Preparing disposable execution surface..."

  mkdir -p "${AEGIS_WORKTREE_ROOT}"

  git worktree add \
    --force \
    --detach \
    "${AEGIS_WORKTREE_PATH}" \
    HEAD \
    >/dev/null

  [[ -d "${AEGIS_WORKTREE_PATH}" ]] \
    || runtime_fatal "failed_to_materialize_worktree"
}

# =========================================================
# EXECUTION
# =========================================================

execute_mode() {

  runtime_log "Executing mode: ${AEGIS_MODE}"

  local execution_output

  execution_output="$(
    bash scripts/execute_mode.sh \
      "${AEGIS_SKILL_FILE}" \
      "${AEGIS_MODE}" \
      "${AEGIS_ACTIVE_TASK_FILE}"
  )"

  echo "${execution_output}"

  echo "${execution_output}" | grep -q "${AEGIS_ARTIFACT_BEGIN_MARKER}" \
    || runtime_fatal "missing_artifact"

  echo "${execution_output}" | grep -q "${AEGIS_ARTIFACT_END_MARKER}" \
    || runtime_fatal "missing_artifact"

  runtime_log "Execution completed successfully"
}

# =========================================================
# CONTINUITY
# =========================================================

promote_runtime_continuity() {

  runtime_log "Promoting runtime continuity..."

  cp \
    "${AEGIS_ACTIVE_TASK_FILE}" \
    "${AEGIS_LAST_GOOD_TASK_FILE}"
}

# =========================================================
# MAIN
# =========================================================

main() {

  validate_runtime_environment
  remove_stale_runtime_residue
  prepare_execution_surface
  execute_mode
  promote_runtime_continuity
}

main "$@"