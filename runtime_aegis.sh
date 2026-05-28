#!/usr/bin/env bash
# =================================================
# AEGIS HARNESS — RUNTIME AUTHORITY
# =================================================
#
# Purpose:
# - lifecycle orchestration
# - capability environment authority
# - disposable execution management
# - runtime-owned continuity
# - deterministic execution topology
#
# Runtime owns:
# - orchestration
# - continuity lifecycle
# - capability exposure
# - capability payload lifecycle
# - sandbox lifecycle
# - persistence decisions
# - cleanup
#
# Runtime intentionally does NOT:
# - reason semantically
# - interpret architecture
# - own cognition
# - infer intent
#
# =================================================
set -Eeuo pipefail
# =================================================
# ROOT RESOLUTION
# =================================================
ROOT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")" \
  && pwd
)"
CONFIG_FILE="$ROOT_DIR/.harness/config.sh"
EXECUTOR="$ROOT_DIR/scripts/execute_mode.sh"
# =================================================
# VALIDATION
# =================================================
[[ -f "$CONFIG_FILE" ]] \
  || {
    echo "[AEGIS][RUNTIME][FATAL] missing_config"
    exit 1
  }
source "$CONFIG_FILE"
# =================================================
# HELPERS
# =================================================
log() {
  printf '[AEGIS][RUNTIME] %s\n' "$1"
}
fatal() {
  printf '[AEGIS][RUNTIME][FATAL] %s\n' "$1"
  exit 1
}
# =================================================
# RUNTIME PATHS
# =================================================
RUNTIME_DIR="$ROOT_DIR/$AEGIS_RUNTIME_DIR"
CAPABILITY_ENV_DIR="$ROOT_DIR/$AEGIS_CAPABILITY_ENV_DIR"
CAPABILITY_PAYLOAD_DIR="$ROOT_DIR/$AEGIS_CAPABILITY_PAYLOAD_DIR"
ACTIVE_TASK_FILE="$ROOT_DIR/$AEGIS_ACTIVE_TASK_FILE"
LAST_GOOD_TASK_FILE="$ROOT_DIR/$AEGIS_LAST_GOOD_TASK_FILE"
WORKTREE_ROOT="$ROOT_DIR/.harness/worktrees"
# =================================================
# SELF CONSISTENCY
# =================================================
validate_runtime_files() {
  for file in "${AEGIS_REQUIRED_RUNTIME_FILES[@]}"; do
    [[ -f "$ROOT_DIR/$file" ]] \
      || fatal "missing_runtime_file: $file"
  done
}
validate_runtime_directories() {
  for dir in "${AEGIS_REQUIRED_RUNTIME_DIRECTORIES[@]}"; do
    [[ -d "$ROOT_DIR/$dir" ]] \
      || fatal "missing_runtime_directory: $dir"
  done
}
validate_mode_contracts() {
  local all_modes
  all_modes=(
    "${AEGIS_ANALYSIS_MODES[@]}"
    "${AEGIS_MUTATION_MODES[@]}"
  )
  for mode in "${all_modes[@]}"; do
    contract="$ROOT_DIR/.skills/$mode.md"
    [[ -f "$contract" ]] \
      || fatal "missing_mode_contract: $mode"
  done
}
validate_executor_integrity() {
  grep -q "CAPABILITY_PAYLOAD_DIR" "$EXECUTOR" \
    || fatal "executor_missing_capability_payload_support"
  grep -q "materialize_capability_payloads" "$EXECUTOR" \
    || fatal "executor_missing_payload_materialization"
  grep -q "validate_json_payload" "$EXECUTOR" \
    || fatal "executor_missing_json_validation"
}
validate_runtime_topology() {
  log "Validating runtime topology..."
  validate_runtime_files
  validate_runtime_directories
  validate_mode_contracts
  validate_executor_integrity
}
# =================================================
# RUNTIME STATE
# =================================================
initialize_runtime_state() {
  mkdir -p "$RUNTIME_DIR"
  mkdir -p "$WORKTREE_ROOT"
  mkdir -p "$CAPABILITY_ENV_DIR"
  mkdir -p "$CAPABILITY_PAYLOAD_DIR"
  touch "$ACTIVE_TASK_FILE"
}
# =================================================
# CAPABILITY LIFECYCLE
# =================================================
reset_capability_state() {
  rm -rf "$CAPABILITY_ENV_DIR"
  rm -rf "$CAPABILITY_PAYLOAD_DIR"
  mkdir -p "$CAPABILITY_ENV_DIR"
  mkdir -p "$CAPABILITY_PAYLOAD_DIR"
}
validate_capability_payloads() {
  [[ -d "$CAPABILITY_PAYLOAD_DIR" ]] \
    || fatal "missing_capability_payload_directory"
  payload_count="$(
    find "$CAPABILITY_PAYLOAD_DIR" \
      -name '*.json' \
      | wc -l \
      | tr -d ' '
  )"
  [[ "$payload_count" -gt 0 ]] \
    || fatal "empty_capability_payload_directory"
}
# =================================================
# WORKTREE MANAGEMENT
# =================================================
cleanup_stale_worktrees() {
  git worktree prune >/dev/null 2>&1 || true
}
create_worktree() {
  local mode="$1"
  local worktree_path
  worktree_path="$WORKTREE_ROOT/$mode"
  git worktree remove \
    --force \
    "$worktree_path" \
    >/dev/null 2>&1 || true
  rm -rf "$worktree_path"
  git worktree prune >/dev/null 2>&1 || true
  git worktree add \
    --detach \
    "$worktree_path" \
    HEAD >/dev/null
  printf '%s\n' "$worktree_path"
}
destroy_worktree() {
  local worktree_path="$1"
  git worktree remove \
    --force \
    "$worktree_path" \
    >/dev/null 2>&1 || true
  rm -rf "$worktree_path"
}
# =================================================
# EXECUTION
# =================================================
execute_mode() {
  local mode="$1"
  local worktree_path="$2"
  local contract
  contract="$ROOT_DIR/.skills/$mode.md"
  log "Executing mode: $mode"
  output="$(
    AEGIS_WORKTREE_PATH="$worktree_path" \
    bash "$EXECUTOR" \
      "$contract" \
      "$mode" \
      "$ACTIVE_TASK_FILE"
  )"
  printf '%s\n' "$output"
}
# =================================================
# ARTIFACT VALIDATION
# =================================================
extract_artifact() {
  sed -n '
/AEGIS_ARTIFACT_BEGIN/,/AEGIS_ARTIFACT_END/p
'
}
validate_artifact_presence() {
  local artifact="$1"
  [[ -n "$artifact" ]] \
    || fatal "missing_artifact"
}
# =================================================
# EXECUTOR FAILURE SURFACING
# =================================================
validate_executor_output() {
  local output="$1"
  echo "$output" \
    | grep -q '\[AEGIS\]\[EXECUTOR\]\[FATAL\]' \
    && fatal "executor_failure_detected"
  echo "$output" \
    | grep -q '\[AEGIS\]\[RAW\]\[FATAL\]' \
    && fatal "raw_substrate_failure_detected"
}
# =================================================
# CONTINUITY
# =================================================
promote_runtime_state() {
  cp \
    "$ACTIVE_TASK_FILE" \
    "$LAST_GOOD_TASK_FILE"
}
# =================================================
# CLEANUP
# =================================================
cleanup_transient_state() {
  rm -rf "$CAPABILITY_ENV_DIR"
  rm -rf "$CAPABILITY_PAYLOAD_DIR"
  rm -f .aider.chat.history.md
  rm -f .aider.input.history
  rm -f .aider.tags.cache.v4
}
# =================================================
# EXECUTION FLOW
# =================================================
run_mode_lifecycle() {
  local mode="$1"
  local worktree_path
  local mode_output
  local artifact
  reset_capability_state
  worktree_path="$(
    create_worktree "$mode"
  )"
  [[ -d "$worktree_path" ]] \
    || fatal "worktree_creation_failed"
  mode_output="$(
    execute_mode \
      "$mode" \
      "$worktree_path"
  )"
  printf '%s\n' "$mode_output"
  validate_executor_output "$mode_output"
  artifact="$(
    printf '%s\n' "$mode_output" \
      | extract_artifact
  )"
  validate_artifact_presence "$artifact"
  validate_capability_payloads
  destroy_worktree "$worktree_path"
}
# =================================================
# MAIN
# =================================================
main() {
  log "Initializing runtime..."
  cleanup_stale_worktrees
  validate_runtime_topology
  initialize_runtime_state
  for mode in "${AEGIS_ANALYSIS_MODES[@]}"; do
    printf '\n'
    printf '=================================================\n'
    printf '[AEGIS] Executing: %s\n' "$mode"
    printf '=================================================\n'
    printf '\n'
    run_mode_lifecycle "$mode"
  done
  promote_runtime_state
  cleanup_transient_state
  log "Runtime execution completed"
}
# =================================================
# ENTRYPOINT
# =================================================
main