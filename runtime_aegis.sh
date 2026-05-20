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
# - reads explicit terminal state;
# - routes deterministic transitions.
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
  echo "[AEGIS] Forcing epistemic amnesia..."

  # Destroy conversational continuity
  rm -f .aider.chat.history.md

  # Destroy temporary operational state
  rm -rf .aider.tmp

  # Destroy repo-map latent bias
  rm -f .aider.tags.cache.*
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

  # -------------------------------------------------------
  # MODE EXECUTION CONTRACT
  #
  # Each mode MUST generate:
  #
  # {
  #   "status": "RUNNING|ESCALATED|COMPLETE"
  # }
  #
  # Runtime does not interpret cognition.
  # Runtime only routes deterministic state transitions.
  #
  # -------------------------------------------------------

  MODE_FILE=".skills/${mode_name}.md"

  if [[ ! -f "$MODE_FILE" ]]; then
    fail "Missing mode definition: $MODE_FILE"
  fi

  "./scripts/execute_mode.sh" "$MODE_FILE"

  if [[ ! -f "$RESULT_FILE" ]]; then
    fail "Mode did not produce result.json"
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
      # EPISTEMIC STATE RESET
      #
      # Prevent hidden cognitive continuity between modes.
      #
      # Each mode must execute with isolated cognition.
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
