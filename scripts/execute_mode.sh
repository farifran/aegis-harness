#!/usr/bin/env bash

# =========================================================
# AEGIS HARNESS — MODE EXECUTOR
# =========================================================
#
# Responsibilities:
# - execute a single cognition mode;
# - capture structured runtime artifacts;
# - validate mechanical execution integrity.
#
# This layer remains semantically blind.
#
# Sandbox lifecycle belongs to:
# - runtime_aegis.sh
#
# =========================================================

set -euo pipefail

# =========================================================
# INPUT
# =========================================================

MODE_FILE="${1:-}"

if [[ -z "$MODE_FILE" ]]; then
  echo "[AEGIS] Missing mode file argument."
  exit 1
fi

if [[ ! -f "$MODE_FILE" ]]; then
  echo "[AEGIS] Mode file not found: $MODE_FILE"
  exit 1
fi

# =========================================================
# GOVERNED CONTEXT
# =========================================================

AGENTS_FILE="AGENTS.md"

ACTIVE_TASK_FILE="docs/active_task.md"

ARCHITECTURE_GRAPH_FILE=".harness/architecture_graph.json"

RESULT_FILE=".harness/runtime/result.json"

# =========================================================
# MODEL
# =========================================================

MODEL_NAME="openai/qwen/qwen3-next-80b-a3b-instruct"

# =========================================================
# REQUIRED CONTEXT VALIDATION
# =========================================================

if [[ ! -f "$AGENTS_FILE" ]]; then
  echo "[AEGIS] Missing AGENTS.md"
  exit 1
fi

if [[ ! -f "$ACTIVE_TASK_FILE" ]]; then
  echo "[AEGIS] Missing docs/active_task.md"
  exit 1
fi

if [[ ! -f "$ARCHITECTURE_GRAPH_FILE" ]]; then
  echo "[AEGIS] Missing architecture_graph.json"
  exit 1
fi

if [[ ! -f ".aider.empty.conf.yml" ]]; then
  echo "[AEGIS] Missing .aider.empty.conf.yml"
  exit 1
fi

# =========================================================
# PROVIDER VALIDATION
# =========================================================

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  echo "[AEGIS] Missing OPENAI_API_KEY"
  exit 1
fi

if [[ -z "${OPENAI_API_BASE:-}" ]]; then
  echo "[AEGIS] Missing OPENAI_API_BASE"
  exit 1
fi

# =========================================================
# CLEAN PREVIOUS RESULT
# =========================================================

mkdir -p ".harness/runtime"

rm -f "$RESULT_FILE"

# =========================================================
# EXECUTION
# =========================================================

echo ""
echo "================================================="
echo "[AEGIS] Executing mode file: $MODE_FILE"
echo "================================================="
echo ""

set +e

OUTPUT=$(aider \
  --config .aider.empty.conf.yml \
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
  --exit \
  --read "$AGENTS_FILE" \
  --read "$ACTIVE_TASK_FILE" \
  --read "$ARCHITECTURE_GRAPH_FILE" \
  --message-file "$MODE_FILE" \
  2>&1)

EXIT_CODE=$?

set -e

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
# JSON EXTRACTION
# =========================================================

RAW_JSON=$(echo "$OUTPUT" | python3 -c '
import sys

text = sys.stdin.read()

start = text.find("{")

if start == -1:
    sys.exit(1)

depth = 0
end = None

for i, ch in enumerate(text[start:], start=start):

    if ch == "{":
        depth += 1

    elif ch == "}":
        depth -= 1

        if depth == 0:
            end = i + 1
            break

if end is None:
    sys.exit(1)

print(text[start:end])
')

# =========================================================
# EXTRACTION FAILURE
# =========================================================

if [[ -z "$RAW_JSON" ]]; then

  echo ""
  echo "[AEGIS] Failed to extract JSON artifact."
  echo ""

  echo "$OUTPUT"

  exit 1
fi

# =========================================================
# JSON CANONICALIZATION
# =========================================================

CANONICAL_JSON=$(echo "$RAW_JSON" | python3 -c '
import json
import sys

try:
    obj = json.loads(sys.stdin.read())
    print(json.dumps(obj, ensure_ascii=False))
except Exception as e:
    print(f"[AEGIS] JSON canonicalization failure: {e}", file=sys.stderr)
    sys.exit(1)
')

# =========================================================
# CANONICALIZATION FAILURE
# =========================================================

if [[ -z "$CANONICAL_JSON" ]]; then

  echo ""
  echo "[AEGIS] Failed to canonicalize JSON artifact."
  echo ""

  echo "$RAW_JSON"

  exit 1
fi

# =========================================================
# ARTIFACT CAPTURE
# =========================================================

echo "$CANONICAL_JSON" \
  | tr -d '\r' \
  | sed '/^[[:space:]]*$/d' \
  > "$RESULT_FILE"

# =========================================================
# JSON VALIDATION
# =========================================================

if ! jq . "$RESULT_FILE" > /dev/null 2>&1; then

  echo ""
  echo "[AEGIS] Invalid JSON runtime artifact."
  echo ""

  echo "[AEGIS DEBUG] RAW RESULT:"
  cat "$RESULT_FILE"

  echo ""
  echo "[AEGIS DEBUG] RAW BYTES:"
  python3 -c '
import pathlib

data = pathlib.Path(".harness/runtime/result.json").read_bytes()

print(repr(data[:1000]))
'

  exit 1
fi

# =========================================================
# REQUIRED FIELD VALIDATION
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

  if ! jq -e ".${FIELD}" "$RESULT_FILE" >/dev/null 2>&1; then

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