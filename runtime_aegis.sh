#!/usr/bin/env bash

# =========================================================
# AEGIS RUNTIME — DETERMINISTIC SANDBOX CONTROLLER
# =========================================================
#
# Responsibilities:
# - create isolated disposable execution sandboxes;
# - execute bounded cognition modes;
# - validate runtime artifacts mechanically;
# - enforce deterministic execution lifecycle.
#
# This runtime:
# - does NOT interpret cognition;
# - does NOT validate semantic correctness;
# - does NOT orchestrate epistemology;
# - does NOT redesign execution flow.
#
# Modes think.
# Runtime routes.
#
# =========================================================

set -euo pipefail

# =========================================================
# CONFIG
# =========================================================

MODES=(
  "mode_0_discovery"
)

RESULT_FILE=".harness/runtime/result.json"

# =========================================================
# HELPERS
# =========================================================

fail() {

  echo ""
  echo "[AEGIS RUNTIME] ERROR: $1"
  echo ""

  exit 1
}

read_status() {

  jq -r '.status' "$RESULT_FILE"
}

cleanup_sandbox() {

  if [[ -n "${SANDBOX_DIR:-}" && -d "${SANDBOX_DIR:-}" ]]; then

    cd /workspaces/aegis-harness || true

    git worktree remove "$SANDBOX_DIR" --force >/dev/null 2>&1 || true
  fi
}

# =========================================================
# CLEANUP TRAP
# =========================================================

trap cleanup_sandbox EXIT

# =========================================================
# PROVIDER VALIDATION
# =========================================================

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
  fail "Missing OPENAI_API_KEY"
fi

if [[ -z "${OPENAI_API_BASE:-}" ]]; then
  fail "Missing OPENAI_API_BASE"
fi

# =========================================================
# MODE LOOP
# =========================================================

for MODE_NAME in "${MODES[@]}"; do

  echo ""
  echo "================================================="
  echo "[AEGIS] Executing: $MODE_NAME"
  echo "================================================="
  echo ""

  # -------------------------------------------------------
  # Disposable sandbox identity
  # -------------------------------------------------------

  SANDBOX_ID="sandbox-$(date +%s%N)"

  SANDBOX_DIR="/tmp/$SANDBOX_ID"

  # -------------------------------------------------------
  # Create isolated worktree
  # -------------------------------------------------------

  git worktree add --detach "$SANDBOX_DIR" >/dev/null 2>&1 \
    || fail "Failed to create sandbox worktree"

  cd "$SANDBOX_DIR" \
    || fail "Failed to enter sandbox"

  # -------------------------------------------------------
  # Execute bounded cognition mode
  # -------------------------------------------------------

  MODE_FILE=".skills/${MODE_NAME}.md"

  if [[ ! -f "$MODE_FILE" ]]; then
    fail "Missing mode definition: $MODE_FILE"
  fi

  if ! ./scripts/execute_mode.sh "$MODE_FILE"; then
    fail "Mechanical mode execution failure"
  fi

  # -------------------------------------------------------
  # Runtime artifact validation
  # -------------------------------------------------------

  if [[ ! -f "$RESULT_FILE" ]]; then
    fail "Missing runtime result artifact"
  fi

  if ! jq empty "$RESULT_FILE" >/dev/null 2>&1; then
    fail "Invalid runtime artifact JSON"
  fi

  STATUS="$(read_status)"

  case "$STATUS" in

    RUNNING|COMPLETE)

      echo ""
      echo "[AEGIS] Mode completed successfully."
      echo ""

      ;;

    ESCALATED)

      echo ""
      echo "[AEGIS] Runtime escalated."
      echo ""

      exit 1

      ;;

    *)

      fail "Invalid runtime status: $STATUS"

      ;;

  esac

  # -------------------------------------------------------
  # Destroy sandbox after execution
  # -------------------------------------------------------

  cd /workspaces/aegis-harness \
    || fail "Failed to return to repository root"

  git worktree remove "$SANDBOX_DIR" --force >/dev/null 2>&1 \
    || fail "Failed to destroy sandbox"

done

# =========================================================
# FINAL STATE
# =========================================================

echo ""
echo "================================================="
echo "[AEGIS] Runtime execution completed."
echo "================================================="
echo ""

exit 0