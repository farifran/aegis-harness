#!/usr/bin/env bash

# =========================================================
# AEGIS HARNESS — EXECUTION PROTOCOL VM
# =========================================================
#
# Version: 2.2
# Layer: Protocol Execution VM
# Status: Hardened
#
# Responsibilities:
#
# - protocol enforcement
# - capability envelope resolution
# - capability environment materialization
# - capability payload generation
# - payload freshness guarantees
# - grounding payload construction
# - substrate routing
# - artifact validation
# - deterministic cleanup
#
# The executor intentionally does NOT:
#
# - own orchestration
# - own runtime sovereignty
# - own persistence
# - infer architecture
# - inherit repository awareness
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

readonly AEGIS_SKILL_FILE="${1:?missing_skill_file}"

readonly AEGIS_MODE="${2:?missing_mode}"

readonly AEGIS_ACTIVE_TASK_FILE_INPUT="${3:?missing_active_task}"

# =========================================================
# EXECUTION IDENTITY
# =========================================================

readonly AEGIS_EXECUTION_ID="${AEGIS_EXECUTION_ID:-unknown}"

readonly AEGIS_EXECUTION_TIMESTAMP="${AEGIS_EXECUTION_TIMESTAMP:-unknown}"

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
# EXECUTION ENGINE
# =========================================================

readonly AEGIS_EXECUTION_ENGINE="${AEGIS_EXECUTION_ENGINES[$AEGIS_MODE]:-}"

readonly AEGIS_SUBSTRATE_SCRIPT="scripts/substrates/${AEGIS_EXECUTION_ENGINE}_llm.sh"

# =========================================================
# PATHS
# =========================================================

readonly AEGIS_CAPABILITY_ENV_PATH="${AEGIS_CAPABILITY_ENV_DIR}"

readonly AEGIS_CAPABILITY_PAYLOAD_PATH="${AEGIS_CAPABILITY_PAYLOAD_DIR}"

# =========================================================
# TEMPFILES
# =========================================================

declare -a AEGIS_EXECUTOR_TEMPFILES=()

register_tempfile() {

  local tempfile_path="$1"

  AEGIS_EXECUTOR_TEMPFILES+=("${tempfile_path}")
}

# =========================================================
# CLEANUP
# =========================================================

cleanup_executor() {

  set +e

  executor_log "Starting executor cleanup..."

  local tempfile_path

  for tempfile_path in "${AEGIS_EXECUTOR_TEMPFILES[@]:-}"; do

    [[ -f "${tempfile_path}" ]] || continue

    rm -f "${tempfile_path}" \
      >/dev/null 2>&1 || true
  done

  executor_log "Executor cleanup completed"

  set -e
}

trap cleanup_executor EXIT
trap 'executor_warn "Interrupted"; exit 130' INT TERM

# =========================================================
# VALIDATION
# =========================================================

validate_inputs() {

  [[ -f "${AEGIS_SKILL_FILE}" ]] \
    || executor_fatal "missing_skill_file"

  [[ -n "${AEGIS_MODE}" ]] \
    || executor_fatal "missing_mode"

  declare -p AEGIS_WORKTREE_PATH \
    >/dev/null 2>&1 \
    || executor_fatal "missing_worktree_path"

  [[ -d "${AEGIS_WORKTREE_PATH}" ]] \
    || executor_fatal "invalid_worktree_surface"

  [[ -f "${AEGIS_ACTIVE_TASK_FILE_INPUT}" ]] \
    || touch "${AEGIS_ACTIVE_TASK_FILE_INPUT}"
}

validate_execution_engine() {

  [[ -n "${AEGIS_EXECUTION_ENGINE}" ]] \
    || executor_fatal "unknown_execution_engine"
}

validate_substrate() {

  [[ -f "${AEGIS_SUBSTRATE_SCRIPT}" ]] \
    || executor_fatal "missing_substrate"
}

# =========================================================
# CAPABILITY ENVELOPE
# =========================================================

resolve_capability_envelope() {

  local envelope_name

  envelope_name="${AEGIS_MODE_CAPABILITY_MAP[$AEGIS_MODE]:-}"

  [[ -n "${envelope_name}" ]] \
    || executor_fatal "missing_capability_envelope"

  declare -n RESOLVED_CAPABILITIES="${envelope_name}"

  [[ "${#RESOLVED_CAPABILITIES[@]}" -gt 0 ]] \
    || executor_fatal "empty_capability_envelope"
}

# =========================================================
# CLEAN STALE STATE
# =========================================================

