#!/usr/bin/env bash

set -euo pipefail

# =========================================================
# AEGIS RUNTIME
# =========================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

RUNTIME_DIR="$ROOT_DIR/.harness/runtime"
SESSION_TASK="$RUNTIME_DIR/active_task.md"
LAST_GOOD_STATE="$RUNTIME_DIR/last_good_active_task.md"
ACTIVE_TASK_TEMPLATE="$ROOT_DIR/docs/active_task.template.md"

MODES=(
  "mode_0_discovery"
)

CURRENT_WORKTREE=""

cleanup() {
  if [[ -n "$CURRENT_WORKTREE" ]] && [[ -d "$CURRENT_WORKTREE" ]]; then
    cd "$ROOT_DIR" >/dev/null 2>&1 || true
    git worktree remove "$CURRENT_WORKTREE" --force >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

fail() {
  echo "[AEGIS RUNTIME] ERROR: $1"
  exit 1
}

init_session_state() {
  [[ -f "$ACTIVE_TASK_TEMPLATE" ]] || fail "Missing active_task.template.md"

  mkdir -p "$RUNTIME_DIR"
  cp "$ACTIVE_TASK_TEMPLATE" "$SESSION_TASK"
  cp "$SESSION_TASK" "$LAST_GOOD_STATE"
}

prepare_worktree() {
  local mode_name="$1"
  CURRENT_WORKTREE="/tmp/aegis-${mode_name}"

  git worktree add --detach "$CURRENT_WORKTREE" >/dev/null
  mkdir -p "$CURRENT_WORKTREE/docs"
  cp "$SESSION_TASK" "$CURRENT_WORKTREE/docs/active_task.md"
}

sync_back_session_state() {
  local mode_worktree="$1"

  if [[ -f "$mode_worktree/docs/active_task.md" ]]; then
    cp "$mode_worktree/docs/active_task.md" "$SESSION_TASK"
    cp "$SESSION_TASK" "$LAST_GOOD_STATE"
  fi
}

run_mode() {
  local mode_name="$1"

  echo
  echo "================================================="
  echo "[AEGIS] Executing: $mode_name"
  echo "================================================="
  echo

  prepare_worktree "$mode_name"

  (
    cd "$CURRENT_WORKTREE"
    bash "$ROOT_DIR/scripts/execute_mode.sh" ".skills/${mode_name}.md"
  ) || {
    fail "Mechanical mode execution failure"
  }

  sync_back_session_state "$CURRENT_WORKTREE"

  git worktree remove "$CURRENT_WORKTREE" --force >/dev/null
  CURRENT_WORKTREE=""

  echo
  echo "[AEGIS] Mode completed successfully."
  echo
}

main() {
  rm -rf /tmp/aegis-*
  rm -rf "$RUNTIME_DIR"
  init_session_state

  for MODE in "${MODES[@]}"; do
    run_mode "$MODE"
  done

  echo
  echo "================================================="
  echo "[AEGIS] Runtime execution completed."
  echo "================================================="
  echo
}

main "$@"