#!/usr/bin/env bash

# =========================================================
# AEGIS EXECUTOR — MODE EXECUTION WRAPPER
# =========================================================
#
# This script:
# - executes bounded cognition modes;
# - injects explicit governance context;
# - injects explicit epistemic continuity;
# - validates mechanical execution integrity.
#
# It does NOT:
# - interpret reasoning;
# - validate cognition quality;
# - analyze semantic correctness;
# - orchestrate runtime transitions.
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

EPISTEMIC_STATE_FILE=".harness/state/epistemic_state.json"

RESULT_FILE=".harness/runtime/result.json"

# =========================================================
# CONTEXT VALIDATION
# =========================================================

if [[ ! -f "$AGENTS_FILE" ]]; then
  echo "[AEGIS] Missing AGENTS.md"
  exit 1
fi

if [[ ! -f "$ACTIVE_TASK_FILE" ]]; then
  echo "[AEGIS] Missing active_task.md"
  exit 1
fi

if [[ ! -f "$EPISTEMIC_STATE_FILE" ]]; then
  echo "[AEGIS] Missing epistemic_state.json"
  exit 1
fi

# =========================================================
# EXECUTION
# =========================================================

echo ""
echo "[AEGIS] Executing mode file: $MODE_FILE"
echo ""

# ---------------------------------------------------------
# EXPLICIT CONTEXT GOVERNANCE
#
# Runtime explicitly governs:
# - constitutional context;
# - operational epistemic discipline;
# - bounded continuity state.
#
# Context ownership remains externalized from the executor.
# ---------------------------------------------------------

if ! aider \
  --yes-always \
  --read "$AGENTS_FILE" \
  --read "$ACTIVE_TASK_FILE" \
  --read "$EPISTEMIC_STATE_FILE" \
  --message-file "$MODE_FILE"; then

  echo ""
  echo "[AEGIS] Mechanical execution failure detected."
  echo ""

  exit 1
fi

# =========================================================
# RUNTIME ARTIFACT VALIDATION
# =========================================================

if [[ ! -f "$RESULT_FILE" ]]; then
  echo ""
  echo "[AEGIS] Missing runtime result artifact."
  echo ""

  exit 1
fi

# =========================================================
# SUCCESS
# =========================================================

echo ""
echo "[AEGIS] Mechanical execution integrity verified."
echo ""

exit 0