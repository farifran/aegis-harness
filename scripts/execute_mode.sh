#!/usr/bin/env bash

# =========================================================
# AEGIS HARNESS — EXECUTION PROTOCOL VM
# =========================================================
#
# Version: 2.9
# Layer: Protocol VM
# Status: Grounding Selective
#
# Responsibilities:
#
# - capability envelope resolution
# - capability environment materialization
# - capability payload persistence
# - capability manifest generation
# - grounding profile resolution
# - selective grounding payload selection
# - selected manifest materialization
# - capability invocation contracts
# - capability evidence generation
# - substrate invocation
# - protocol validation
# - artifact coercion
#
# The executor intentionally owns:
#
# - capability routing
# - payload persistence
# - grounding selection
# - capability manifest generation
# - selected manifest generation
# - capability invocation
# - protocol enforcement
# - capability evidence lifecycle
#
# The executor intentionally does NOT:
#
# - own orchestration
# - own runtime lifecycle
# - own persistence decisions
# - reason semantically
#
# =========================================================

set -Eeuo pipefail

# =========================================================
# ROOT RESOLUTION
# =========================================================

readonly AEGIS_EXECUTOR_ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
)"

cd "${AEGIS_EXECUTOR_ROOT}"

# =========================================================
# CONFIGURATION
# =========================================================

[[ -f ".harness/config.sh" ]] || {
  echo "[AEGIS][EXECUTOR][FATAL] missing_config" >&2
  exit 1
}

source ".harness/config.sh"

# =========================================================
# INPUTS
# =========================================================

readonly AEGIS_SKILL_FILE="${1:-}"
readonly AEGIS_MODE="${2:-}"
readonly AEGIS_ACTIVE_TASK_FILE_INPUT="${3:-}"

# =========================================================
# LOGGING
# =========================================================

executor_log() {
  echo "[AEGIS][EXECUTOR] $*" >&2
}

executor_warn() {
  echo "[AEGIS][EXECUTOR][WARN] $*" >&2
}

executor_fatal() {
  echo "[AEGIS][EXECUTOR][FATAL] $*" >&2
  exit 1
}

# =========================================================
# CLEANUP
# =========================================================

cleanup_executor() {

  set +e

  executor_log "Starting executor cleanup..."

  #
  # Runtime remains sovereign over:
  #
  # - worktrees
  # - payload retention
  # - capability environment retention
  # - continuity lifecycle
  #
  # Executor intentionally does NOT remove runtime-owned state.
  #

  executor_log "Executor cleanup completed"

  set -e
}

trap cleanup_executor EXIT
trap 'executor_warn "Interrupted"; exit 130' INT TERM

# =========================================================
# VALIDATION
# =========================================================

validate_executor_inputs() {

  [[ -n "${AEGIS_WORKTREE_PATH:-}" ]] \
    || executor_fatal "missing_worktree_path"

  [[ -n "${AEGIS_EXECUTION_ID:-}" ]] \
    || executor_fatal "missing_execution_id"

  [[ -n "${AEGIS_EXECUTION_TIMESTAMP:-}" ]] \
    || executor_fatal "missing_execution_timestamp"

  [[ -f "${AEGIS_SKILL_FILE}" ]] \
    || executor_fatal "missing_skill_contract"

  [[ -f "${AEGIS_ACTIVE_TASK_FILE_INPUT}" ]] \
    || executor_fatal "missing_active_task"

  declare -p AEGIS_EXECUTION_ENGINES >/dev/null 2>&1 \
    || executor_fatal "missing_execution_engine_registry"

  declare -p AEGIS_MODE_CAPABILITY_MAP >/dev/null 2>&1 \
    || executor_fatal "missing_mode_capability_map"

  declare -p AEGIS_CAPABILITY_HANDLERS >/dev/null 2>&1 \
    || executor_fatal "missing_capability_handler_registry"

  declare -p AEGIS_CAPABILITY_ARGUMENTS >/dev/null 2>&1 \
    || executor_fatal "missing_capability_argument_registry"

  declare -p AEGIS_MODE_GROUNDING_PROFILE >/dev/null 2>&1 \
    || executor_fatal "missing_grounding_profile_registry"

  [[ -n "${AEGIS_EXECUTION_ENGINES[$AEGIS_MODE]:-}" ]] \
    || executor_fatal "unknown_execution_mode"
}

# =========================================================
# EXECUTION ENGINE
# =========================================================

resolve_execution_engine() {

  export AEGIS_EXECUTION_ENGINE="$(
    printf '%s' \
      "${AEGIS_EXECUTION_ENGINES[$AEGIS_MODE]}"
  )"

  [[ -n "${AEGIS_EXECUTION_ENGINE}" ]] \
    || executor_fatal "missing_execution_engine"

  executor_log "Execution engine: ${AEGIS_EXECUTION_ENGINE}"
}

# =========================================================
# CAPABILITY ENVELOPE
# =========================================================

