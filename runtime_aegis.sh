#!/usr/bin/env bash

# =========================================================
# AEGIS HARNESS — SOVEREIGN RUNTIME
# =========================================================
#
# Version: 2.2
# Layer: Runtime Sovereignty
# Status: Hardened
#
# Responsibilities:
#
# - runtime sovereignty
# - execution orchestration
# - worktree lifecycle
# - capability lifecycle
# - continuity lifecycle
# - cleanup enforcement
# - protocol topology validation
# - execution identity
# - failure containment
#
# The runtime intentionally does NOT:
#
# - perform cognition
# - interpret semantic meaning
# - mutate architecture
# - infer intent
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

readonly AEGIS_EXECUTION_ID="$(
  date +%s
)-$RANDOM"

readonly AEGIS_EXECUTION_TIMESTAMP="$(
  date -u +"%Y-%m-%dT%H:%M:%SZ"
)"

# =========================================================
# MODE CONFIGURATION
# =========================================================

readonly AEGIS_MODE="${1:-discovery}"

readonly AEGIS_SKILL_FILE=".skills/${AEGIS_MODE}.md"

readonly AEGIS_WORKTREE_PATH="${AEGIS_WORKTREE_ROOT}/${AEGIS_MODE}"

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

  #
  # Remove worktree safely.
  #

  if git worktree list | grep -q "${AEGIS_WORKTREE_PATH}"; then

    git worktree remove \
      --force \
      "${AEGIS_WORKTREE_PATH}" \
      >/dev/null 2>&1 || true
  fi

  #
  # Remove runtime execution residue.
  #

  rm -rf "${AEGIS_CAPABILITY_ENV_DIR}" \
    >/dev/null 2>&1 || true

  rm -rf "${AEGIS_CAPABILITY_PAYLOAD_DIR}" \
    >/dev/null 2>&1 || true

  #
  # Cleanup verification.
  #

  if [[ -d "${AEGIS_WORKTREE_PATH}" ]]; then
    runtime_warn "worktree_cleanup_incomplete"
  fi

  if [[ -d "${AEGIS_CAPABILITY_ENV_DIR}" ]]; then
    runtime_warn "capability_env_cleanup_incomplete"
  fi

  if [[ -d "${AEGIS_CAPABILITY_PAYLOAD_DIR}" ]]; then
    runtime_warn "capability_payload_cleanup_incomplete"
  fi

  runtime_log "Runtime cleanup completed"

  set -e
}

trap cleanup_runtime EXIT
trap 'runtime_warn "Interrupted"; exit 130' INT TERM

# =========================================================
# VALIDATION
# =========================================================

validate_runtime_configuration() {

  local required_vars=(
    AEGIS_WORKTREE_ROOT
    AEGIS_CAPABILITY_ENV_DIR
    AEGIS_CAPABILITY_PAYLOAD_DIR
    AEGIS_ACTIVE_TASK_FILE
    AEGIS_LAST_GOOD_TASK_FILE
    AEGIS_EXECUTION_ENGINES
    AEGIS_ARTIFACT_BEGIN_MARKER
    AEGIS_ARTIFACT_END_MARKER
  )

  local var_name

  for var_name in "${required_vars[@]}"; do

    declare -p "${var_name}" \
      >/dev/null 2>&1 \
      || runtime_fatal "missing_runtime_variable: ${var_name}"

  done
}

validate_runtime_dependencies() {

  local required_commands=(
    git
    jq
    curl
  )

  local command_name

  for command_name in "${required_commands[@]}"; do

    command -v "${command_name}" \
      >/dev/null 2>&1 \
      || runtime_fatal "missing_dependency: ${command_name}"

  done
}

validate_execution_mode() {

  [[ -f "${AEGIS_SKILL_FILE}" ]] \
    || runtime_fatal "missing_skill_contract"

  [[ -n "${AEGIS_EXECUTION_ENGINES[$AEGIS_MODE]:-}" ]] \
    || runtime_fatal "unsupported_execution_mode"
}

