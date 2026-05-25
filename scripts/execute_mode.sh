#!/usr/bin/env bash

set -euo pipefail

# =========================================================
# EXECUTE MODE
# =========================================================

MODE_FILE="${1:?missing mode file}"
EXPECTED_MODE="${2:?missing mode name}"
ACTIVE_TASK_PATH="${3:?missing active task path}"
EDITABLE_SURFACES="${4:-}"

ROOT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
)"

MODE_PATH="$ROOT_DIR/$MODE_FILE"
AGENTS_FILE="$ROOT_DIR/AGENTS.md"
ARCH_GRAPH_FILE="$ROOT_DIR/.harness/architecture_graph.json"

EXECUTION_TIMEOUT=300

# =========================================================
# FAILURE
# =========================================================

fail() {
  echo
  echo "[AEGIS] $1" >&2
  echo
  exit 1
}

# =========================================================
# DEBUG OUTPUT
# =========================================================

debug_output() {

  local title="$1"

  echo
  echo "================================================="
  echo "[AEGIS DEBUG] $title"
  echo "================================================="
  echo
  echo "$OUTPUT"
  echo
  echo "================================================="
  echo
}

# =========================================================
# VALIDATION
# =========================================================

[[ -f "$MODE_PATH" ]] \
  || fail "Mode file not found."

[[ -f "$ACTIVE_TASK_PATH" ]] \
  || fail "Missing runtime active task."

[[ -f "$AGENTS_FILE" ]] \
  || fail "Missing AGENTS.md."

[[ -f "$ARCH_GRAPH_FILE" ]] \
  || fail "Missing architecture_graph.json."

# =========================================================
# MODE CAPABILITY MODEL
# =========================================================

is_mutation_mode() {

  case "$EXPECTED_MODE" in
    repair|optimize)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# =========================================================
# ENVIRONMENT VALIDATION
# =========================================================

[[ -n "${OPENAI_API_KEY:-}" ]] \
  || fail "Missing OPENAI_API_KEY."

[[ -n "${OPENAI_API_BASE:-}" ]] \
  || fail "Missing OPENAI_API_BASE."

# =========================================================
# BUILD AIDER ARGS
# =========================================================

AIDER_ARGS=(
  --config "$ROOT_DIR/.aider.empty.conf.yml"

  --model openai/meta/llama-3.1-8b-instruct

  --no-stream
  --no-pretty
  --no-git

  --map-tokens 0
  --map-refresh manual

  --no-show-model-warnings

  --yes-always
  --exit

  --read "$ACTIVE_TASK_PATH"
  --read "$AGENTS_FILE"
  --read "$ARCH_GRAPH_FILE"

  --message-file "$MODE_PATH"
)

# =========================================================
# MUTATION-AUTHORIZED MODES
# =========================================================

if is_mutation_mode
then

  [[ -n "$EDITABLE_SURFACES" ]] \
    || fail "Missing editable surfaces."

  IFS=',' read -r -a SURFACES \
    <<< "$EDITABLE_SURFACES"

  for surface in "${SURFACES[@]}"
  do

    surface="${surface//[[:space:]]/}"

    [[ -z "$surface" ]] && continue

    AIDER_ARGS+=(
      "$ROOT_DIR/$surface"
    )

  done
fi

# =========================================================
# EXECUTE AIDER
# =========================================================

set +e

OUTPUT="$(
  timeout "$EXECUTION_TIMEOUT" \
    aider \
      "${AIDER_ARGS[@]}" \
      2>&1
)"

EXIT_CODE=$?

set -e

# =========================================================
# TIMEOUT DETECTION
# =========================================================

if [[ "$EXIT_CODE" -eq 124 ]]
then
  debug_output "TIMEOUT OUTPUT"
  fail "Provider execution timeout."
fi

# =========================================================
# PROVIDER FAILURE DETECTION
# =========================================================

if echo "$OUTPUT" | grep -qi \
  "InternalServerError"
then
  debug_output "PROVIDER INTERNAL SERVER FAILURE"
  fail "Provider internal server failure."
fi

if echo "$OUTPUT" | grep -qi \
  "RateLimit"
then
  debug_output "PROVIDER RATE LIMIT FAILURE"
  fail "Provider rate limit failure."
fi

if echo "$OUTPUT" | grep -qi \
  "AuthenticationError"
then
  debug_output "PROVIDER AUTH FAILURE"
  fail "Provider authentication failure."
fi

if echo "$OUTPUT" | grep -qi \
  "Connection error"
then
  debug_output "PROVIDER CONNECTION FAILURE"
  fail "Provider connection failure."
fi

if echo "$OUTPUT" | grep -qi \
  "API key"
then
  debug_output "PROVIDER API KEY FAILURE"
  fail "Provider API key failure."
fi

# =========================================================
# SENTINEL EXTRACTION
# =========================================================

ARTIFACT="$(
  echo "$OUTPUT" | awk '
    /AEGIS_ARTIFACT_BEGIN/ {
      capture=1
      next
    }

    /AEGIS_ARTIFACT_END/ {
      capture=0
    }

    capture
  '
)"

# =========================================================
# ARTIFACT VALIDATION
# =========================================================

[[ -n "$ARTIFACT" ]] || {

  debug_output "RAW OUTPUT"

  fail "Missing sentinel-framed artifact."
}

echo "$ARTIFACT" | jq empty \
  >/dev/null 2>&1 \
  || fail "Invalid JSON runtime artifact."

# =========================================================
# REQUIRED FIELD VALIDATION
# =========================================================

REQUIRED_FIELDS=(
  mode
  status
  confidence
)

for FIELD in "${REQUIRED_FIELDS[@]}"
do

  VALUE="$(
    echo "$ARTIFACT" | jq -r \
      ".$FIELD // empty"
  )"

  [[ -n "$VALUE" ]] \
    || fail "Missing required field: $FIELD"

done

# =========================================================
# MODE VALIDATION
# =========================================================

ARTIFACT_MODE="$(
  echo "$ARTIFACT" | jq -r '.mode'
)"

[[ "$ARTIFACT_MODE" == "$EXPECTED_MODE" ]] \
  || fail "Mode/artifact mismatch detected."

# =========================================================
# SUCCESS
# =========================================================

echo "$ARTIFACT"