#!/usr/bin/env bash

# =================================================
# AEGIS HARNESS — EXECUTION PROTOCOL VM
# =================================================
#
# Purpose:
# - protocol-oriented execution
# - substrate routing
# - capability environment injection
# - capability payload grounding
# - deterministic payload validation
#
# Runtime owns:
# - orchestration
# - continuity
# - persistence
# - capability exposure
#
# Executor owns:
# - protocol enforcement
# - substrate routing
# - capability payload injection
# - payload validation
#
# =================================================

set -Eeuo pipefail

# =================================================
# INPUTS
# =================================================

MODE_CONTRACT="${1:-}"

MODE_NAME="${2:-}"

ACTIVE_TASK_PATH="${3:-}"

# =================================================
# ROOT RESOLUTION
# =================================================

ROOT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.." \
  && pwd
)"

CONFIG_FILE="$ROOT_DIR/.harness/config.sh"

RAW_SUBSTRATE="$ROOT_DIR/scripts/substrates/raw_llm.sh"

CAPABILITY_ENV_DIR="$ROOT_DIR/.harness/runtime/capability_env"

CAPABILITY_PAYLOAD_DIR="$ROOT_DIR/.harness/runtime/capability_payloads"

WORKTREE_PATH="${AEGIS_WORKTREE_PATH:-$ROOT_DIR}"

# =================================================
# HELPERS
# =================================================

log() {
  printf '[AEGIS][EXECUTOR] %s\n' "$1" >&2
}

fatal() {
  printf '[AEGIS][EXECUTOR][FATAL] %s\n' "$1" >&2
  exit 1
}

# =================================================
# VALIDATION
# =================================================

[[ -n "$MODE_CONTRACT" ]] \
  || fatal "missing_mode_contract"

[[ -n "$MODE_NAME" ]] \
  || fatal "missing_mode_name"

[[ -f "$MODE_CONTRACT" ]] \
  || fatal "mode_contract_not_found"

[[ -f "$CONFIG_FILE" ]] \
  || fatal "config_not_found"

source "$CONFIG_FILE"

# =================================================
# MODE TOPOLOGY
# =================================================

ENGINE_VAR="AEGIS_MODE_EXECUTION_ENGINE_${MODE_NAME}"

EXECUTION_ENGINE="${!ENGINE_VAR:-}"

[[ -n "$EXECUTION_ENGINE" ]] \
  || fatal "missing_execution_engine"

CAPABILITY_ARRAY_NAME="AEGIS_MODE_CAPABILITIES_${MODE_NAME}"

declare -n MODE_CAPABILITIES="$CAPABILITY_ARRAY_NAME"

[[ -v MODE_CAPABILITIES ]] \
  || fatal "missing_capability_envelope"

[[ "${#MODE_CAPABILITIES[@]}" -gt 0 ]] \
  || fatal "empty_capability_envelope"

# =================================================
# CAPABILITY ENVIRONMENT
# =================================================

materialize_capability_environment() {

  rm -rf "$CAPABILITY_ENV_DIR"

  mkdir -p "$CAPABILITY_ENV_DIR"

  for capability in "${MODE_CAPABILITIES[@]}"; do

    [[ -n "$capability" ]] \
      || fatal "empty_capability_name"

    normalized="$(
      printf '%s' "$capability" \
        | tr '.' '_'
    )"

    handler_var="AEGIS_CAPABILITY_HANDLER_${normalized^^}"

    handler="${!handler_var:-}"

    [[ -n "$handler" ]] \
      || fatal "missing_handler_for_capability: $capability"

    target="$ROOT_DIR/$handler"

    [[ -f "$target" ]] \
      || fatal "capability_handler_not_found: $target"

    chmod +x "$target"

    ln -sf \
      "$target" \
      "$CAPABILITY_ENV_DIR/$capability"

  done
}

# =================================================
# CAPABILITY PAYLOADS
# =================================================

reset_capability_payloads() {

  rm -rf "$CAPABILITY_PAYLOAD_DIR"

  mkdir -p "$CAPABILITY_PAYLOAD_DIR"
}

execute_capability() {

  local capability="$1"

  local capability_path

  capability_path="$CAPABILITY_ENV_DIR/$capability"

  [[ -f "$capability_path" ]] \
    || fatal "capability_not_materialized: $capability"

  case "$capability" in

    filesystem.list_tree)

      (
        cd "$WORKTREE_PATH"
        bash "$capability_path"
      )
      ;;

    filesystem.read)

      (
        cd "$WORKTREE_PATH"
        bash "$capability_path" "AGENTS.md"
      )
      ;;

    filesystem.search_symbol)

      case "$MODE_NAME" in

        discovery)

          (
            cd "$WORKTREE_PATH"

            bash "$capability_path" \
              "$AEGIS_DISCOVERY_SYMBOL_QUERY"
          )
          ;;

        forensics)

          (
            cd "$WORKTREE_PATH"

            bash "$capability_path" \
              "$AEGIS_FORENSICS_SYMBOL_QUERY"
          )
          ;;

        validation)

          (
            cd "$WORKTREE_PATH"

            bash "$capability_path" \
              "$AEGIS_VALIDATION_SYMBOL_QUERY"
          )
          ;;

        adversarial)

          (
            cd "$WORKTREE_PATH"

            bash "$capability_path" \
              "$AEGIS_ADVERSARIAL_SYMBOL_QUERY"
          )
          ;;

        *)

          (
            cd "$WORKTREE_PATH"

            bash "$capability_path" \
              "$AEGIS_DISCOVERY_SYMBOL_QUERY"
          )
          ;;

      esac
      ;;

    git.status)

      (
        cd "$WORKTREE_PATH"
        bash "$capability_path"
      )
      ;;

    git.diff)

      (
        cd "$WORKTREE_PATH"
        bash "$capability_path"
      )
      ;;

    topology.read_graph)

      (
        cd "$ROOT_DIR"
        bash "$capability_path"
      )
      ;;

    runtime.read_active_task)

      (
        cd "$ROOT_DIR"
        bash "$capability_path"
      )
      ;;

    *)

      (
        cd "$WORKTREE_PATH"
        bash "$capability_path"
      )
      ;;

  esac
}

