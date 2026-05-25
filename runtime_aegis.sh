#!/usr/bin/env bash

set -euo pipefail

# =========================================================
# AEGIS RUNTIME
# =========================================================

ROOT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)"

RUNTIME_DIR="$ROOT_DIR/.harness/runtime"

ACTIVE_TASK="$RUNTIME_DIR/active_task.md"

LAST_GOOD_TASK="$RUNTIME_DIR/last_good_active_task.md"

WORKTREE_BASE="$ROOT_DIR/.harness/worktrees"

MODES=(
  discovery
  forensics
  validation
  adversarial
)

# =========================================================
# FAILURE
# =========================================================

fail() {

  echo
  echo "[AEGIS] $1" >&2
  echo

  exit 1
}

# =========================================================
# VALIDATION
# =========================================================

[[ -f "$ACTIVE_TASK" ]] \
  || fail "Missing runtime active_task.md"

mkdir -p "$WORKTREE_BASE"

# =========================================================
# EXECUTION LOOP
# =========================================================

for MODE in "${MODES[@]}"
do

  echo
  echo "================================================="
  echo "[AEGIS] Executing: $MODE"
  echo "================================================="
  echo

  WORKTREE_PATH="$WORKTREE_BASE/$MODE"

  rm -rf "$WORKTREE_PATH"

  git worktree add \
    --detach \
    "$WORKTREE_PATH" \
    HEAD

  pushd "$WORKTREE_PATH" \
    >/dev/null

  chmod +x scripts/execute_mode.sh

  set +e

  OUTPUT="$(
    bash scripts/execute_mode.sh \
      ".skills/$MODE.md" \
      "$MODE" \
      ".harness/runtime/active_task.md" \
      2>&1
  )"

  EXIT_CODE=$?

  set -e

  popd >/dev/null

  echo "$OUTPUT"

  if [[ "$EXIT_CODE" -ne 0 ]]
  then

    echo
    echo "[AEGIS] Mode failed: $MODE"
    echo

    git worktree remove \
      --force \
      "$WORKTREE_PATH"

    exit 1
  fi

  # =======================================================
  # ACTIVE TASK PROMOTION
  # =======================================================

  if [[ -f \
    "$WORKTREE_PATH/.harness/runtime/active_task.md" ]]
  then

    cp \
      "$WORKTREE_PATH/.harness/runtime/active_task.md" \
      "$ACTIVE_TASK"

    cp \
      "$ACTIVE_TASK" \
      "$LAST_GOOD_TASK"
  fi

  # =======================================================
  # WORKTREE CLEANUP
  # =======================================================

  git worktree remove \
    --force \
    "$WORKTREE_PATH"

  echo
  echo "[AEGIS] Mode completed successfully."
  echo

done

echo
echo "================================================="
echo "[AEGIS] Runtime completed successfully."
echo "================================================="
echo