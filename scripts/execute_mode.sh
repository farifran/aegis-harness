#!/usr/bin/env bash

set -euo pipefail

MODE_FILE="${1:-}"

# =========================================================
# VALIDATION
# =========================================================

if [[ -z "$MODE_FILE" ]]
then
  echo "[AEGIS] Missing mode file."
  exit 1
fi

if [[ ! -f "$MODE_FILE" ]]
then
  echo "[AEGIS] Mode file not found: $MODE_FILE"
  exit 1
fi

if [[ ! -f "docs/active_task.md" ]]
then
  echo "[AEGIS] Missing session active_task.md"
  exit 1
fi

if [[ ! -f "AGENTS.md" ]]
then
  echo "[AEGIS] Missing AGENTS.md"
  exit 1
fi

if [[ ! -f ".harness/architecture_graph.json" ]]
then
  echo "[AEGIS] Missing architecture_graph.json"
  exit 1
fi

# =========================================================
# EXECUTION HEADER
# =========================================================

echo
echo "================================================="
echo "[AEGIS] Executing mode file: $MODE_FILE"
echo "================================================="
echo

# =========================================================
# EXECUTE AIDER
# =========================================================

OUTPUT="$(
aider \
  --config .aider.empty.conf.yml \
  --model openai/qwen/qwen3-next-80b-a3b-instruct \
  --no-stream \
  --no-git \
  --map-tokens 0 \
  --map-refresh manual \
  --no-show-model-warnings \
  --yes-always \
  --exit \
  --message-file "$MODE_FILE" \
  docs/active_task.md \
  AGENTS.md \
  .harness/architecture_graph.json \
  2>&1
)"

# =========================================================
# PROVIDER FAILURE DETECTION
# =========================================================

if echo "$OUTPUT" | grep -qiE \
  "InternalServerError|APIConnectionError|RateLimitError|timeout|Connection error"
then
  echo "[AEGIS] Provider execution failure."
  echo
  echo "$OUTPUT"
  exit 1
fi

# =========================================================
# SENTINEL EXTRACTION
# =========================================================

ARTIFACT="$(
printf '%s\n' "$OUTPUT" | awk '
/AEGIS_ARTIFACT_BEGIN/ { capture=1; next }
/AEGIS_ARTIFACT_END/   { capture=0 }
capture
'
)"

if [[ -z "$ARTIFACT" ]]
then
  echo "[AEGIS] Missing sentinel-framed artifact."
  echo
  echo "$OUTPUT"
  exit 1
fi

# =========================================================
# JSON VALIDATION
# =========================================================

if ! echo "$ARTIFACT" | jq empty >/dev/null 2>&1
then
  echo "[AEGIS] Invalid JSON runtime artifact."
  echo
  echo "$ARTIFACT"
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

for FIELD in "${REQUIRED_FIELDS[@]}"
do
  if ! echo "$ARTIFACT" | jq -e ".${FIELD}" >/dev/null 2>&1
  then
    echo "[AEGIS] Missing required field: $FIELD"
    echo
    echo "$ARTIFACT"
    exit 1
  fi
done

# =========================================================
# PERSIST SESSION FINDINGS
# =========================================================

{
  echo
  echo "---"
  echo
  echo "## Session Findings"
  echo
  echo '```json'
  echo "$ARTIFACT"
  echo '```'
} >> docs/active_task.md

# =========================================================
# SUCCESS
# =========================================================

echo
echo "[AEGIS] Mechanical execution integrity verified."
echo "[AEGIS] Structured runtime artifact persisted."
echo