#!/usr/bin/env bash

source ~/.bashrc
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

mkdir -p "$WORKTREE_BASE"

git worktree prune

# =========================================================
# RUNTIME STATE RESET
# =========================================================

rm -f "$ACTIVE_TASK"
rm -f "$LAST_GOOD_TASK"

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
    --force \
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

  # =======================================================
  # AIDER RESIDUE CLEANUP
  # =======================================================

  rm -rf "$WORKTREE_PATH/.aider.tags.cache.v4"

  rm -f "$WORKTREE_PATH/.aider.chat.history.md"
  rm -f "$WORKTREE_PATH/.aider.input.history"

  printf '%s\n' "$OUTPUT"

  # =======================================================
  # FAILURE DETECTION
  # =======================================================

  if [[ "$EXIT_CODE" -ne 0 ]]
  then

    echo
    echo "[AEGIS] Mode failed: $MODE"
    echo

    git worktree remove \
      --force \
      "$WORKTREE_PATH" \
      >/dev/null 2>&1 || true

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
    "$WORKTREE_PATH" \
    >/dev/null 2>&1 || true

  echo
  echo "[AEGIS] Mode completed successfully."
  echo

done

# =========================================================
# GLOBAL CLEANUP
# =========================================================

rm -rf "$WORKTREE_BASE"
rm -rf "$ROOT_DIR/.aider.tags.cache.v4"
rm -f "$ROOT_DIR/.aider.chat.history.md"
rm -f "$ROOT_DIR/.aider.input.history"
rm -f "$HOME/.aider.chat.history.md"
rm -f "$HOME/.aider.input.history"
echo
echo "================================================="
echo "[AEGIS] Runtime completed successfully."
echo "================================================="
echo