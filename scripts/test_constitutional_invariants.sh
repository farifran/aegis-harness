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

start_mock_provider() {
  MOCK_PROVIDER_PORT_FILE="$(mktemp)"
  MOCK_PROVIDER_LOG_FILE="$(mktemp)"

  python3 - "${MOCK_PROVIDER_PORT_FILE}" <<'PY' >"${MOCK_PROVIDER_LOG_FILE}" 2>&1 &
import http.server
import json
import re
import socketserver
import sys

PORT_FILE = sys.argv[1]
BEGIN = "AEGIS_ARTIFACT_BEGIN"
END = "AEGIS_ARTIFACT_END"
MODE_PATTERN = re.compile(r'"mode"\s*:\s*"(discovery|forensics|validation|adversarial)"')
SYSTEM_MODE_PATTERN = re.compile(r'Mode:\s*(discovery|forensics|validation|adversarial)')
PAYLOAD_PATTERN = re.compile(r'^--- PAYLOAD: ([^\n]+) ---$', re.MULTILINE)


class Handler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", "0"))
        raw_body = self.rfile.read(length)
        request = json.loads(raw_body.decode("utf-8") or "{}")

        mode = "discovery"
        payload_names = []

        for message in request.get("messages", []):
            content = message.get("content", "")
            manifest_match = MODE_PATTERN.search(content)
            if manifest_match:
                mode = manifest_match.group(1)
                break

            system_match = SYSTEM_MODE_PATTERN.search(content)
            if system_match:
                mode = system_match.group(1)

        for message in request.get("messages", []):
            payload_names.extend(PAYLOAD_PATTERN.findall(message.get("content", "")))

        artifact = {
            "mode": mode,
            "status": "ok",
            "summary": f"mock {mode} artifact",
            "observed_payloads": payload_names,
        }

        response = {
            "choices": [
                {
                    "message": {
                        "content": BEGIN + "\n" + json.dumps(artifact) + "\n" + END
                    }
                }
            ]
        }

        encoded = json.dumps(response).encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def log_message(self, format, *args):
        return


with socketserver.TCPServer(("127.0.0.1", 0), Handler) as server:
    with open(PORT_FILE, "w", encoding="utf-8") as handle:
        handle.write(str(server.server_address[1]))
    server.serve_forever()
PY

  MOCK_PROVIDER_PID="$!"

  while [[ ! -s "${MOCK_PROVIDER_PORT_FILE}" ]]; do
    kill -0 "${MOCK_PROVIDER_PID}" >/dev/null 2>&1 \
      || fail "mock_provider_failed_to_start"
  done

  MOCK_PROVIDER_PORT="$(cat "${MOCK_PROVIDER_PORT_FILE}")"

  export OPENAI_API_KEY="aegis-test-key"
  export OPENAI_API_BASE="http://127.0.0.1:${MOCK_PROVIDER_PORT}"
  export OPENAI_MODEL_READONLY_COGNITION="aegis-test-model"
  export AEGIS_PROVIDER_CONNECT_TIMEOUT=3
  export AEGIS_PROVIDER_RESPONSE_TIMEOUT=5
  export AEGIS_PROVIDER_MAX_RETRIES=1
  export AEGIS_PROVIDER_RETRY_DELAY=0
}

cleanup() {
  set +e

  if [[ -n "${MOCK_PROVIDER_PID:-}" ]]; then
    kill "${MOCK_PROVIDER_PID}" >/dev/null 2>&1 || true
    wait "${MOCK_PROVIDER_PID}" >/dev/null 2>&1 || true
  fi

  rm -f \
    "${MOCK_PROVIDER_PORT_FILE:-}" \
    "${MOCK_PROVIDER_LOG_FILE:-}" \
    >/dev/null 2>&1 || true

  rm -rf \
    "${AEGIS_CAPABILITY_ENV_DIR}" \
    "${AEGIS_CAPABILITY_PAYLOAD_DIR}" \
    ".harness/execution_surfaces/discovery" \
    ".harness/execution_surfaces/forensics" \
    ".harness/execution_surfaces/validation" \
    ".harness/execution_surfaces/adversarial" \
    >/dev/null 2>&1 || true
}

trap cleanup EXIT

array_contains() {
  local needle="$1"
  shift

  local item
  for item in "$@"; do
    [[ "${item}" == "${needle}" ]] && return 0
  done

  return 1
}

assert_constitutional_state_registry() {
  local duplicate_states

  duplicate_states="$({
    printf '%s\n' "${AEGIS_PROVEN_SURFACES[@]}"
    printf '%s\n' "${AEGIS_INTENDED_SURFACES[@]}"
    printf '%s\n' "${AEGIS_DEFERRED_SURFACES[@]}"
  } | sort | uniq -d)"

  [[ -z "${duplicate_states}" ]] \
    || fail "overlapping_constitutional_state_registry"

  array_contains "payload_provenance_tracking" "${AEGIS_PROVEN_SURFACES[@]}" \
    || fail "payload_provenance_tracking_not_proven"

  array_contains "readonly_execution_surface_elision" "${AEGIS_PROVEN_SURFACES[@]}" \
    || fail "readonly_execution_surface_elision_not_proven"

  array_contains "bounded_mutation_hardening" "${AEGIS_INTENDED_SURFACES[@]}" \
    || fail "bounded_mutation_hardening_not_intended"

  array_contains "advanced_capability_sandboxing" "${AEGIS_DEFERRED_SURFACES[@]}" \
    || fail "advanced_capability_sandboxing_not_deferred"
}