validate_provider_environment() {

  local required_provider_vars=(
    OPENAI_API_KEY
    OPENAI_API_BASE
    OPENAI_MODEL_ANALYSIS
  )

  local provider_var

  for provider_var in "${required_provider_vars[@]}"; do

    [[ -n "${!provider_var:-}" ]] \
      || runtime_fatal "missing_provider_variable: ${provider_var}"

  done
}

# =========================================================
# RUNTIME RESIDUE
# =========================================================

remove_stale_runtime_residue() {

  runtime_log "Removing stale runtime residue..."

  rm -rf "${AEGIS_CAPABILITY_ENV_DIR}" \
    >/dev/null 2>&1 || true

  rm -rf "${AEGIS_CAPABILITY_PAYLOAD_DIR}" \
    >/dev/null 2>&1 || true

  rm -rf "${AEGIS_WORKTREE_PATH}" \
    >/dev/null 2>&1 || true

  git worktree prune \
    >/dev/null 2>&1 || true
}

# =========================================================
# EXECUTION SURFACE
# =========================================================

prepare_execution_surface() {

  runtime_log "Preparing disposable execution surface..."

  mkdir -p "${AEGIS_WORKTREE_ROOT}"

  git worktree add \
    --detach \
    --force \
    "${AEGIS_WORKTREE_PATH}" \
    HEAD
}

# =========================================================
# CONTINUITY
# =========================================================

promote_runtime_continuity() {

  runtime_log "Promoting runtime continuity..."

  cp \
    "${AEGIS_ACTIVE_TASK_FILE}" \
    "${AEGIS_LAST_GOOD_TASK_FILE}" \
    >/dev/null 2>&1 || true
}

# =========================================================
# ARTIFACT EXTRACTION
# =========================================================

extract_artifact() {

  local executor_output="$1"

  local artifact

  artifact="$(
    echo "${executor_output}" \
      | sed -n "/${AEGIS_ARTIFACT_BEGIN_MARKER}/,/${AEGIS_ARTIFACT_END_MARKER}/p" \
      | sed "1d;\$d"
  )"

  [[ -n "${artifact}" ]] \
    || runtime_fatal "missing_artifact"

  echo "${artifact}"
}

validate_artifact() {

  local artifact="$1"

  echo "${artifact}" \
    | jq empty \
    >/dev/null 2>&1 \
    || runtime_fatal "invalid_artifact_json"

  local artifact_mode

  artifact_mode="$(
    echo "${artifact}" \
      | jq -r '.mode // empty'
  )"

  [[ "${artifact_mode}" == "${AEGIS_MODE}" ]] \
    || runtime_fatal "artifact_mode_mismatch"
}

# =========================================================
# EXECUTION
# =========================================================

execute_mode() {

  runtime_log "Executing mode: ${AEGIS_MODE}"

  export AEGIS_WORKTREE_PATH
  export AEGIS_EXECUTION_ID
  export AEGIS_EXECUTION_TIMESTAMP

  local executor_output

  executor_output="$(
    bash scripts/execute_mode.sh \
      "${AEGIS_SKILL_FILE}" \
      "${AEGIS_MODE}" \
      "${AEGIS_ACTIVE_TASK_FILE}"
  )"

  local artifact

  artifact="$(extract_artifact "${executor_output}")"

  validate_artifact "${artifact}"

  promote_runtime_continuity

  echo "${AEGIS_ARTIFACT_BEGIN_MARKER}"
  echo "${artifact}"
  echo "${AEGIS_ARTIFACT_END_MARKER}"
}

# =========================================================
# MAIN
# =========================================================

main() {

  runtime_log "Initializing runtime..."

  validate_runtime_configuration

  validate_runtime_dependencies

  validate_provider_environment

  validate_execution_mode

  remove_stale_runtime_residue

  prepare_execution_surface

  execute_mode

  runtime_log "Execution completed successfully"
}

main "$@"