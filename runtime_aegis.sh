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
  rm -f "$HOME/.aider.chat.history.md" >/dev/null 2>&1 || true
  rm -f "$HOME/.aider.input.history" >/dev/null 2>&1 || true

  git worktree prune >/dev/null 2>&1 || true
}

cleanup_all() {
  cleanup_worktree "${CURRENT_WORKTREE_PATH:-}"
  cleanup_global
}

trap cleanup_all EXIT INT TERM

validate_runtime_consistency() {
  local required_files=(
    "$ROOT_DIR/AGENTS.md"
    "$ROOT_DIR/.harness/config.sh"
    "$ROOT_DIR/scripts/execute_mode.sh"
    "$ROOT_DIR/.harness/architecture_graph.json"
    "$ROOT_DIR/.skills/discovery.md"
    "$ROOT_DIR/.skills/forensics.md"
    "$ROOT_DIR/.skills/validation.md"
    "$ROOT_DIR/.skills/adversarial.md"
    "$ROOT_DIR/.skills/repair.md"
    "$ROOT_DIR/.skills/optimize.md"
  )

  local file
  for file in "${required_files[@]}"
  do
    [[ -f "$file" ]] || fail "Missing runtime file: ${file#"$ROOT_DIR/"}"
  done

  [[ -n "${AEGIS_MODEL:-}" ]] \
    || fail "Invalid config: missing model."

  [[ -n "${AEGIS_EDIT_FORMAT:-}" ]] \
    || fail "Invalid config: missing edit format."

  [[ "${AEGIS_EXECUTION_TIMEOUT:-}" =~ ^[0-9]+$ ]] \
    || fail "Invalid config: execution timeout must be numeric."

  [[ "${AEGIS_EXECUTION_TIMEOUT:-0}" -gt 0 ]] \
    || fail "Invalid config: execution timeout must be greater than zero."

  [[ -n "${AEGIS_ANALYSIS_MODES[*]:-}" ]] \
    || fail "Invalid config: missing analysis mode list."

  [[ -n "${AEGIS_MUTATION_MODES[*]:-}" ]] \
    || fail "Invalid config: missing mutation mode list."

  declare -A seen_modes=()
  local mode authority_var authority file_path

  for mode in "${AEGIS_ANALYSIS_MODES[@]}" "${AEGIS_MUTATION_MODES[@]}"
  do
    [[ -n "$mode" ]] || fail "Invalid config: empty mode entry."

    [[ -z "${seen_modes[$mode]:-}" ]] \
      || fail "Invalid config: duplicate mode declaration: $mode"

    seen_modes["$mode"]=1

    file_path="$ROOT_DIR/.skills/$mode.md"
    [[ -f "$file_path" ]] \
      || fail "Missing mode contract: .skills/$mode.md"

    authority_var="AEGIS_MODE_EDIT_AUTHORITY_${mode}"
    authority="${!authority_var:-}"

    [[ -n "$authority" ]] \
      || fail "Invalid config: missing edit authority for mode: $mode"

    case "$mode" in
      "${AEGIS_ANALYSIS_MODES[@]}")
        [[ "$authority" == "false" ]] \
          || fail "Invalid config: analysis mode must not have edit authority: $mode"
        ;;
      "${AEGIS_MUTATION_MODES[@]}")
        [[ "$authority" == "true" ]] \
          || fail "Invalid config: mutation mode must have edit authority: $mode"
        ;;
    esac
  done

  grep -q 'AEGIS_ARTIFACT_BEGIN' "$ROOT_DIR/scripts/execute_mode.sh" \
    || fail "Invalid executor: missing artifact sentinel handling."

  grep -q 'Execute immediately.' "$ROOT_DIR/scripts/execute_mode.sh" \
    || fail "Invalid executor: missing execution coercion."
}

mkdir -p "$WORKTREE_BASE"
mkdir -p "$RUNTIME_DIR"

validate_runtime_consistency
git worktree prune

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
    cp "$ACTIVE_TASK" "$CURRENT_WORKTREE_PATH/.harness/runtime/active_task.md"
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

Continue runtime analysis using currently observable repository and runtime state.
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