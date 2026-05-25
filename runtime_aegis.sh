#!/usr/bin/env bash

set -euo pipefail

# =========================================================
# AEGIS RUNTIME
# =========================================================

ROOT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
)"

RUNTIME_DIR="$ROOT_DIR/.harness/runtime"

SESSION_ACTIVE_TASK="$RUNTIME_DIR/active_task.md"

LAST_GOOD_STATE="$RUNTIME_DIR/last_good_active_task.md"

ACTIVE_TASK_TEMPLATE="$ROOT_DIR/docs/active_task.template.md"

CURRENT_WORKTREE=""

MODES=(
  "discovery"
  "forensics"
  "repair"
  "optimize"
  "validation"
  "adversarial"
)

# =========================================================
# FAILURE
# =========================================================

fail() {
  echo
  echo "[AEGIS RUNTIME] ERROR: $1"
  echo
  exit 1
}

# =========================================================
# ENVIRONMENT VALIDATION
# =========================================================

validate_environment() {

  command -v aider >/dev/null 2>&1 \
    || fail "Missing aider."

  command -v jq >/dev/null 2>&1 \
    || fail "Missing jq."

  command -v timeout >/dev/null 2>&1 \
    || fail "Missing timeout."

  [[ -n "${OPENAI_API_KEY:-}" ]] \
    || fail "Missing OPENAI_API_KEY."

  [[ -n "${OPENAI_API_BASE:-}" ]] \
    || fail "Missing OPENAI_API_BASE."
}

# =========================================================
# CLEANUP
# =========================================================

cleanup() {

  if [[ -n "${CURRENT_WORKTREE:-}" ]] &&
     [[ -d "$CURRENT_WORKTREE" ]]
  then
    cd "$ROOT_DIR" >/dev/null 2>&1 || true

    git worktree remove \
      "$CURRENT_WORKTREE" \
      --force \
      >/dev/null 2>&1 || true
  fi
}

trap cleanup EXIT

# =========================================================
# MODE CAPABILITY MODEL
# =========================================================

is_mutation_mode() {

  local mode="$1"

  case "$mode" in
    repair|optimize)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

# =========================================================
# INITIALIZE RUNTIME STATE
# =========================================================

initialize_runtime_state() {

  rm -rf /tmp/aegis-*
  rm -rf "$RUNTIME_DIR"

  mkdir -p "$RUNTIME_DIR"

  cp "$ACTIVE_TASK_TEMPLATE" \
     "$SESSION_ACTIVE_TASK"

  cp "$SESSION_ACTIVE_TASK" \
     "$LAST_GOOD_STATE"
}

# =========================================================
# CREATE SANDBOX
# =========================================================

create_sandbox() {

  local mode="$1"

  CURRENT_WORKTREE="/tmp/aegis-$mode"

  git worktree add \
    --detach \
    "$CURRENT_WORKTREE" \
    >/dev/null

  mkdir -p \
    "$CURRENT_WORKTREE/.harness/runtime"

  cp "$SESSION_ACTIVE_TASK" \
     "$CURRENT_WORKTREE/.harness/runtime/active_task.md"
}

# =========================================================
# ALLOWED MUTATION SURFACES
# =========================================================

build_allowed_mutations() {

  local mode="$1"

  if is_mutation_mode "$mode"
  then
    cat <<EOF
src/
tests/
EOF
  fi
}

# =========================================================
# GIT DIFF VALIDATION
# =========================================================

validate_mutations() {

  local mode="$1"

  local changed_files

  changed_files="$(
    cd "$CURRENT_WORKTREE"
    git diff --name-only
  )"

  # -------------------------------------------------------
  # HARD CONTAINMENT MODES
  # -------------------------------------------------------

  if ! is_mutation_mode "$mode"
  then

    if [[ -n "$changed_files" ]]
    then
      echo
      echo "[AEGIS] Unauthorized mutation surface detected."
      echo
      echo "$changed_files"
      echo

      fail "Hard containment violation"
    fi

    return
  fi

  # -------------------------------------------------------
  # MUTATION-AUTHORIZED MODES
  # -------------------------------------------------------

  local allowed

  allowed="$(build_allowed_mutations "$mode")"

  while read -r file
  do
    [[ -z "$file" ]] && continue

    local authorized=false

    while read -r allowed_path
    do
      [[ -z "$allowed_path" ]] && continue

      if [[ "$file" == "$allowed_path"* ]]
      then
        authorized=true
        break
      fi

    done <<< "$allowed"

    if [[ "$authorized" == false ]]
    then
      echo
      echo "[AEGIS] Unauthorized mutation surface detected."
      echo
      echo "Unauthorized file:"
      echo "$file"
      echo

      fail "Mutation boundary violation"
    fi

  done <<< "$changed_files"
}

# =========================================================
# PERSIST CONTINUITY
# =========================================================

persist_continuity() {

  local mode="$1"
  local artifact="$2"

  {
    echo
    echo "---"
    echo
    echo "## Mode Execution — $mode"
    echo
    echo '```json'
    echo "$artifact"
    echo '```'
  } >> "$SESSION_ACTIVE_TASK"

  cp "$SESSION_ACTIVE_TASK" \
     "$LAST_GOOD_STATE"
}

# =========================================================
# EXECUTE MODE
# =========================================================

execute_mode() {

  local mode="$1"

  echo
  echo "================================================="
  echo "[AEGIS] Executing: $mode"
  echo "================================================="
  echo

  create_sandbox "$mode"

  local artifact

  if is_mutation_mode "$mode"
  then

    artifact="$(
      cd "$CURRENT_WORKTREE"

      bash "$ROOT_DIR/scripts/execute_mode.sh" \
        ".skills/${mode}.md" \
        "$mode" \
        ".harness/runtime/active_task.md" \
        "src/,tests/"
    )"

  else

    artifact="$(
      cd "$CURRENT_WORKTREE"

      bash "$ROOT_DIR/scripts/execute_mode.sh" \
        ".skills/${mode}.md" \
        "$mode" \
        ".harness/runtime/active_task.md"
    )"

  fi

  validate_mutations "$mode"

  persist_continuity \
    "$mode" \
    "$artifact"

  git worktree remove \
    "$CURRENT_WORKTREE" \
    --force \
    >/dev/null

  CURRENT_WORKTREE=""

  echo
  echo "[AEGIS] Mode completed successfully."
  echo
}

# =========================================================
# MAIN
# =========================================================

main() {

  validate_environment

  [[ -f "$ACTIVE_TASK_TEMPLATE" ]] \
    || fail "Missing active_task.template.md"

  initialize_runtime_state

  for MODE in "${MODES[@]}"
  do
    execute_mode "$MODE"
  done

  echo
  echo "================================================="
  echo "[AEGIS] Runtime execution completed."
  echo "================================================="
  echo
}

main "$@"