assert_executor_subprocess_isolation_contract() {

  grep -q 'env -i' scripts/execute_mode.sh \
    || fail "missing_sanitized_subprocess_environment"

  grep -q 'invoke_capability_handler()' scripts/execute_mode.sh \
    || fail "missing_capability_handler_isolation_helper"

  grep -q 'invoke_raw_substrate()' scripts/execute_mode.sh \
    || fail "missing_raw_substrate_isolation_helper"
}

assert_raw_substrate_isolation_contract() {

  grep -q 'prepare_isolated_substrate_workspace()' scripts/substrates/raw_llm.sh \
    || fail "missing_isolated_substrate_workspace_helper"

  grep -q 'cd "${AEGIS_SUBSTRATE_WORKSPACE}"' scripts/substrates/raw_llm.sh \
    || fail "missing_isolated_substrate_workspace_entry"

  grep -q 'normalize_selected_payload_paths' scripts/substrates/raw_llm.sh \
    || fail "missing_selected_payload_normalization"

  grep -q 'exposed_capability_payload_out_of_scope' scripts/substrates/raw_llm.sh \
    || fail "missing_payload_scope_guard"
}

assert_evidence_profiles_are_subset_of_envelopes() {
  local manifest

  manifest="$(
    bash scripts/capabilities/generate_manifest.sh
  )"

  printf '%s\n' "${manifest}" | jq -e '
    .modes
    | to_entries
    | all(
        ((.value.evidence_capabilities - (.value.capabilities | map(.capability))) | length) == 0
      )
  ' >/dev/null || fail "evidence_profile_outside_envelope"
}

assert_readonly_mode_has_no_execution_surface() {
  local mode="$1"
  local runtime_log_file
  local execution_surface_path="${AEGIS_EXECUTION_SURFACE_ROOT}/${mode}"

  runtime_log_file="$(mktemp)"

  rm -rf "${execution_surface_path}"

  AEGIS_RUNTIME_REMOVE_EXECUTION_SURFACE=false \
  bash runtime_aegis.sh "${mode}" >/dev/null 2>"${runtime_log_file}"

  [[ ! -d "${execution_surface_path}" ]] \
    || fail "unexpected_execution_surface_for_mode: ${mode}"

  grep -q "Skipping disposable execution surface" "${runtime_log_file}" \
    || fail "missing_execution_surface_skip_log_for_mode: ${mode}"

  grep -q "Preparing disposable execution surface" "${runtime_log_file}" \
    && fail "unexpected_execution_surface_preparation_for_mode: ${mode}"

  rm -f "${runtime_log_file}"
}

assert_payloads_are_execution_scoped() {
  local payload_dir="${AEGIS_CAPABILITY_PAYLOAD_DIR}"
  local payload_file
  local current_execution_id=""
  local payload_execution_id
  local actual_payloads_json

  rm -rf "${payload_dir}"
  mkdir -p "${payload_dir}"

  jq -n \
    --arg execution_id "stale-execution" \
    '{
      success: true,
      capability: "stale.payload",
      classification: "readonly",
      execution_id: $execution_id,
      generated_at: "1970-01-01T00:00:00Z",
      payload: {},
      error: null
    }' > "${payload_dir}/stale_payload.json"

  AEGIS_RUNTIME_REMOVE_CAPABILITY_PAYLOADS=false \
  bash runtime_aegis.sh discovery >/dev/null

  [[ ! -f "${payload_dir}/stale_payload.json" ]] \
    || fail "stale_payload_survived_runtime_refresh"

  actual_payloads_json="$({
    find "${payload_dir}" -maxdepth 1 -type f \
      | sed 's#.*/##' \
      | sort \
      | jq -R . \
      | jq -s '.'
  })"

  jq -n \
    --argjson actual_payloads "${actual_payloads_json}" \
    --argjson expected_payloads '[
      "filesystem_list_tree.json",
      "filesystem_search_symbol.json",
      "runtime_read_epistemic_handover.json",
      "runtime_read_target_system_profile.json"
    ]' \
    '
      $actual_payloads == $expected_payloads
    ' >/dev/null || fail "unexpected_discovery_payload_set"

  while IFS= read -r payload_file; do

    printf '%s\n' "${payload_file}" | grep -q '.' \
      || continue

    jq -e '
      .success == true
      and .error == null
      and (.capability | type == "string" and length > 0)
      and (.classification | type == "string" and length > 0)
      and (.execution_id | type == "string" and length > 0 and . != "unknown")
      and (.generated_at | type == "string" and length > 0)
      and .payload != null
    ' "${payload_file}" >/dev/null \
      || fail "invalid_payload_contract: ${payload_file}"

    payload_execution_id="$(jq -r '.execution_id' "${payload_file}")"

    if [[ -z "${current_execution_id}" ]]; then
      current_execution_id="${payload_execution_id}"
    else
      [[ "${payload_execution_id}" == "${current_execution_id}" ]] \
        || fail "payload_execution_id_mismatch"
    fi

  done < <(find "${payload_dir}" -maxdepth 1 -type f | sort)

  rm -rf "${payload_dir}"
}

main() {
  assert_constitutional_state_registry
  assert_executor_subprocess_isolation_contract
  assert_raw_substrate_isolation_contract
  bash scripts/test_runtime_contract.sh
  assert_evidence_profiles_are_subset_of_envelopes
  bash scripts/test_readonly_modes.sh

  start_mock_provider

  assert_readonly_mode_has_no_execution_surface "discovery"
  assert_readonly_mode_has_no_execution_surface "forensics"
  assert_readonly_mode_has_no_execution_surface "validation"
  assert_readonly_mode_has_no_execution_surface "adversarial"
  assert_payloads_are_execution_scoped

  echo "[AEGIS][TEST] constitutional invariants passed"
}

main "$@"