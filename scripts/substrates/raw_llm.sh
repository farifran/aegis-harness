#!/usr/bin/env bash

# =========================================================
# AEGIS HARNESS — RAW COGNITION SUBSTRATE
# =========================================================
#
# Version: 2.2
# Layer: Bounded Cognition Substrate
# Status: Hardened
#
# Responsibilities:
#
# - bounded cognition execution
# - provider interaction
# - strict protocol coercion
# - JSON-only cognition output
# - capability-grounded execution
# - deterministic extraction
# - provider failure classification
# - timeout handling
# - retry handling
#
# The substrate intentionally does NOT:
#
# - own orchestration
# - own continuity
# - own persistence
# - own topology
# - inherit repository awareness
#
# =========================================================

set -Eeuo pipefail

# =========================================================
# ROOT RESOLUTION
# =========================================================

readonly AEGIS_SUBSTRATE_ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
)"

cd "${AEGIS_SUBSTRATE_ROOT}"

# =========================================================
# CONFIGURATION
# =========================================================

[[ -f ".harness/config.sh" ]] || {
  echo "[AEGIS][RAW][FATAL] missing_config" >&2
  exit 1
}

source ".harness/config.sh"

# =========================================================
# INPUTS
# =========================================================

readonly AEGIS_PROVIDER_MODEL="${1:?missing_provider_model}"

readonly AEGIS_SKILL_FILE="${2:?missing_skill_file}"

readonly AEGIS_GROUNDING_PAYLOAD="${3:?missing_grounding_payload}"

readonly AEGIS_CAPABILITY_PAYLOAD_DIR_INPUT="${4:?missing_capability_payload_dir}"

# =========================================================
# EXECUTION IDENTITY
# =========================================================

readonly AEGIS_SUBSTRATE_EXECUTION_ID="${AEGIS_EXECUTION_ID:-unknown}"

readonly AEGIS_SUBSTRATE_EXECUTION_TIMESTAMP="${AEGIS_EXECUTION_TIMESTAMP:-unknown}"

# =========================================================
# LOGGING
# =========================================================

substrate_log() {
  echo "[AEGIS][RAW] $*" >&2
}

substrate_warn() {
  echo "[AEGIS][RAW][WARN] $*" >&2
}

substrate_fatal() {
  echo "[AEGIS][RAW][FATAL] $*" >&2
  exit 1
}

# =========================================================
# TEMPFILES
# =========================================================

declare -a AEGIS_SUBSTRATE_TEMPFILES=()

register_tempfile() {

  local tempfile_path="$1"

  AEGIS_SUBSTRATE_TEMPFILES+=("${tempfile_path}")
}

# =========================================================
# CLEANUP
# =========================================================

cleanup_substrate() {

  set +e

  local tempfile_path

  for tempfile_path in "${AEGIS_SUBSTRATE_TEMPFILES[@]:-}"; do

    [[ -f "${tempfile_path}" ]] || continue

    rm -f "${tempfile_path}" \
      >/dev/null 2>&1 || true
  done

  set -e
}

trap cleanup_substrate EXIT
trap 'substrate_warn "Interrupted"; exit 130' INT TERM

# =========================================================
# VALIDATION
# =========================================================

validate_environment() {

  local required_commands=(
    jq
    curl
  )

  local command_name

  for command_name in "${required_commands[@]}"; do

    command -v "${command_name}" \
      >/dev/null 2>&1 \
      || substrate_fatal "missing_dependency: ${command_name}"

  done

  local required_provider_vars=(
    OPENAI_API_KEY
    OPENAI_API_BASE
  )

  local provider_var

  for provider_var in "${required_provider_vars[@]}"; do

    [[ -n "${!provider_var:-}" ]] \
      || substrate_fatal "missing_provider_variable: ${provider_var}"

  done

  [[ -f "${AEGIS_SKILL_FILE}" ]] \
    || substrate_fatal "missing_skill_file"

  [[ -d "${AEGIS_CAPABILITY_PAYLOAD_DIR_INPUT}" ]] \
    || substrate_fatal "missing_capability_payload_directory"

  [[ -n "${AEGIS_RAW_SUBSTRATE_TIMEOUT_SECONDS:-}" ]] \
    || substrate_fatal "missing_timeout_configuration"

  [[ -n "${AEGIS_RAW_SUBSTRATE_TEMPERATURE:-}" ]] \
    || substrate_fatal "missing_temperature_configuration"

  [[ -n "${AEGIS_PROVIDER_MAX_RETRIES:-}" ]] \
    || substrate_fatal "missing_retry_configuration"
}