remove_stale_execution_state() {

  executor_log "Removing stale execution state..."

  rm -rf "${AEGIS_CAPABILITY_ENV_PATH}" \
    >/dev/null 2>&1 || true

  rm -rf "${AEGIS_CAPABILITY_PAYLOAD_PATH}" \
    >/dev/null 2>&1 || true
}

# =========================================================
# CAPABILITY ENVIRONMENT
# =========================================================

materialize_capability_environment() {

  executor_log "Materializing capability environment..."

  mkdir -p "${AEGIS_CAPABILITY_ENV_PATH}"

  local capability

  for capability in "${RESOLVED_CAPABILITIES[@]}"; do

    local handler
    handler="${AEGIS_CAPABILITY_HANDLERS[$capability]:-}"

    [[ -n "${handler}" ]] \
      || executor_fatal "missing_handler_for_capability: ${capability}"

    [[ -f "${handler}" ]] \
      || executor_fatal "missing_handler_file: ${handler}"

    local capability_surface
    capability_surface="${AEGIS_CAPABILITY_ENV_PATH}/${capability}"

    cat > "${capability_surface}" <<EOF
#!/usr/bin/env bash
bash "${AEGIS_EXECUTOR_ROOT}/${handler}" "\$@"
EOF

    chmod +x "${capability_surface}"
  done
}

# =========================================================
# PAYLOAD METADATA
# =========================================================

wrap_payload_metadata() {

  local capability="$1"

  local raw_payload_file="$2"

  local wrapped_payload_file="$3"

  jq -n \
    --arg execution_id "${AEGIS_EXECUTION_ID}" \
    --arg generated_at "${AEGIS_EXECUTION_TIMESTAMP}" \
    --arg mode "${AEGIS_MODE}" \
    --arg capability "${capability}" \
    --slurpfile payload "${raw_payload_file}" \
    '{
      execution_id: $execution_id,
      generated_at: $generated_at,
      mode: $mode,
      capability: $capability,
      payload: $payload[0]
    }' \
    > "${wrapped_payload_file}"
}

# =========================================================
# CAPABILITY PAYLOADS
# =========================================================

generate_capability_payload() {

  local capability="$1"

  local capability_surface="$2"

  local payload_file="$3"

  local raw_payload_file
  raw_payload_file="$(mktemp)"

  register_tempfile "${raw_payload_file}"

  case "${capability}" in

    "filesystem.list_tree")

      bash "${capability_surface}" "." \
        > "${raw_payload_file}"

      ;;

    "filesystem.read")

      bash "${capability_surface}" "AGENTS.md" \
        > "${raw_payload_file}"

      ;;

    "filesystem.search_symbol")

      bash "${capability_surface}" \
        "${AEGIS_DISCOVERY_SYMBOL_QUERY}" \
        > "${raw_payload_file}"

      ;;

    "topology.read_graph")

      bash "${capability_surface}" \
        > "${raw_payload_file}"

      ;;

    "runtime.read_active_task")

      bash "${capability_surface}" \
        "${AEGIS_ACTIVE_TASK_FILE_INPUT}" \
        > "${raw_payload_file}"

      ;;

    "git.diff")

      bash "${capability_surface}" \
        > "${raw_payload_file}"

      ;;

    "git.status")

      bash "${capability_surface}" \
        > "${raw_payload_file}"

      ;;

    *)

      executor_fatal "unsupported_capability_payload_generation: ${capability}"

      ;;
  esac

  jq empty "${raw_payload_file}" \
    >/dev/null 2>&1 \
    || executor_fatal "invalid_raw_capability_payload"

  wrap_payload_metadata \
    "${capability}" \
    "${raw_payload_file}" \
    "${payload_file}"
}

materialize_capability_payloads() {

  executor_log "Materializing capability payloads..."

  mkdir -p "${AEGIS_CAPABILITY_PAYLOAD_PATH}"

  local capability

  for capability in "${RESOLVED_CAPABILITIES[@]}"; do

    executor_log "Executing capability: ${capability}"

    local capability_surface
    capability_surface="${AEGIS_CAPABILITY_ENV_PATH}/${capability}"

    [[ -f "${capability_surface}" ]] \
      || executor_fatal "missing_capability_surface"

    local payload_file
    payload_file="${AEGIS_CAPABILITY_PAYLOAD_PATH}/$(echo "${capability}" | tr '.' '_').json"

    generate_capability_payload \
      "${capability}" \
      "${capability_surface}" \
      "${payload_file}"

    [[ -f "${payload_file}" ]] \
      || executor_fatal "missing_payload_output"

    jq empty "${payload_file}" \
      >/dev/null 2>&1 \
      || executor_fatal "invalid_capability_payload"

    local payload_execution_id

    payload_execution_id="$(
      jq -r '.execution_id // empty' "${payload_file}"
    )"

    [[ "${payload_execution_id}" == "${AEGIS_EXECUTION_ID}" ]] \
      || executor_fatal "stale_payload_detected"
  done
}

