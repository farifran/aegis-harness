#!/usr/bin/env bash

set -euo pipefail

# =========================================================
# EXECUTE MODE
# =========================================================

MODE_FILE="${1:?missing mode file}"

EXPECTED_MODE="${2:?missing mode name}"

ACTIVE_TASK_PATH="${3:-}"

EDITABLE_SURFACES="${4:-}"

ROOT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
)"

# =========================================================
# CENTRAL CONFIG
# =========================================================

source "$ROOT_DIR/.harness/config.sh"

# =========================================================
# PATHS
# =========================================================

MODE_PATH="$ROOT_DIR/$MODE_FILE"

AGENTS_FILE="$ROOT_DIR/AGENTS.md"

ARCH_GRAPH_FILE="$ROOT_DIR/.harness/architecture_graph.json"

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

  printf '%s\n' "$OUTPUT"

  echo
  echo "================================================="
  echo
}

# =========================================================
# VALIDATION
# =========================================================

[[ -f "$MODE_PATH" ]] \
  || fail "Mode file not found."

[[ -f "$AGENTS_FILE" ]] \
  || fail "Missing AGENTS.md."

[[ -f "$ARCH_GRAPH_FILE" ]] \
  || fail "Missing architecture_graph.json."

if [[ "$EXPECTED_MODE" != "discovery" ]]
then

  [[ -n "$ACTIVE_TASK_PATH" ]] \
    || fail "Missing runtime active task path."

  [[ -f "$ACTIVE_TASK_PATH" ]] \
    || fail "Missing runtime active task."

fi

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
# OPERATIONAL BOOTSTRAP
# =========================================================

MODE_BOOTSTRAP="Execute immediately.

No conversation.
No questions.
No explanations.

Emit exactly one sentinel-framed artifact."

# =========================================================
# MODE OBJECTIVE
# =========================================================

MODE_OBJECTIVE="Inspect the currently observable runtime and repository state."

if [[ "$EXPECTED_MODE" == "forensics" ]]
then
  MODE_OBJECTIVE="Inspect the currently observable operational integrity state."
fi

if [[ "$EXPECTED_MODE" == "validation" ]]
then
  MODE_OBJECTIVE="Inspect the currently observable execution validity state."
fi

if [[ "$EXPECTED_MODE" == "adversarial" ]]
then
  MODE_OBJECTIVE="Inspect the currently observable boundary and failure surfaces."
fi

if [[ "$EXPECTED_MODE" == "repair" ]]
then

MODE_OBJECTIVE="Execute only the explicitly authorized bounded repair.

Remove the empty export statement from src/ui/index.ts while preserving valid TypeScript syntax."

fi

if [[ "$EXPECTED_MODE" == "optimize" ]]
then
  MODE_OBJECTIVE="Execute only explicitly authorized bounded optimization."
fi

# =========================================================
# STRUCTURAL OUTPUT PRIMING
# =========================================================

OUTPUT_PRIMING="Begin output now:

AEGIS_ARTIFACT_BEGIN
{
  \"mode\": \"$EXPECTED_MODE\","

# =========================================================
# FINAL MESSAGE
# =========================================================

MODE_MESSAGE="/ask

$MODE_BOOTSTRAP

Objective:
$MODE_OBJECTIVE

$MODE_CONTRACT

$OUTPUT_PRIMING"

# =========================================================
# BUILD AIDER ARGS
# =========================================================

AIDER_ARGS=(
  --config "$ROOT_DIR/.aider.empty.conf.yml"

  --model "$AEGIS_MODEL"

  --edit-format "$AEGIS_EDIT_FORMAT"

  --yes-always
  --exit

  --read "$AGENTS_FILE"

  --read "$ARCH_GRAPH_FILE"

  --message "$MODE_MESSAGE"
)

# =========================================================
# OPTIONAL ACTIVE TASK
# =========================================================

if [[ -n "$ACTIVE_TASK_PATH" ]] \
  && [[ -f "$ACTIVE_TASK_PATH" ]]
then

  AIDER_ARGS+=(
    --read "$ACTIVE_TASK_PATH"
  )

fi

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

    AIDER_ARGS+=("$surface")

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
  timeout "$AEGIS_EXECUTION_TIMEOUT" \
    aider \
      "${AIDER_ARGS[@]}" \
      2>&1
)"

EXIT_CODE=$?

set -e

echo
echo "[AEGIS] Aider execution completed."
echo

printf '%s\n' "$OUTPUT"

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

if echo "$OUTPUT" | grep -qi "InternalServerError"
then

  debug_output "PROVIDER INTERNAL SERVER FAILURE"

  fail "Provider internal server failure."

fi

if echo "$OUTPUT" | grep -qi "RateLimit"
then

  debug_output "PROVIDER RATE LIMIT FAILURE"

  fail "Provider rate limit failure."

fi

if echo "$OUTPUT" | grep -qi "AuthenticationError"
then

  debug_output "PROVIDER AUTH FAILURE"

  fail "Provider authentication failure."

fi

if echo "$OUTPUT" | grep -qi "Connection error"
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

# =========================================================
# SUCCESS
# =========================================================

echo
echo "[AEGIS] Artifact validated successfully."
echo

printf '%s\n' "$ARTIFACT"