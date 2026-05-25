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
# ENVIRONMENT VALIDATION
# =========================================================

[[ -n "${OPENAI_API_KEY:-}" ]] \
  || fail "Missing OPENAI_API_KEY."

[[ -n "${OPENAI_API_BASE:-}" ]] \
  || fail "Missing OPENAI_API_BASE."

# =========================================================
# LOAD MODE CONTRACT
# =========================================================

MODE_CONTRACT="$(
  cat "$MODE_PATH"
)"

# =========================================================
# MODE MESSAGE
# =========================================================

MODE_MESSAGE="/ask

Execute the following mode contract exactly.

DO NOT create files.
DO NOT emit patches.
DO NOT implement code.
DO NOT generate file listings.

Emit ONLY the required sentinel-framed artifact.

$MODE_CONTRACT"

if [[ "$EXPECTED_MODE" == "repair" ]]
then

MODE_MESSAGE="Execute the following repair mode contract exactly.

Objective:
Remove the empty export statement from src/ui/index.ts while preserving valid TypeScript syntax.

$MODE_CONTRACT"

fi

if [[ "$EXPECTED_MODE" == "optimize" ]]
then

MODE_MESSAGE="Execute the following optimize mode contract exactly.

$MODE_CONTRACT"

fi

# =========================================================
# BUILD AIDER ARGS
# =========================================================

AIDER_ARGS=(
  --config "$ROOT_DIR/.aider.empty.conf.yml"

  --model openai/meta/llama-3.3-70b-instruct

  --edit-format diff

  --yes-always
  --exit

  --read "$ACTIVE_TASK_PATH"
  --read "$AGENTS_FILE"
  --read "$ARCH_GRAPH_FILE"

  --message "$MODE_MESSAGE"
)

# =========================================================
# EDITABLE SURFACES
# =========================================================

if [[ -n "$EDITABLE_SURFACES" ]]
then

  IFS=',' read -r -a SURFACES \
    <<< "$EDITABLE_SURFACES"

  for surface in "${SURFACES[@]}"
  do

    surface="${surface//[[:space:]]/}"

    [[ -z "$surface" ]] && continue

    AIDER_ARGS+=(
      "$surface"
    )

  done
fi

# =========================================================
# EXECUTION
# =========================================================

echo
echo "[AEGIS] Starting aider execution..."
echo

cd "$ROOT_DIR"

set +e

OUTPUT="$(
  timeout "$EXECUTION_TIMEOUT" \
    aider \
      "${AIDER_ARGS[@]}" \
      2>&1
)"

EXIT_CODE=$?

set -e

echo
echo "[AEGIS] Aider execution completed."
echo

# =========================================================
# PROPAGATE RAW OUTPUT
# =========================================================

echo "$OUTPUT"

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

# =========================================================
# SENTINEL EXTRACTION
# =========================================================

echo
echo "[AEGIS] Extracting artifact..."
echo

ARTIFACT="$(
  printf '%s\n' "$OUTPUT" \
    | sed -n '/AEGIS_ARTIFACT_BEGIN/,/AEGIS_ARTIFACT_END/p' \
    | sed '1d;$d'
)"

# =========================================================
# REQUIRED ARTIFACT VALIDATION
# =========================================================

if [[ -z "$ARTIFACT" ]]
then

  if [[ "$EXPECTED_MODE" == "repair" ]] \
    || [[ "$EXPECTED_MODE" == "optimize" ]]
  then

    echo
    echo "[AEGIS] No runtime artifact emitted."
    echo

    exit 0
  fi

  debug_output "RAW OUTPUT"

  fail "Missing sentinel-framed artifact."
fi

# =========================================================
# ARTIFACT VALIDATION
# =========================================================

echo
echo "[AEGIS] Validating artifact..."
echo

echo "$ARTIFACT" | jq empty \
  >/dev/null 2>&1 \
  || {

    debug_output "INVALID JSON OUTPUT"

    fail "Invalid JSON runtime artifact."
  }

# =========================================================
# MODE VALIDATION
# =========================================================

ARTIFACT_MODE="$(
  echo "$ARTIFACT" | jq -r '.mode'
)"

[[ "$ARTIFACT_MODE" == "$EXPECTED_MODE" ]] \
  || fail "Mode/artifact mismatch detected."

echo
echo "[AEGIS] Artifact validated successfully."
echo

# =========================================================
# SUCCESS
# =========================================================

printf '%s\n' "$ARTIFACT"