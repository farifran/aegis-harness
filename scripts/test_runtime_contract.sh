#!/usr/bin/env bash

set -Eeuo pipefail

readonly AEGIS_TEST_ROOT="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
)"

cd "${AEGIS_TEST_ROOT}"

fail() {
  echo "[AEGIS][TEST][FATAL] $*" >&2
  exit 1
}

assert_invalid_handover_schema() {
  local output
  local status

  set +e
  output="$({
    bash scripts/capabilities/runtime/read_epistemic_handover.sh
  } 2>/dev/null)"
  status=$?
  set -e

  [[ "${status}" -ne 0 ]] || fail "legacy_handover_schema_still_accepted"

  printf '%s\n' "${output}" | jq -e '
    .success == false
    and .capability == "runtime.read_epistemic_handover"
    and .error.type == "invalid_epistemic_handover_schema"
  ' >/dev/null || fail "unexpected_invalid_handover_error"
}

assert_runtime_context_error() {
  local capability="$1"
  local required_var="$2"
  local script_path="$3"

  local output
  local status

  set +e
  output="$({
    env \
      -u AEGIS_TARGET_SYSTEM_PROFILE_FILE \
      -u AEGIS_EPISTEMIC_HANDOVER_FILE \
      bash "${script_path}"
  } 2>/dev/null)"
  status=$?
  set -e

  [[ "${status}" -ne 0 ]] || fail "expected_runtime_context_failure: ${capability}"

  printf '%s\n' "${output}" | jq -e \
    --arg capability "${capability}" \
    --arg required_var "${required_var}" \
    '
      .success == false
      and .capability == $capability
      and .error.type == "runtime_context_not_initialized"
      and .error.required == [$required_var]
    ' >/dev/null || fail "unexpected_runtime_context_error: ${capability}"
}

assert_no_forbidden_patterns() {
  local file_path="$1"

  grep -Eq 'target_system_profile\.yml|epistemic_handover\.json' "${file_path}" \
    && fail "hardcoded_runtime_fallback_detected: ${file_path}"

  grep -Eq '\b(find|locate|realpath)\b' "${file_path}" \
    && fail "runtime_context_autodiscovery_detected: ${file_path}"
}

TMP_TEST_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "${TMP_TEST_DIR}" >/dev/null 2>&1 || true
}

trap cleanup EXIT

assert_runtime_context_error \
  "runtime.read_target_system_profile" \
  "AEGIS_TARGET_SYSTEM_PROFILE_FILE" \
  scripts/capabilities/runtime/read_target_system_profile.sh

assert_runtime_context_error \
  "runtime.read_epistemic_handover" \
  "AEGIS_EPISTEMIC_HANDOVER_FILE" \
  scripts/capabilities/runtime/read_epistemic_handover.sh

assert_no_forbidden_patterns scripts/capabilities/runtime/read_target_system_profile.sh
assert_no_forbidden_patterns scripts/capabilities/runtime/read_epistemic_handover.sh

source ".harness/config.sh"

export AEGIS_EXECUTION_ID="runtime-contract-harness"
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

printf '%s\n' "$(bash scripts/capabilities/runtime/read_target_system_profile.sh)" \
  | jq -e '.success == true and .error == null' >/dev/null \
  || fail "runtime_bound_profile_failed_with_context"

printf '%s\n' "$(bash scripts/capabilities/runtime/read_epistemic_handover.sh)" \
  | jq -e '.success == true and .error == null and .payload.handover.epistemic_state.next_attention_targets == [] and .payload.handover.epistemic_state.attention_scope == "none" and .payload.handover.epistemic_state.attention_reason == "no active attention" and .payload.handover.artifact_snapshot == null' >/dev/null \
  || fail "runtime_bound_handover_failed_with_context"

jq -n \
  '{
    artifact_snapshot: null,
    epistemic_state: {
      incomplete_observations: [],
      uninspected_areas: [],
      insufficient_evidence: [],
      observed_limitations: []
    }
  }' > "${AEGIS_EPISTEMIC_HANDOVER_FILE}"

assert_invalid_handover_schema

echo "[AEGIS][TEST] runtime contract harness passed"