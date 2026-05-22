#!/usr/bin/env bash

# =========================================================
# AEGIS HARNESS — RUNTIME
# =========================================================
#
# Responsibilities:
# - deterministic mode execution;
# - execution isolation;
# - governed context injection;
# - structured artifact validation;
# - bounded lifecycle governance.
#
# Runtime remains semantically blind.
#
# =========================================================

set -euo pipefail

# =========================================================
# CONFIGURATION
# =========================================================

MODES=(
  ".skills/mode_0_discovery.md"
)

MODEL_NAME="openai/deepseek-ai/deepseek-v4-pro"

ROOT_DIR="$(pwd)"

RUNTIME_DIR=".harness/runtime"

RESULT_FILE="$RUNTIME_DIR/result.json"

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
# REQUIRED FILES
# =========================================================

REQUIRED_FILES=(
  "AGENTS.md"
  "docs/active_task.md"
  ".harness/architecture_graph.json"
  "scripts/execute_mode.sh"
)

for FILE in "${REQUIRED_FILES[@]}"; do

  if [[ ! -f "$FILE" ]]; then
    echo "[AEGIS] Missing required file: $FILE"
    exit 1
  fi
done

# =========================================================
# RUNTIME DIRECTORY
# =========================================================

mkdir -p "$RUNTIME_DIR"

# =========================================================
# EXECUTION LOOP
# =========================================================

for MODE_FILE in "${MODES[@]}"; do

  MODE_NAME=$(basename "$MODE_FILE" .md)

  echo ""
  echo "================================================="
  echo "[AEGIS] Executing: $MODE_NAME"
  echo "================================================="
  echo ""

  # =======================================================
  # SANDBOX SETUP
  # =======================================================

  SESSION_ID=$(uuidgen)

  SANDBOX_DIR="/tmp/aegis-$SESSION_ID"

  git worktree add --detach "$SANDBOX_DIR" >/dev/null 2>&1

  cleanup() {

    cd "$ROOT_DIR" >/dev/null 2>&1 || true

    git worktree remove "$SANDBOX_DIR" \
      --force >/dev/null 2>&1 || true
  }

  trap cleanup EXIT

  # =======================================================
  # ENTER SANDBOX
  # =======================================================

  cd "$SANDBOX_DIR"

  # =======================================================
  # REMOVE EXECUTOR CONTINUITY
  # =======================================================

  rm -rf .aider*

  # =======================================================
  # CLEAN PREVIOUS RESULT
  # =======================================================

  rm -f "$RESULT_FILE"

  # =======================================================
  # EXECUTE MODE
  # =======================================================

  if ! bash "scripts/execute_mode.sh" "$MODE_FILE"; then

    echo ""
    echo "[AEGIS RUNTIME] ERROR: Mechanical mode execution failure."
    echo ""

    exit 1
  fi

  # =======================================================
  # RESULT VALIDATION
  # =======================================================

  if [[ ! -f "$RESULT_FILE" ]]; then

    echo ""
    echo "[AEGIS] Missing runtime result artifact."
    echo ""

    exit 1
  fi

  if ! jq empty "$RESULT_FILE" >/dev/null 2>&1; then

    echo ""
    echo "[AEGIS] Invalid JSON runtime artifact."
    echo ""

    cat "$RESULT_FILE"

    exit 1
  fi

  # =======================================================
  # REQUIRED FIELD VALIDATION
  # =======================================================

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

  # =======================================================
  # COPY RESULT BACK TO ROOT REPO
  # =======================================================

  mkdir -p "$ROOT_DIR/$RUNTIME_DIR"

  cp "$RESULT_FILE" \
    "$ROOT_DIR/$RESULT_FILE"

  # =======================================================
  # SUCCESS
  # =======================================================

  echo ""
  echo "[AEGIS] Mechanical execution integrity verified."
  echo "[AEGIS] Structured runtime artifact persisted."
  echo ""

  # =======================================================
  # EXIT SANDBOX
  # =======================================================

  cd "$ROOT_DIR"

  git worktree remove "$SANDBOX_DIR" \
    --force >/dev/null 2>&1

  trap - EXIT

done

# =========================================================
# COMPLETE
# =========================================================

echo ""
echo "================================================="
echo "[AEGIS] Runtime execution completed."
echo "================================================="
echo ""

exit 0