resolve_capability_envelope() {

  local envelope_name

  envelope_name="$(
    printf '%s' \
      "${AEGIS_MODE_CAPABILITY_MAP[$AEGIS_MODE]:-}"
  )"

  [[ -n "${envelope_name}" ]] \
    || executor_fatal "missing_capability_envelope"

  declare -n envelope_ref="${envelope_name}"

  [[ "${#envelope_ref[@]}" -gt 0 ]] \
    || executor_fatal "empty_capability_envelope"

  AEGIS_ACTIVE_CAPABILITIES=("${envelope_ref[@]}")
}

# =========================================================
# GROUNDING PROFILE
# =========================================================

resolve_grounding_profile() {

  local profile_name

  profile_name="$(
    printf '%s' \
      "${AEGIS_MODE_GROUNDING_PROFILE[$AEGIS_MODE]:-}"
  )"

  [[ -n "${profile_name}" ]] \
    || executor_fatal "missing_grounding_profile"

  declare -n grounding_ref="${profile_name}"

  [[ "${#grounding_ref[@]}" -gt 0 ]] \
    || executor_fatal "empty_grounding_profile"

  AEGIS_ACTIVE_GROUNDING_CAPABILITIES=("${grounding_ref[@]}")
}

# =========================================================
# EXECUTION STATE
# =========================================================

prepare_execution_state() {

  executor_log "Removing stale execution state..."

  rm -rf "${AEGIS_CAPABILITY_ENV_DIR}" \
    >/dev/null 2>&1 || true

  rm -rf "${AEGIS_CAPABILITY_PAYLOAD_DIR}" \
    >/dev/null 2>&1 || true

  mkdir -p "${AEGIS_CAPABILITY_ENV_DIR}"
  mkdir -p "${AEGIS_CAPABILITY_PAYLOAD_DIR}"
}

# =========================================================
# CAPABILITY ENVIRONMENT
# =========================================================

materialize_capability_environment() {

  executor_log "Materializing capability environment..."

  local capability
  local handler
  local capability_path

  for capability in "${AEGIS_ACTIVE_CAPABILITIES[@]}"; do

    handler="$(
      printf '%s' \
        "${AEGIS_CAPABILITY_HANDLERS[$capability]:-}"
    )"

    [[ -n "${handler}" ]] \
      || executor_fatal "missing_handler_for_capability"

    [[ -f "${handler}" ]] \
      || executor_fatal "missing_capability_handler_file"

    capability_path="${AEGIS_CAPABILITY_ENV_DIR}/${capability}"

    cat > "${capability_path}" <<EOF
#!/usr/bin/env bash
exec bash "${AEGIS_EXECUTOR_ROOT}/${handler}" "\$@"
EOF

    chmod +x "${capability_path}"

  done
}

# =========================================================
# CAPABILITY PAYLOADS
# =========================================================

materialize_capability_payloads() {

  executor_log "Materializing capability payloads..."

  export AEGIS_CAPABILITY_PAYLOAD_INDEX="$(
    jq -n '{}'
  )"

  local capability
  local handler
  local capability_argument
  local payload_output
  local payload_file
  local payload_path

  for capability in "${AEGIS_ACTIVE_CAPABILITIES[@]}"; do

    handler="$(
      printf '%s' \
        "${AEGIS_CAPABILITY_HANDLERS[$capability]:-}"
    )"

    [[ -f "${handler}" ]] \
      || executor_fatal "missing_capability_handler"

    capability_argument="$(
      printf '%s' \
        "${AEGIS_CAPABILITY_ARGUMENTS[$capability]:-}"
    )"

    payload_file="$(
      echo "${capability}" | tr '.' '_'
    ).json"

    payload_path="${AEGIS_CAPABILITY_PAYLOAD_DIR}/${payload_file}"

    payload_output="$(
      AEGIS_EXECUTION_ID="${AEGIS_EXECUTION_ID}" \
      AEGIS_EXECUTION_TIMESTAMP="${AEGIS_EXECUTION_TIMESTAMP}" \
      AEGIS_WORKTREE_PATH="${AEGIS_WORKTREE_PATH}" \
      bash "${handler}" "${capability_argument}"
    )"

    echo "${payload_output}" > "${payload_path}"

    jq empty "${payload_path}" \
      >/dev/null 2>&1 \
      || executor_fatal "invalid_capability_payload_json"

    AEGIS_CAPABILITY_PAYLOAD_INDEX="$(
      echo "${AEGIS_CAPABILITY_PAYLOAD_INDEX}" \
        | jq \
            --arg capability "${capability}" \
            --arg path "${payload_path}" \
            '.[$capability] = $path'
    )"

  done
}

# =========================================================
# MANIFEST GENERATION
# =========================================================