validate_grounding_payload() {

  echo "${AEGIS_GROUNDING_PAYLOAD}" \
    | jq empty \
    >/dev/null 2>&1 \
    || substrate_fatal "invalid_grounding_payload"
}

# =========================================================
# SKILL CONTRACT
# =========================================================

load_skill_contract() {

  cat "${AEGIS_SKILL_FILE}"
}

# =========================================================
# CAPABILITY PAYLOAD BUNDLE
# =========================================================

load_capability_payloads() {

  local payload_bundle
  payload_bundle="$(mktemp)"

  register_tempfile "${payload_bundle}"

  echo "{" > "${payload_bundle}"

  local first_payload="true"

  while IFS= read -r payload_file; do

    [[ -f "${payload_file}" ]] || continue

    jq empty "${payload_file}" \
      >/dev/null 2>&1 \
      || substrate_fatal "invalid_capability_payload"

    local payload_key
    payload_key="$(basename "${payload_file}" .json)"

    if [[ "${first_payload}" == "false" ]]; then
      echo "," >> "${payload_bundle}"
    fi

    first_payload="false"

    echo "\"${payload_key}\":" >> "${payload_bundle}"

    cat "${payload_file}" >> "${payload_bundle}"

  done < <(
    find "${AEGIS_CAPABILITY_PAYLOAD_DIR_INPUT}" \
      -type f \
      -name "*.json" \
      | sort
  )

  echo "}" >> "${payload_bundle}"

  jq empty "${payload_bundle}" \
    >/dev/null 2>&1 \
    || substrate_fatal "invalid_payload_bundle"

  cat "${payload_bundle}"
}

# =========================================================
# PROMPT CONSTRUCTION
# =========================================================

build_provider_prompt() {

  local skill_contract
  skill_contract="$(load_skill_contract)"

  local capability_payloads
  capability_payloads="$(load_capability_payloads)"

  local prompt_file
  prompt_file="$(mktemp)"

  register_tempfile "${prompt_file}"

  cat > "${prompt_file}" <<EOF
You are operating as a bounded cognition substrate inside Aegis Harness.

Execution constraints:
- protocol-oriented
- non-conversational
- capability-grounded
- JSON-only output
- bounded cognition
- deterministic execution

You MUST:
- emit ONLY valid JSON
- emit EXACTLY one JSON object
- avoid markdown
- avoid explanations
- avoid prose outside JSON
- avoid conversational behavior

You do NOT possess:
- repository sovereignty
- implicit repository awareness
- hidden memory
- orchestration authority
- continuity ownership

Execution identity:
- execution_id: ${AEGIS_SUBSTRATE_EXECUTION_ID}
- execution_timestamp: ${AEGIS_SUBSTRATE_EXECUTION_TIMESTAMP}

Grounding payload:
${AEGIS_GROUNDING_PAYLOAD}

Capability payloads:
${capability_payloads}

Skill contract:
${skill_contract}

Return ONLY one valid JSON object.
EOF

  cat "${prompt_file}"
}

# =========================================================
# PROVIDER REQUEST
# =========================================================

