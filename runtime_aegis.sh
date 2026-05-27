#!/usr/bin/env bash

source ~/.bashrc
set -euo pipefail

ROOT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)"

source "$ROOT_DIR/.harness/config.sh"

RUNTIME_DIR="$ROOT_DIR/.harness/runtime"
ACTIVE_TASK="$RUNTIME_DIR/active_task.md"
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

  git worktree remove --force "$path" >/dev/null 2>&1 || true
}

cleanup_global() {
  rm -rf "$WORKTREE_BASE" >/dev/null 2>&1 || true

  rm -rf "$ROOT_DIR/.aider.tags.cache.v4" >/dev/null 2>&1 || true
  rm -f "$ROOT_DIR/.aider.chat.history.md" >/dev/null 2>&1 || true
  rm -f "$ROOT_DIR/.aider.input.history" >/dev/null 2>&1 || true

  git worktree prune >/dev/null 2>&1 || true
}

cleanup_all() {
  cleanup_worktree "${CURRENT_WORKTREE_PATH:-}"
  cleanup_global
}

trap cleanup_all EXIT INT TERM

validate_runtime_topology() {
  local required_files=(
    "$ROOT_DIR/AGENTS.md"
    "$ROOT_DIR/.harness/config.sh"
    "$ROOT_DIR/scripts/execute_mode.sh"
    "$ROOT_DIR/.harness/architecture_graph.json"
  )

  local file

  for file in "${required_files[@]}"
  do
    [[ -f "$file" ]] \
      || fail "Missing runtime file: ${file#"$ROOT_DIR/"}"
  done

  [[ -n "${AEGIS_MODEL:-}" ]] \
    || fail "Missing AEGIS_MODEL."

  [[ -n "${AEGIS_EDIT_FORMAT:-}" ]] \
    || fail "Missing AEGIS_EDIT_FORMAT."

  [[ -n "${AEGIS_EXECUTION_TIMEOUT:-}" ]] \
    || fail "Missing AEGIS_EXECUTION_TIMEOUT."

  [[ "${AEGIS_EXECUTION_TIMEOUT}" =~ ^[0-9]+$ ]] \
    || fail "Invalid execution timeout."

  grep -q 'Execute immediately.' \
    "$ROOT_DIR/scripts/execute_mode.sh" \
    || fail "Invalid executor: missing coercion marker."

  grep -q 'jq empty' \
    "$ROOT_DIR/scripts/execute_mode.sh" \
    || fail "Invalid executor: missing JSON validation."
}

mkdir -p "$WORKTREE_BASE"
mkdir -p "$RUNTIME_DIR"

validate_runtime_topology

rm -f "$ACTIVE_TASK"

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

  if [[ -f "$ACTIVE_TASK" ]]
  then
    mkdir -p "$CURRENT_WORKTREE_PATH/.harness/runtime"

    cp \
      "$ACTIVE_TASK" \
      "$CURRENT_WORKTREE_PATH/.harness/runtime/active_task.md"
  fi

  pushd "$CURRENT_WORKTREE_PATH" >/dev/null

  chmod +x scripts/execute_mode.sh

  ACTIVE_TASK_ARG=""

  if [[ "$MODE" != "discovery" ]]
  then
    ACTIVE_TASK_ARG=".harness/runtime/active_task.md"
  fi

  set +e

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

  if [[ "$MODE" == "discovery" ]]
  then
    cat > "$ACTIVE_TASK" <<EOF
# ACTIVE TASK

Discovery completed successfully.
EOF
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