# =========================================================
# MANIFEST HASH
# =========================================================

compute_manifest_hash() {

  local manifest_hash

  manifest_hash="$(
    bash scripts/capabilities/generate_manifest.sh \
      | sha256sum \
      | awk '{print $1}'
  )"

  [[ -n "${manifest_hash}" ]] \
    || executor_fatal "manifest_hash_failure"

  echo "${manifest_hash}"
}

# =========================================================
# GROUNDING PAYLOAD
# =========================================================

build_grounding_payload() {

  local grounding_file
  grounding_file="$(mktemp)"

  register_tempfile "${grounding_file}"

  local manifest_hash
  manifest_hash="$(compute_manifest_hash)"

  jq -n \
    --arg execution_id "${AEGIS_EXECUTION_ID}" \
    --arg runtime_timestamp "${AEGIS_EXECUTION_TIMESTAMP}" \
    --arg manifest_hash "${manifest_hash}" \
    --arg mode "${AEGIS_MODE}" \
    --arg skill_file "${AEGIS_SKILL_FILE}" \
    --arg worktree "${AEGIS_WORKTREE_PATH}" \
    --arg payload_dir "${AEGIS_CAPABILITY_PAYLOAD_PATH}" \
    '{
      execution_id: $execution_id,
      runtime_timestamp: $runtime_timestamp,
      capability_manifest_hash: $manifest_hash,
      mode: $mode,
      skill_file: $skill_file,
      worktree_path: $worktree,
      capability_payload_directory: $payload_dir
    }' \
    > "${grounding_file}"

  jq empty "${grounding_file}" \
    >/dev/null 2>&1 \
    || executor_fatal "invalid_grounding_payload"

  cat "${grounding_file}"
}

# =========================================================
# ARTIFACT VALIDATION
# =========================================================

validate_artifact() {

  local artifact="$1"

  echo "${artifact}" \
    | jq empty \
    >/dev/null 2>&1 \
    || executor_fatal "invalid_artifact_json"

  local required_fields=(
    mode
    execution_id
  )

  local field_name

  for field_name in "${required_fields[@]}"; do

    local field_value

    field_value="$(
      echo "${artifact}" \
        | jq -r ".${field_name} // empty"
    )"

    [[ -n "${field_value}" ]] \
      || executor_fatal "missing_artifact_field: ${field_name}"

  done

  local mode_identity

  mode_identity="$(
    echo "${artifact}" \
      | jq -r '.mode // empty'
  )"

  [[ "${mode_identity}" == "${AEGIS_MODE}" ]] \
    || executor_fatal "artifact_mode_mismatch"

  local execution_identity

  execution_identity="$(
    echo "${artifact}" \
      | jq -r '.execution_id // empty'
  )"

  [[ "${execution_identity}" == "${AEGIS_EXECUTION_ID}" ]] \
    || executor_fatal "artifact_execution_identity_mismatch"
}

# =========================================================
# EXECUTION
# =========================================================

execute_substrate() {

  executor_log "Execution engine: ${AEGIS_EXECUTION_ENGINE}"

  local grounding_payload
  grounding_payload="$(build_grounding_payload)"

  local artifact_output

  case "${AEGIS_EXECUTION_ENGINE}" in

    "raw")

      artifact_output="$(
        bash "${AEGIS_SUBSTRATE_SCRIPT}" \
          "${OPENAI_MODEL_ANALYSIS}" \
          "${AEGIS_SKILL_FILE}" \
          "${grounding_payload}" \
          "${AEGIS_CAPABILITY_PAYLOAD_PATH}"
      )"

      ;;

    "aider")

      executor_fatal "mutation_substrate_not_yet_hardened"

      ;;

    *)

      executor_fatal "unsupported_execution_engine"

      ;;
  esac

  validate_artifact "${artifact_output}"

  executor_log "Payload validated successfully"

  echo "${AEGIS_ARTIFACT_BEGIN_MARKER}"
  echo "${artifact_output}"
  echo "${AEGIS_ARTIFACT_END_MARKER}"
}

# =========================================================
# MAIN
# =========================================================

main() {

  validate_inputs

  validate_execution_engine

  validate_substrate

  resolve_capability_envelope

  remove_stale_execution_state

  materialize_capability_environment

  materialize_capability_payloads

  execute_substrate
}

main "$@"