execute_provider_request() {

  local provider_prompt="$1"

  local request_body
  request_body="$(mktemp)"

  register_tempfile "${request_body}"

  jq -n \
    --arg model "${AEGIS_PROVIDER_MODEL}" \
    --arg content "${provider_prompt}" \
    --argjson temperature "${AEGIS_RAW_SUBSTRATE_TEMPERATURE}" \
    '{
      model: $model,
      temperature: $temperature,
      messages: [
        {
          role: "user",
          content: $content
        }
      ]
    }' \
    > "${request_body}"

  local provider_response
  provider_response="$(mktemp)"

  register_tempfile "${provider_response}"

  local retry_count=0

  while true; do

    local http_status

    http_status="$(
      curl \
        --silent \
        --show-error \
        --connect-timeout "${AEGIS_PROVIDER_CONNECT_TIMEOUT}" \
        --max-time "${AEGIS_PROVIDER_RESPONSE_TIMEOUT}" \
        -o "${provider_response}" \
        -w "%{http_code}" \
        -X POST \
        "${OPENAI_API_BASE}/chat/completions" \
        -H "Authorization: Bearer ${OPENAI_API_KEY}" \
        -H "Content-Type: application/json" \
        -d @"${request_body}"
    )"

    [[ "${http_status}" == "200" ]] && break

    case "${http_status}" in

      "401")
        cat "${provider_response}" >&2
        substrate_fatal "provider_authentication_failure"
        ;;

      "429")
        substrate_warn "provider_rate_limited"
        ;;

      "500"|"502"|"503"|"504")
        substrate_warn "provider_transient_failure"
        ;;

      *)
        cat "${provider_response}" >&2
        substrate_fatal "provider_http_failure"
        ;;
    esac

    retry_count=$((retry_count + 1))

    [[ "${retry_count}" -lt "${AEGIS_PROVIDER_MAX_RETRIES}" ]] \
      || substrate_fatal "provider_retry_limit_exceeded"

    sleep "${AEGIS_PROVIDER_RETRY_DELAY}"
  done

  jq empty "${provider_response}" \
    >/dev/null 2>&1 \
    || substrate_fatal "provider_response_not_json"

  cat "${provider_response}"
}

# =========================================================
# ARTIFACT EXTRACTION
# =========================================================

extract_json_object() {

  local raw_content="$1"

  local normalized_content

  normalized_content="$(
    echo "${raw_content}" \
      | tr -d '\r'
  )"

  #
  # Attempt direct JSON parse first.
  #

  if echo "${normalized_content}" | jq empty >/dev/null 2>&1; then
    echo "${normalized_content}"
    return
  fi

  #
  # Extract first JSON object heuristically.
  #

  local extracted_json

  extracted_json="$(
    echo "${normalized_content}" \
      | grep -o '{.*}' \
      | head -n 1
  )"

  [[ -n "${extracted_json}" ]] \
    || substrate_fatal "json_payload_extraction_failure"

  echo "${extracted_json}" \
    | jq empty \
    >/dev/null 2>&1 \
    || substrate_fatal "invalid_extracted_json"

  echo "${extracted_json}"
}

extract_artifact_json() {

  local provider_response="$1"

  local extracted_content

  extracted_content="$(
    echo "${provider_response}" \
      | jq -r '.choices[0].message.content // empty'
  )"

  [[ -n "${extracted_content}" ]] \
    || substrate_fatal "empty_provider_content"

  extract_json_object "${extracted_content}"
}

# =========================================================
# ARTIFACT VALIDATION
# =========================================================

validate_artifact() {

  local artifact="$1"

  echo "${artifact}" \
    | jq empty \
    >/dev/null 2>&1 \
    || substrate_fatal "invalid_artifact"

  local mode_field

  mode_field="$(
    echo "${artifact}" \
      | jq -r '.mode // empty'
  )"

  [[ -n "${mode_field}" ]] \
    || substrate_fatal "missing_mode_field"

  local execution_id_field

  execution_id_field="$(
    echo "${artifact}" \
      | jq -r '.execution_id // empty'
  )"

  [[ -n "${execution_id_field}" ]] \
    || substrate_fatal "missing_execution_id"

  [[ "${execution_id_field}" == "${AEGIS_SUBSTRATE_EXECUTION_ID}" ]] \
    || substrate_fatal "execution_identity_mismatch"
}

# =========================================================
# EXECUTION
# =========================================================

execute_cognition() {

  substrate_log "Executing raw cognition substrate..."

  local provider_prompt
  provider_prompt="$(build_provider_prompt)"

  local provider_response
  provider_response="$(
    execute_provider_request "${provider_prompt}"
  )"

  local artifact
  artifact="$(
    extract_artifact_json "${provider_response}"
  )"

  validate_artifact "${artifact}"

  echo "${artifact}"
}

# =========================================================
# MAIN
# =========================================================

main() {

  validate_environment

  validate_grounding_payload

  execute_cognition
}

main "$@"