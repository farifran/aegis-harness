#!/usr/bin/env bash

set -euo pipefail

MODE_FILE="${1:?missing mode file}"
EXPECTED_MODE="${2:?missing mode name}"
ACTIVE_TASK_PATH="${3:-}"
EDITABLE_SURFACES="${4:-}"

ROOT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
)"

source "$ROOT_DIR/.harness/config.sh"

MODE_PATH="$ROOT_DIR/$MODE_FILE"
AGENTS_FILE="$ROOT_DIR/AGENTS.md"
ARCH_GRAPH_FILE="$ROOT_DIR/.harness/architecture_graph.json"

MODE_EDIT_AUTHORITY_VAR="AEGIS_MODE_EDIT_AUTHORITY_${EXPECTED_MODE}"
MODE_EDIT_AUTHORITY="${!MODE_EDIT_AUTHORITY_VAR:-false}"

fail() {
  echo
  echo "[AEGIS] $1" >&2
  echo
  exit 1
}

debug_output() {
  local title="$1"

  echo
  echo "================================================="
  echo "[AEGIS DEBUG] $title"
  echo "================================================="
  echo

  printf '%s\n' "$RAW_OUTPUT"

  echo
  echo "================================================="
  echo
}

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

[[ -n "${AEGIS_MODEL:-}" ]] \
  || fail "Missing AEGIS_MODEL."

[[ -n "${AEGIS_EDIT_FORMAT:-}" ]] \
  || fail "Missing AEGIS_EDIT_FORMAT."

[[ -n "${AEGIS_EXECUTION_TIMEOUT:-}" ]] \
  || fail "Missing AEGIS_EXECUTION_TIMEOUT."

[[ "${AEGIS_EXECUTION_TIMEOUT}" =~ ^[0-9]+$ ]] \
  || fail "Invalid execution timeout."

MODE_CONTRACT="$(
  cat "$MODE_PATH"
)"

MODE_OBJECTIVE="Inspect observable runtime state."

case "$EXPECTED_MODE" in
  discovery)
    MODE_OBJECTIVE="Inspect observable runtime and repository state."
    ;;
  forensics)
    MODE_OBJECTIVE="Inspect observable operational integrity."
    ;;
  validation)
    MODE_OBJECTIVE="Inspect observable execution validity."
    ;;
  adversarial)
    MODE_OBJECTIVE="Inspect observable boundary and containment weaknesses."
    ;;
  repair)
    MODE_OBJECTIVE="Execute the explicitly authorized bounded repair."
    ;;
  optimize)
    MODE_OBJECTIVE="Execute the explicitly authorized bounded optimization."
    ;;
esac

MODE_MESSAGE="/ask

Execute immediately.

Rules:
- no conversation;
- no questions;
- no acknowledgements;
- no explanations;
- no reasoning;
- emit exactly one JSON object;
- do not emit markdown;
- do not emit prose before JSON;
- do not emit prose after JSON.

Objective:
$MODE_OBJECTIVE

$MODE_CONTRACT"

AIDER_ARGS=(
  --config "$ROOT_DIR/.aider.empty.conf.yml"
  --model "$AEGIS_MODEL"
  --yes-always
  --exit
  --read "$AGENTS_FILE"
  --read "$ARCH_GRAPH_FILE"
  --message "$MODE_MESSAGE"
)

if [[ "$MODE_EDIT_AUTHORITY" == "true" ]]
then
  AIDER_ARGS+=(
    --edit-format "$AEGIS_EDIT_FORMAT"
  )
fi

if [[ -n "$ACTIVE_TASK_PATH" ]] \
  && [[ -f "$ACTIVE_TASK_PATH" ]]
then
  AIDER_ARGS+=(
    --read "$ACTIVE_TASK_PATH"
  )
fi

if [[ -n "$EDITABLE_SURFACES" ]]
then
  IFS=',' read -r -a SURFACES <<< "$EDITABLE_SURFACES"

  for surface in "${SURFACES[@]}"
  do
    surface="${surface//[[:space:]]/}"

    [[ -z "$surface" ]] && continue

    AIDER_ARGS+=("$surface")
  done
fi

echo
echo "[AEGIS] Starting aider execution..."
echo

cd "$ROOT_DIR"

set +e

RAW_OUTPUT="$(
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

printf '%s\n' "$RAW_OUTPUT"

if [[ "$EXIT_CODE" -eq 124 ]]
then
  debug_output "TIMEOUT OUTPUT"
  fail "Provider execution timeout."
fi

if echo "$RAW_OUTPUT" | grep -qi -E \
  'InternalServerError|RateLimit|AuthenticationError|Connection error'
then
  debug_output "PROVIDER FAILURE"
  fail "Provider execution failure."
fi

JSON_PAYLOAD="$(
printf '%s' "$RAW_OUTPUT" | python3 -c '
import json
import sys

data = sys.stdin.read()

decoder = json.JSONDecoder()

for i, ch in enumerate(data):
    if ch != "{":
        continue

    try:
        obj, end = decoder.raw_decode(data[i:])
        print(json.dumps(obj))
        sys.exit(0)
    except Exception:
        pass

sys.exit(1)
'
)"

[[ -n "$JSON_PAYLOAD" ]] || {
  debug_output "RAW OUTPUT"
  fail "Missing JSON artifact."
}

echo
echo "[AEGIS] Validating artifact..."
echo

echo "$JSON_PAYLOAD" | jq empty >/dev/null 2>&1 || {
  debug_output "INVALID JSON OUTPUT"
  fail "Invalid JSON runtime artifact."
}

ARTIFACT_MODE="$(
  echo "$JSON_PAYLOAD" | jq -r '.mode'
)"

[[ "$ARTIFACT_MODE" == "$EXPECTED_MODE" ]] || {
  fail "Mode/artifact mismatch detected."
}

OUTPUT="$(printf '%s\n%s\n%s\n' \
  'AEGIS_ARTIFACT_BEGIN' \
  "$JSON_PAYLOAD" \
  'AEGIS_ARTIFACT_END'
)"

echo
echo "[AEGIS] Artifact validated successfully."
echo

printf '%s\n' "$OUTPUT"