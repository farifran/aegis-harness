#!/usr/bin/env bash

source ~/.bashrc
set -euo pipefail

ROOT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)"

source "$ROOT_DIR/.harness/config.sh"

RUNTIME_DIR="$ROOT_DIR/.harness/runtime"

ACTIVE_TASK="$RUNTIME_DIR/active_task.md"
LAST_GOOD_TASK="$RUNTIME_DIR/last_good_active_task.md"

WORKTREE_BASE="$ROOT_DIR/.harness/worktrees"

CURRENT_WORKTREE_PATH=""

fail() {
  echo
  echo "[AEGIS] $1" >&2
  echo
  exit 1
}

cleanup_worktree() {
  local path="${1:-}"

  [[ -n "$path" ]] || return 0

  rm -rf "$path/.aider.tags.cache.v4" >/dev/null 2>&1 || true
  rm -f "$path/.aider.chat.history.md" >/dev/null 2>&1 || true
  rm -f "$path/.aider.input.history" >/dev/null 2>&1 || true

  git worktree remove \
    --force \
    "$path" \
    >/dev/null 2>&1 || true
}

cleanup_global() {
  rm -rf "$WORKTREE_BASE" >/dev/null 2>&1 || true

  rm -rf "$ROOT_DIR/.aider.tags.cache.v4" >/dev/null 2>&1 || true

  rm -f "$ROOT_DIR/.aider.chat.history.md" >/dev/null 2>&1 || true
  rm -f "$ROOT_DIR/.aider.input.history" >/dev/null 2>&1 || true

  rm -f "$HOME/.aider.chat.history.md" >/dev/null 2>&1 || true
  rm -f "$HOME/.aider.input.history" >/dev/null 2>&1 || true

  git worktree prune >/dev/null 2>&1 || true
}

cleanup_all() {
  cleanup_worktree "${CURRENT_WORKTREE_PATH:-}"
  cleanup_global
}

trap cleanup_all EXIT INT TERM

mkdir -p "$WORKTREE_BASE"

git worktree prune

rm -f "$ACTIVE_TASK"
rm -f "$LAST_GOOD_TASK"

for MODE in "${AEGIS_ANALYSIS_MODES[@]}"
do
  echo
  echo "================================================="
  echo "[AEGIS] Executing: $MODE"
  echo "================================================="
  echo

  CURRENT_WORKTREE_PATH="$WORKTREE_BASE/$MODE"

  rm -rf "$CURRENT_WORKTREE_PATH"

  git worktree add \
    --force \
    --detach \
    "$CURRENT_WORKTREE_PATH" \
    HEAD

  pushd "$CURRENT_WORKTREE_PATH" >/dev/null

  chmod +x scripts/execute_mode.sh

  set +e

  ACTIVE_TASK_ARG=".harness/runtime/active_task.md"

  if [[ "$MODE" == "discovery" ]]
  then
    ACTIVE_TASK_ARG=""
  fi

  OUTPUT="$(
    bash scripts/execute_mode.sh \
      ".skills/$MODE.md" \
      "$MODE" \
      "$ACTIVE_TASK_ARG" \
      2>&1
  )"

  EXIT_CODE=$?

  set -e

  popd >/dev/null

  printf '%s\n' "$OUTPUT"

  if [[ "$EXIT_CODE" -ne 0 ]]
  then
    echo
    echo "[AEGIS] Mode failed: $MODE"
    echo

    exit 1
  fi

  if [[ -f \
    "$CURRENT_WORKTREE_PATH/.harness/runtime/active_task.md" ]]
  then
    cp \
      "$CURRENT_WORKTREE_PATH/.harness/runtime/active_task.md" \
      "$ACTIVE_TASK"

    cp \
      "$ACTIVE_TASK" \
      "$LAST_GOOD_TASK"
  fi

  cleanup_worktree "$CURRENT_WORKTREE_PATH"

  CURRENT_WORKTREE_PATH=""

  echo
  echo "[AEGIS] Mode completed successfully."
  echo
done

echo
echo "================================================="
echo "[AEGIS] Runtime completed successfully."
echo "================================================="
echo