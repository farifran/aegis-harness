#!/usr/bin/env bash

set -euo pipefail

# =========================================================
# EXECUTE MODE
# =========================================================

MODE_FILE="${1:?missing mode file}"

EXPECTED_MODE="${2:?missing mode name}"

ACTIVE_TASK_PATH="${3:?missing active task path}"

ROOT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
)"

MODE_PATH="$ROOT_DIR/$MODE_FILE"

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
# VALIDATION
# =========================================================

[[ -f "$MODE_PATH" ]] \
  || fail "Mode file not found."

[[ -f "$ACTIVE_TASK_PATH" ]] \
  || fail "Missing runtime active task."

# =========================================================
# MODE CAPABILITY MODEL
# =========================================================

is_hard_containment_mode() {

  case "$EXPECTED_MODE" in
    discovery|\
    forensics|\
    validation|\
    adversarial)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# =========================================================
# BUILD AIDER FLAGS
# =========================================================

AIDER_FLAGS=(
  --config "$ROOT_DIR/.aider.empty.conf.yml"
  --model openai/qwen/qwen3-next-80b-a3b-instruct
  --no-stream
  --no-git
  --map-tokens 0
  --map-refresh manual
  --yes-always
  --exit
)

# ---------------------------------------------------------
# HARD CONTAINMENT MODES
# ---------------------------------------------------------

if is_hard_containment_mode
then
  AIDER_FLAGS+=(--ask)
fi

# =========================================================
# EXECUTE AIDER
# =========================================================

set +e

OUTPUT="$(
  timeout "$EXECUTION_TIMEOUT" \
    aider \
      "${AIDER_FLAGS[@]}" \
      "$ACTIVE_TASK_PATH" \
      "$MODE_FILE" \
      --message-file "$MODE_PATH" \
      2>&1
)"

EXIT_CODE=$?

set -e

# =========================================================
# TIMEOUT DETECTION
# =========================================================

if [[ "$EXIT_CODE" -eq 124 ]]
then
  fail "Provider execution timeout."
fi

# =========================================================
# PROVIDER FAILURE DETECTION
# =========================================================

if echo "$OUTPUT" | grep -qi \
  "InternalServerError"
then
  fail "Provider internal server failure."
fi

if echo "$OUTPUT" | grep -qi \
  "RateLimit"
then
  fail "Provider rate limit failure."
fi

if echo "$OUTPUT" | grep -qi \
  "AuthenticationError"
then
  fail "Provider authentication failure."
fi

if echo "$OUTPUT" | grep -qi \
  "Connection error"
then
  fail "Provider connection failure."
fi

if echo "$OUTPUT" | grep -qi \
  "API key"
then
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

[[ -n "$ARTIFACT" ]] \
  || fail "Missing sentinel-framed artifact."

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