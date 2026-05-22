#!/usr/bin/env bash

# =========================================================
# AEGIS RUNTIME — DETERMINISTIC CONTROLLER
# =========================================================

set -euo pipefail

# =========================================================
# MODES
# =========================================================

MODES=(
  "mode_0_discovery"
)

# =========================================================
# HELPERS
# =========================================================

fail() {
  echo "[AEGIS RUNTIME] ERROR: $1"
  exit 1
}

read_status() {

  local result_file=".harness/runtime/result.json"

  jq -r '.status' "$result_file"
}

# =========================================================
# SANDBOX
# =========================================================

create_sandbox() {

  SANDBOX_PATH="/tmp/aegis-$$"

  git worktree add --detach "$SANDBOX_PATH" >/dev/null
}

destroy_sandbox() {

  git worktree remove "$SANDBOX_PATH" \
    --force >/dev/null 2>&1 || true
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

  create_sandbox

  pushd "$SANDBOX_PATH" >/dev/null

  if ! "./scripts/execute_mode.sh" \
    ".skills/${mode_name}.md"; then

    popd >/dev/null

    destroy_sandbox

    fail "Mechanical mode execution failure"
  fi

  STATUS="$(read_status)"

  popd >/dev/null

  destroy_sandbox

  case "$STATUS" in

    RUNNING|COMPLETE)

      echo ""
      echo "[AEGIS] Mode completed successfully."
      echo ""

      ;;

    ESCALATED)

      fail "Flow escalated"

      ;;

    *)

      fail "Invalid runtime status: $STATUS"

      ;;

  esac
}

# =========================================================
# MAIN
# =========================================================

for MODE in "${MODES[@]}"; do
  execute_mode "$MODE"
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