materialize_capability_payloads() {

  reset_capability_payloads

  for capability in "${MODE_CAPABILITIES[@]}"; do

    log "Executing capability: $capability"

    payload="$(
      execute_capability "$capability"
    )" || fatal "capability_execution_failure: $capability"

    echo "$payload" | jq empty >/dev/null 2>&1 \
      || fatal "invalid_capability_payload: $capability"

    payload_file="$(
      printf '%s' "$capability" \
        | tr '.' '_'
    ).json"

    printf '%s\n' "$payload" \
      > "$CAPABILITY_PAYLOAD_DIR/$payload_file"

  done
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
    || fatal "empty_capability_payloads"
}

# =================================================
# CAPABILITY GROUNDING
# =================================================

build_capability_grounding() {

  for payload in "$CAPABILITY_PAYLOAD_DIR"/*.json; do

    [[ -f "$payload" ]] || continue

    printf '=== CAPABILITY PAYLOAD ===\n'
    printf 'FILE: %s\n\n' "$payload"

    cat "$payload"

    printf '\n\n'

  done
}

# =================================================
# CONTINUITY
# =================================================

load_active_task() {

  if [[ -f "$ACTIVE_TASK_PATH" ]]; then
    cat "$ACTIVE_TASK_PATH"
  fi
}

# =================================================
# EXECUTION BOOTSTRAP
# =================================================

build_execution_bootstrap() {

cat <<EOF
You are executing inside the Aegis Harness runtime.

Execution mode:
$MODE_NAME

Execution substrate:
$EXECUTION_ENGINE

Rules:
- emit exactly one JSON object
- emit no prose outside JSON
- emit no markdown
- emit no acknowledgements
- consume only runtime-provided evidence
- avoid implicit repository assumptions
- avoid speculative fabrication
- do not self-authorize capabilities
EOF
}

# =================================================
# RAW SUBSTRATE
# =================================================

run_raw_substrate() {

  [[ -f "$RAW_SUBSTRATE" ]] \
    || fatal "raw_substrate_not_found"

  local bootstrap
  local contract
  local continuity
  local grounding

  bootstrap="$(build_execution_bootstrap)"

  contract="$(cat "$MODE_CONTRACT")"

  continuity="$(load_active_task || true)"

  grounding="$(build_capability_grounding)"

  bash "$RAW_SUBSTRATE" \
    "$AEGIS_MODEL" \
    "$bootstrap" \
    "$contract" \
    "$continuity

$grounding"
}

# =================================================
# AIDER SUBSTRATE
# =================================================

run_aider_substrate() {

  local bootstrap
  local contract
  local continuity
  local grounding

  bootstrap="$(build_execution_bootstrap)"

  contract="$(cat "$MODE_CONTRACT")"

  continuity="$(load_active_task || true)"

  grounding="$(build_capability_grounding)"

  (
    cd "$WORKTREE_PATH"

    aider \
      --model "$AEGIS_MODEL" \
      --edit-format "$AEGIS_EDIT_FORMAT" \
      --message "
$bootstrap

$contract

$continuity

$grounding
"
  )
}

# =================================================
# SUBSTRATE ROUTING
# =================================================

execute_substrate() {

  case "$EXECUTION_ENGINE" in

    raw)
      run_raw_substrate
      ;;

    aider)
      run_aider_substrate
      ;;

    *)
      fatal "unknown_execution_engine: $EXECUTION_ENGINE"
      ;;

  esac
}

# =================================================
# JSON VALIDATION
# =================================================

validate_json_payload() {

  local payload="$1"

  echo "$payload" | jq empty >/dev/null 2>&1 \
    || fatal "invalid_json_payload"

  local mode

  mode="$(
    echo "$payload" \
      | jq -r '.mode // empty'
  )"

  [[ "$mode" == "$MODE_NAME" ]] \
    || fatal "mode_identity_mismatch"
}

# =================================================
# MAIN
# =================================================

main() {

  log "Materializing capability environment..."

  materialize_capability_environment

  log "Materializing capability payloads..."

  materialize_capability_payloads

  validate_capability_payloads

  log "Execution engine: $EXECUTION_ENGINE"

  payload="$(
    execute_substrate
  )" || fatal "substrate_execution_failure"

  [[ -n "$payload" ]] \
    || fatal "empty_substrate_output"

  validate_json_payload "$payload"

  log "Payload validated successfully"

  if [[ "$AEGIS_PROTOCOL_RUNTIME_OWNS_FRAMING" == "true" ]]; then

    printf 'AEGIS_ARTIFACT_BEGIN\n'
    printf '%s\n' "$payload"
    printf 'AEGIS_ARTIFACT_END\n'

  else

    printf '%s\n' "$payload"

  fi
}

# =================================================
# ENTRYPOINT
# =================================================

main