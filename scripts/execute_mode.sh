#!/usr/bin/env bash

# =========================================================
# AEGIS HARNESS — MODE EXECUTOR
# =========================================================

set -euo pipefail

# =========================================================
# INPUT
# =========================================================

MODE_FILE="${1:-}"

[[ -n "$MODE_FILE" ]] || {
  echo "[AEGIS] Missing mode file argument."
  exit 1
}

[[ -f "$MODE_FILE" ]] || {
  echo "[AEGIS] Mode file not found: $MODE_FILE"
  exit 1
}

# =========================================================
# FILES
# =========================================================

AGENTS_FILE="AGENTS.md"

ACTIVE_TASK_FILE="docs/active_task.md"

ARCHITECTURE_GRAPH_FILE=".harness/architecture_graph.json"

RESULT_FILE=".harness/runtime/result.json"

EMPTY_CONFIG_FILE=".aider.empty.conf.yml"

# =========================================================
# MODEL
# =========================================================

MODEL_NAME="openai/qwen/qwen3-next-80b-a3b-instruct"

# =========================================================
# VALIDATION
# =========================================================

[[ -f "$AGENTS_FILE" ]] || {
  echo "[AEGIS] Missing AGENTS.md"
  exit 1
}

[[ -f "$ACTIVE_TASK_FILE" ]] || {
  echo "[AEGIS] Missing docs/active_task.md"
  exit 1
}

[[ -f "$ARCHITECTURE_GRAPH_FILE" ]] || {
  echo "[AEGIS] Missing architecture_graph.json"
  exit 1
}

[[ -f "$EMPTY_CONFIG_FILE" ]] || {
  echo "[AEGIS] Missing .aider.empty.conf.yml"
  exit 1
}

[[ -n "${OPENAI_API_KEY:-}" ]] || {
  echo "[AEGIS] Missing OPENAI_API_KEY"
  exit 1
}

[[ -n "${OPENAI_API_BASE:-}" ]] || {
  echo "[AEGIS] Missing OPENAI_API_BASE"
  exit 1
}

# =========================================================
# PREPARE
# =========================================================

mkdir -p ".harness/runtime"

rm -f "$RESULT_FILE"

# =========================================================
# TERMINAL STABILITY
# =========================================================

export COLUMNS=1000

# =========================================================
# EXECUTION
# =========================================================

echo ""
echo "================================================="
echo "[AEGIS] Executing mode file: $MODE_FILE"
echo "================================================="
echo ""

set +e

OUTPUT=$(timeout 120s aider \
  --config "$EMPTY_CONFIG_FILE" \
  --model "$MODEL_NAME" \
  --yes-always \
  --dry-run \
  --no-auto-commits \
  --no-restore-chat-history \
  --no-git \
  --map-tokens 0 \
  --map-refresh manual \
  --no-show-model-warnings \
  --no-stream \
  --no-pretty \
  --exit \
  --read "$AGENTS_FILE" \
  --read "$ACTIVE_TASK_FILE" \
  --read "$ARCHITECTURE_GRAPH_FILE" \
  --message-file "$MODE_FILE" \
  2>&1)

EXIT_CODE=$?

set -e

# =========================================================
# TIMEOUT
# =========================================================

if [[ $EXIT_CODE -eq 124 ]]; then

  echo ""
  echo "[AEGIS] Provider execution timeout."
  echo ""

  exit 1
fi

# =========================================================
# PROVIDER FAILURES
# =========================================================

if echo "$OUTPUT" | grep -qi "InternalServerError"; then

  echo ""
  echo "[AEGIS] Provider execution failure."
  echo ""

  echo "$OUTPUT"

  exit 1
fi

if echo "$OUTPUT" | grep -qi "AuthenticationError"; then

  echo ""
  echo "[AEGIS] Provider authentication failure."
  echo ""

  echo "$OUTPUT"

  exit 1
fi

if echo "$OUTPUT" | grep -qi "Connection error"; then

  echo ""
  echo "[AEGIS] Provider connection failure."
  echo ""

  echo "$OUTPUT"

  exit 1
fi

# =========================================================
# EXECUTION FAILURE
# =========================================================

if [[ $EXIT_CODE -ne 0 ]]; then

  echo ""
  echo "[AEGIS] Mechanical execution failure detected."
  echo ""

  echo "$OUTPUT"

  exit 1
fi

# =========================================================
# SENTINEL EXTRACTION
# =========================================================

JSON_OUTPUT=$(echo "$OUTPUT" | sed -n '
/===AEGIS_RESULT_START===/,/===AEGIS_RESULT_END===/p
')

[[ -n "$JSON_OUTPUT" ]] || {

  echo ""
  echo "[AEGIS] Missing sentinel-framed artifact."
  echo ""

  echo "$OUTPUT"

  exit 1
}

# =========================================================
# REMOVE SENTINELS
# =========================================================

JSON_OUTPUT=$(echo "$JSON_OUTPUT" | sed '1d;$d')

[[ -n "$JSON_OUTPUT" ]] || {

  echo ""
  echo "[AEGIS] Empty JSON artifact."
  echo ""

  exit 1
}

# =========================================================
# PERSIST
# =========================================================

echo "$JSON_OUTPUT" > "$RESULT_FILE"

# =========================================================
# JSON VALIDATION
# =========================================================

if ! jq . "$RESULT_FILE" >/dev/null 2>&1; then

  echo ""
  echo "[AEGIS] Invalid JSON runtime artifact."
  echo ""

  cat "$RESULT_FILE"

  exit 1
fi

# =========================================================
# REQUIRED FIELDS
# =========================================================

REQUIRED_FIELDS=(
  "mode"
  "status"
  "confidence"
  "claims"
  "hypotheses"
  "escalation_required"
  "escalation_reason"
)

for FIELD in "${REQUIRED_FIELDS[@]}"; do

  if ! jq -e "has(\"${FIELD}\")" \
    "$RESULT_FILE" >/dev/null 2>&1; then

    echo ""
    echo "[AEGIS] Missing required field: $FIELD"
    echo ""

    cat "$RESULT_FILE"

    exit 1
  fi
done

# =========================================================
# SUCCESS
# =========================================================

echo ""
echo "[AEGIS] Mechanical execution integrity verified."
echo "[AEGIS] Structured runtime artifact persisted."
echo ""

exit 0