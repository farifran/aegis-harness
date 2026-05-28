#!/usr/bin/env bash

# =================================================
# AEGIS HARNESS — RAW COGNITION SUBSTRATE
# =================================================
#
# Purpose:
# - bounded readonly cognition
# - deterministic provider interaction
# - strict JSON payload generation
# - protocol-safe execution
#
# This substrate intentionally:
# - does NOT own orchestration
# - does NOT own continuity
# - does NOT own persistence
# - does NOT own grounding
#
# Runtime owns:
# - capability exposure
# - capability payload injection
# - orchestration
# - continuity
# - protocol framing
#
# =================================================

set -Eeuo pipefail

# =================================================
# INPUTS
# =================================================

MODEL="${1:-}"

BOOTSTRAP="${2:-}"

CONTRACT="${3:-}"

GROUNDING="${4:-}"

# =================================================
# HELPERS
# =================================================

log() {
  printf '[AEGIS][RAW] %s\n' "$1" >&2
}

fatal() {
  printf '[AEGIS][RAW][FATAL] %s\n' "$1" >&2
  exit 1
}

# =================================================
# VALIDATION
# =================================================

[[ -n "$MODEL" ]] \
  || fatal "missing_model"

[[ -n "${OPENAI_API_KEY:-}" ]] \
  || fatal "missing_openai_api_key"

[[ -n "${OPENAI_API_BASE:-}" ]] \
  || fatal "missing_openai_api_base"

command -v jq >/dev/null 2>&1 \
  || fatal "missing_jq"

command -v curl >/dev/null 2>&1 \
  || fatal "missing_curl"

# =================================================
# PROVIDER PAYLOAD
# =================================================

build_request_payload() {

cat <<EOF
{
  "model": "$MODEL",
  "messages": [
    {
      "role": "system",
      "content": $(jq -Rs . <<< "$BOOTSTRAP")
    },
    {
      "role": "user",
      "content": $(jq -Rs . <<< "$CONTRACT")
    },
    {
      "role": "user",
      "content": $(jq -Rs . <<< "$GROUNDING")
    }
  ],
  "temperature": 0,
  "top_p": 1,
  "max_tokens": 4096,
  "response_format": {
    "type": "json_object"
  }
}
EOF
}

# =================================================
# PROVIDER EXECUTION
# =================================================

execute_provider_request() {

  local payload

  payload="$(build_request_payload)"

  curl -sS \
    --fail-with-body \
    --max-time 120 \
    -X POST \
    "$OPENAI_API_BASE/chat/completions" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$payload"
}

# =================================================
# RESPONSE VALIDATION
# =================================================

validate_provider_response() {

  local response="$1"

  echo "$response" \
    | jq empty >/dev/null 2>&1 \
    || fatal "provider_response_not_json"
}

validate_provider_error() {

  local response="$1"

  if echo "$response" | jq -e '.error' >/dev/null 2>&1; then

    echo "$response" | jq '.error' >&2

    fatal "provider_returned_error"
  fi
}

# =================================================
# CONTENT EXTRACTION
# =================================================

extract_message_content() {

  jq -er '
    .choices[0].message.content
  '
}

validate_message_content() {

  local content="$1"

  [[ -n "$content" ]] \
    || fatal "empty_message_content"
}

# =================================================
# FINAL PAYLOAD VALIDATION
# =================================================

validate_final_payload() {

  local payload="$1"

  echo "$payload" \
    | jq empty >/dev/null 2>&1 \
    || fatal "final_payload_not_json"
}

# =================================================
# MAIN
# =================================================

main() {

  log "Executing raw cognition substrate..."

  provider_response="$(
    execute_provider_request
  )" || fatal "provider_request_failed"

  validate_provider_response "$provider_response"

  validate_provider_error "$provider_response"

  message_content="$(
    printf '%s' "$provider_response" \
      | extract_message_content
  )" || fatal "message_content_extraction_failure"

  validate_message_content "$message_content"

  validate_final_payload "$message_content"

  printf '%s\n' "$message_content"
}

# =================================================
# ENTRYPOINT
# =================================================

main