materialize_capability_manifest() {

  executor_log "Generating capability manifest..."

  export AEGIS_CAPABILITY_MANIFEST="$(
    bash scripts/capabilities/generate_manifest.sh
  )"

  [[ -n "${AEGIS_CAPABILITY_MANIFEST}" ]] \
    || executor_fatal "missing_capability_manifest"

  export AEGIS_CAPABILITY_MANIFEST_HASH="$(
    printf '%s' "${AEGIS_CAPABILITY_MANIFEST}" \
      | sha256sum \
      | awk '{print $1}'
  )"
}

# =========================================================
# GROUNDING PAYLOAD SELECTION
# =========================================================

select_grounding_payloads() {

  local capability
  local payload_file
  local payload_path

  export AEGIS_SELECTED_GROUNDING_PAYLOADS="$(
    jq -n '[]'
  )"

  for capability in "${AEGIS_ACTIVE_GROUNDING_CAPABILITIES[@]}"; do

    payload_file="$(
      echo "${capability}" | tr '.' '_'
    ).json"

    payload_path="${AEGIS_CAPABILITY_PAYLOAD_DIR}/${payload_file}"

    [[ -f "${payload_path}" ]] \
      || executor_fatal "missing_grounding_payload: ${payload_path}"

    AEGIS_SELECTED_GROUNDING_PAYLOADS="$(
      echo "${AEGIS_SELECTED_GROUNDING_PAYLOADS}" \
        | jq --arg payload "${payload_path}" '. + [$payload]'
    )"
  done

  export AEGIS_SELECTED_GROUNDING_PAYLOADS
}

# =========================================================
# SELECTED MANIFEST
# =========================================================

materialize_selected_manifest() {

  [[ -n "${AEGIS_CAPABILITY_MANIFEST:-}" ]] \
    || executor_fatal "missing_capability_manifest"

  export AEGIS_SELECTED_MANIFEST="$(
    echo "${AEGIS_CAPABILITY_MANIFEST}" \
      | jq -c \
          --arg mode "${AEGIS_MODE}" \
          '{
            schema_version: .schema_version,
            runtime_model: .runtime_model,
            generated_at: .generated_at,
            execution_id: .execution_id,
            manifest_hash: .manifest_hash,
            mode: $mode,
            execution_engine: .modes[$mode].execution_engine,
            capability_envelope: .modes[$mode].capability_envelope,
            grounding_profile: .modes[$mode].grounding_profile,
            capabilities: .modes[$mode].capabilities,
            grounding_capabilities: .modes[$mode].grounding_capabilities
          }'
  )"

  [[ -n "${AEGIS_SELECTED_MANIFEST}" ]] \
    || executor_fatal "missing_selected_manifest"
}

# =========================================================
# SUBSTRATE
# =========================================================

execute_substrate() {

  export AEGIS_MODE
  export AEGIS_SELECTED_GROUNDING_PAYLOADS
  export AEGIS_SELECTED_MANIFEST

  local substrate_output

  case "${AEGIS_EXECUTION_ENGINE}" in

    raw)
      substrate_output="$(
        bash scripts/substrates/raw_llm.sh \
          "${OPENAI_MODEL_ANALYSIS}" \
          "${AEGIS_SKILL_FILE}" \
          "${AEGIS_SELECTED_MANIFEST}" \
          "${AEGIS_CAPABILITY_PAYLOAD_DIR}"
      )"
      ;;

    aider)
      executor_fatal "mutation_substrate_not_implemented"
      ;;

    *)
      executor_fatal "unknown_execution_engine"
      ;;

  esac

  export AEGIS_SUBSTRATE_OUTPUT="${substrate_output}"
}

# =========================================================
# ARTIFACT VALIDATION
# =========================================================

validate_artifact() {

  local artifact

  artifact="$(
    echo "${AEGIS_SUBSTRATE_OUTPUT}" \
      | sed -n '/AEGIS_ARTIFACT_BEGIN/,/AEGIS_ARTIFACT_END/p' \
      | sed '1d;$d'
  )"

  [[ -n "${artifact}" ]] \
    || executor_fatal "missing_artifact_payload"

  echo "${artifact}" \
    | jq empty \
      >/dev/null 2>&1 \
      || executor_fatal "invalid_artifact_json"

  local artifact_mode

  artifact_mode="$(
    echo "${artifact}" \
      | jq -r '.mode // empty'
  )"

  [[ "${artifact_mode}" == "${AEGIS_MODE}" ]] \
    || executor_fatal "artifact_mode_mismatch"

  executor_log "Payload validated successfully"
}

# =========================================================
# OUTPUT
# =========================================================

emit_output() {
  echo "${AEGIS_SUBSTRATE_OUTPUT}"
}

# =========================================================
# MAIN
# =========================================================

main() {

  validate_executor_inputs
  resolve_execution_engine
  resolve_capability_envelope
  resolve_grounding_profile
  prepare_execution_state
  materialize_capability_environment
  materialize_capability_payloads
  materialize_capability_manifest
  select_grounding_payloads
  materialize_selected_manifest
  execute_substrate
  validate_artifact
  emit_output
}

main "$@"