#!/usr/bin/env bash

set -Eeuo pipefail

readonly AEGIS_TEST_ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
)"

cd "${AEGIS_TEST_ROOT}"

source ".harness/config.sh"

fail() {
  echo "[AEGIS][TEST][FATAL] $*" >&2
  exit 1
}

TMP_TEST_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_TEST_DIR}" >/dev/null 2>&1 || true
}

trap cleanup EXIT

export AEGIS_EXECUTION_ID="capability-harness"
export AEGIS_EXECUTION_TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

export AEGIS_TARGET_SYSTEM_PROFILE_FILE="${TMP_TEST_DIR}/target_system_profile.yml"
export AEGIS_EPISTEMIC_HANDOVER_FILE="${TMP_TEST_DIR}/epistemic_handover.json"

cat > "${AEGIS_TARGET_SYSTEM_PROFILE_FILE}" <<'EOF'
characteristics: {}
constraints: {}
preferences: {}
EOF

jq -n \
  '{
    artifact_snapshot: null,
    epistemic_state: {
      next_attention_targets: [],
      attention_scope: "none",
      attention_reason: "no active attention"
    }
  }' > "${AEGIS_EPISTEMIC_HANDOVER_FILE}"

assert_capability_success() {
  local capability="$1"
  local filter="$2"
  shift 2

  local output
  output="$(bash "$@")" || fail "capability_execution_failed: ${capability}"

  printf '%s\n' "${output}" | jq -e "${filter}" >/dev/null \
    || fail "unexpected_capability_output: ${capability}"
}

assert_capability_success \
  "filesystem.read" \
  '.success == true and .capability == "filesystem.read" and .payload.target == "AGENTS.md"' \
  scripts/capabilities/filesystem/read_file.sh \
  AGENTS.md

assert_capability_success \
  "filesystem.list_tree" \
  '.success == true and .capability == "filesystem.list_tree" and .error == null' \
  scripts/capabilities/filesystem/list_tree.sh \
  .

assert_capability_success \
  "filesystem.search_symbol" \
  '.success == true and .capability == "filesystem.search_symbol" and .error == null' \
  scripts/capabilities/filesystem/search_symbol.sh \
  AEGIS

assert_capability_success \
  "git.status" \
  '.success == true and .capability == "git.status" and .error == null' \
  scripts/capabilities/git/git_status.sh

assert_capability_success \
  "git.diff" \
  '.success == true and .capability == "git.diff" and .error == null' \
  scripts/capabilities/git/git_diff.sh

profile_output="$(bash scripts/capabilities/runtime/read_target_system_profile.sh)" \
  || fail "capability_execution_failed: runtime.read_target_system_profile"

printf '%s\n' "${profile_output}" | jq -e \
  --arg path "${AEGIS_TARGET_SYSTEM_PROFILE_FILE}" \
  '.success == true and .capability == "runtime.read_target_system_profile" and .payload.path == $path and .payload.present == true' \
  >/dev/null || fail "unexpected_capability_output: runtime.read_target_system_profile"

handover_output="$(bash scripts/capabilities/runtime/read_epistemic_handover.sh)" \
  || fail "capability_execution_failed: runtime.read_epistemic_handover"

printf '%s\n' "${handover_output}" | jq -e \
  --arg path "${AEGIS_EPISTEMIC_HANDOVER_FILE}" \
  '.success == true and .capability == "runtime.read_epistemic_handover" and .payload.path == $path and .payload.handover.epistemic_state.next_attention_targets == [] and .payload.handover.epistemic_state.attention_scope == "none" and .payload.handover.epistemic_state.attention_reason == "no active attention" and .payload.handover.artifact_snapshot == null' \
  >/dev/null || fail "unexpected_capability_output: runtime.read_epistemic_handover"

echo "[AEGIS][TEST] capability harness passed"