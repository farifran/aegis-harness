#!/usr/bin/env bash

# =========================================================
# AEGIS RUNTIME — MINIMAL DETERMINISTIC CONTROLLER
# =========================================================
#
# This runtime:
# - does NOT think;
# - does NOT interpret epistemology;
# - does NOT validate confidence;
# - does NOT orchestrate cognition;
# - does NOT redesign execution flow.
#
# It only:
# - executes modes;
# - injects deterministic sequencing;
# - validates mechanical execution integrity;
# - enforces bounded continuity containment.
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
  "mode_1_forensics"
  "mode_2_repair"
  "mode_3_optimize"
  "mode_4_adversarial"
  "mode_5_validation"
)

HARNESS_DIR=".harness"

STATE_DIR="$HARNESS_DIR/runtime"

RESULT_FILE="$STATE_DIR/result.json"

mkdir -p "$STATE_DIR"

# =========================================================
# STATE
# =========================================================

RUNTIME_STATE="RUNNING"

CURRENT_MODE_INDEX=0

# =========================================================
# HELPERS
# =========================================================

fail() {
  echo "[AEGIS RUNTIME] ERROR: $1"
  exit 1
}

read_status() {
  grep -o '"status":[[:space:]]*"[^"]*"' "$RESULT_FILE" \
    | cut -d '"' -f4
}

# =========================================================
# EPISTEMIC ISOLATION
# =========================================================

reset_epistemic_state() {

  echo "[AEGIS] Resetting bounded continuity surfaces..."

  # -------------------------------------------------------
  # Conversational continuity
  # -------------------------------------------------------

  rm -f .aider.chat.history.md || true

  # -------------------------------------------------------
  # Prompt continuity
  # -------------------------------------------------------

  rm -f .aider.input.history || true

  # -------------------------------------------------------
  # Temporary operational state
  # -------------------------------------------------------

  rm -rf .aider.tmp || true

  # -------------------------------------------------------
  # Structural topology persistence
  # -------------------------------------------------------

  rm -rf .aider.tags.cache.v4 || true

  # -------------------------------------------------------
  # Additional aider cache variants
  # -------------------------------------------------------

  rm -rf .aider.tags.cache.* || true

  echo "[AEGIS] Bounded continuity reset complete."
}

# =========================================================
# MODE EXECUTION
# =========================================================

execute_mode() {

  local mode_name="$1"

  echo ""
  echo "================================================="
  echo "[AEGIS] Executing: $mode_name"
  echo "================================================="
  echo ""

  rm -f "$RESULT_FILE"

  MODE_FILE=".skills/${mode_name}.md"

  if [[ ! -f "$MODE_FILE" ]]; then
    fail "Missing mode definition: $MODE_FILE"
  fi

  # -------------------------------------------------------
  # Mechanical execution validation only
  # -------------------------------------------------------

  if ! "./scripts/execute_mode.sh" "$MODE_FILE"; then
    fail "Mechanical mode execution failure."
  fi
}

# =========================================================
# MAIN LOOP
# =========================================================

while [[ "$RUNTIME_STATE" == "RUNNING" ]]; do

  CURRENT_MODE="${MODES[$CURRENT_MODE_INDEX]}"

  execute_mode "$CURRENT_MODE"

  STATUS="$(read_status)"

  case "$STATUS" in

    RUNNING)

      echo "[AEGIS] Mode $CURRENT_MODE completed successfully."

      # ---------------------------------------------------
      # Enforce bounded continuity containment
      # ---------------------------------------------------

      reset_epistemic_state

      CURRENT_MODE_INDEX=$((CURRENT_MODE_INDEX + 1))

      if [[ $CURRENT_MODE_INDEX -ge ${#MODES[@]} ]]; then
        RUNTIME_STATE="COMPLETE"
      fi

      ;;

    ESCALATED)

      echo "[AEGIS] Flow escalated."

      RUNTIME_STATE="ESCALATED"

      ;;

    COMPLETE)

      echo "[AEGIS] Flow completed."

      RUNTIME_STATE="COMPLETE"

      ;;

    *)

      fail "Invalid runtime status: $STATUS"

      ;;

  esac

done

# =========================================================
# FINAL STATE
# =========================================================

echo ""
echo "================================================="
echo "[AEGIS] FINAL STATE: $RUNTIME_STATE"
echo "================================================="
echo ""

exit 0