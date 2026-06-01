#!/usr/bin/env bash

# =========================================================
# AEGIS HARNESS — OPERATIONAL TOPOLOGY CONFIGURATION
# =========================================================
#
# Version: 2.9
# Layer: Constitutional Runtime Topology
# Status: Hardened
#
# Responsibilities:
#
# - runtime topology source
# - capability registry
# - capability contracts
# - execution engine registry
# - provider operational policy
# - substrate defaults
# - protocol constants
# - cleanup policy
# - evidence budgets
# - evidence exposure policy
# - mode evidence profiles
# - filesystem pruning policy
#
# =========================================================

# =========================================================
# ROOT TOPOLOGY
# =========================================================

readonly AEGIS_ROOT_DIR="$(
  cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd
)"

# =========================================================
# SYSTEM METADATA
# =========================================================

export AEGIS_SYSTEM_NAME="Aegis Harness"
export AEGIS_SYSTEM_VERSION="2.9"

export AEGIS_ARCHITECTURE_MODEL="bounded_capability_runtime"
export AEGIS_EXECUTION_MODEL="protocol_oriented"
export AEGIS_CAPABILITY_EXPOSURE_MODEL="runtime_exposed_evidence"

# =========================================================
# RUNTIME TOPOLOGY
# =========================================================

export AEGIS_RUNTIME_DIR=".harness/runtime"
export AEGIS_EXECUTION_SURFACE_ROOT=".harness/execution_surfaces"

export AEGIS_CAPABILITY_ENV_DIR=".harness/runtime/capability_env"
export AEGIS_CAPABILITY_PAYLOAD_DIR=".harness/runtime/capability_payloads"

export AEGIS_EPISTEMIC_HANDOVER_FILE=".harness/runtime/epistemic_handover.json"
export AEGIS_LAST_GOOD_EPISTEMIC_HANDOVER_FILE=".harness/runtime/last_good_epistemic_handover.json"
export AEGIS_TARGET_SYSTEM_PROFILE_FILE="target_system_profile.yml"

# =========================================================
# ARTIFACT PROTOCOL
# =========================================================

export AEGIS_ARTIFACT_BEGIN_MARKER="AEGIS_ARTIFACT_BEGIN"
export AEGIS_ARTIFACT_END_MARKER="AEGIS_ARTIFACT_END"

# =========================================================
# PROVIDER DEFAULTS
# =========================================================

: "${OPENAI_API_BASE:=https://integrate.api.nvidia.com/v1}"
: "${OPENAI_MODEL_READONLY_COGNITION:=meta/llama-3.3-70b-instruct}"
: "${OPENAI_MODEL_BOUNDED_MUTATION:=meta/llama-3.3-70b-instruct}"

export OPENAI_API_BASE
export OPENAI_MODEL_READONLY_COGNITION
export OPENAI_MODEL_BOUNDED_MUTATION

# =========================================================
# RAW SUBSTRATE POLICY
# =========================================================

: "${AEGIS_RAW_SUBSTRATE_TEMPERATURE:=0}"
: "${AEGIS_RAW_SUBSTRATE_TIMEOUT_SECONDS:=120}"
: "${AEGIS_RAW_SUBSTRATE_MAX_RETRIES:=1}"

export AEGIS_RAW_SUBSTRATE_TEMPERATURE
export AEGIS_RAW_SUBSTRATE_TIMEOUT_SECONDS
export AEGIS_RAW_SUBSTRATE_MAX_RETRIES

# =========================================================
# PROVIDER POLICY
# =========================================================

: "${AEGIS_PROVIDER_MAX_RETRIES:=3}"
: "${AEGIS_PROVIDER_RETRY_DELAY:=2}"
: "${AEGIS_PROVIDER_CONNECT_TIMEOUT:=15}"
: "${AEGIS_PROVIDER_RESPONSE_TIMEOUT:=120}"

export AEGIS_PROVIDER_MAX_RETRIES
export AEGIS_PROVIDER_RETRY_DELAY
export AEGIS_PROVIDER_CONNECT_TIMEOUT
export AEGIS_PROVIDER_RESPONSE_TIMEOUT

# =========================================================
# CLEANUP POLICY
# =========================================================

: "${AEGIS_RUNTIME_REMOVE_EXECUTION_SURFACE:=true}"
: "${AEGIS_RUNTIME_REMOVE_CAPABILITY_ENV:=true}"
: "${AEGIS_RUNTIME_REMOVE_CAPABILITY_PAYLOADS:=true}"

export AEGIS_RUNTIME_REMOVE_EXECUTION_SURFACE
export AEGIS_RUNTIME_REMOVE_CAPABILITY_ENV
export AEGIS_RUNTIME_REMOVE_CAPABILITY_PAYLOADS

# =========================================================
# EVIDENCE BUDGETS
# =========================================================

: "${AEGIS_EVIDENCE_MAX_FILES:=25}"
: "${AEGIS_CAPABILITY_PAYLOAD_MAX_BYTES:=200000}"
: "${AEGIS_EVIDENCE_MAX_TOTAL_BYTES:=1500000}"
: "${AEGIS_SEARCH_SYMBOL_MAX_MATCH_LINES:=100}"
: "${AEGIS_FILE_CONTENT_MAX_BYTES:=50000}"
: "${AEGIS_EPISTEMIC_HANDOVER_MAX_BYTES:=25000}"
: "${AEGIS_TARGET_SYSTEM_PROFILE_MAX_BYTES:=25000}"
: "${AEGIS_CAPABILITY_MANIFEST_MAX_BYTES:=75000}"

export AEGIS_EVIDENCE_MAX_FILES
export AEGIS_CAPABILITY_PAYLOAD_MAX_BYTES
export AEGIS_EVIDENCE_MAX_TOTAL_BYTES
export AEGIS_SEARCH_SYMBOL_MAX_MATCH_LINES
export AEGIS_FILE_CONTENT_MAX_BYTES
export AEGIS_EPISTEMIC_HANDOVER_MAX_BYTES
export AEGIS_TARGET_SYSTEM_PROFILE_MAX_BYTES
export AEGIS_CAPABILITY_MANIFEST_MAX_BYTES

# =========================================================
# CAPABILITY DEFAULTS
# =========================================================

: "${AEGIS_LIST_TREE_MAX_DEPTH:=4}"
: "${AEGIS_SEARCH_SYMBOL_CONTEXT_LINES:=2}"

export AEGIS_LIST_TREE_MAX_DEPTH
export AEGIS_SEARCH_SYMBOL_CONTEXT_LINES

# =========================================================
# FILESYSTEM PRUNE POLICY
# =========================================================

declare -ar AEGIS_FILESYSTEM_PRUNE_PATHS=(
  "node_modules"
  ".git"
  ".harness/execution_surfaces"
  ".harness/runtime"
)

export AEGIS_FILESYSTEM_PRUNE_PATHS

# =========================================================
# EXECUTION ENGINES
# =========================================================

declare -Ar AEGIS_EXECUTION_ENGINES=(
  ["discovery"]="raw"
  ["forensics"]="raw"
  ["validation"]="raw"
  ["adversarial"]="raw"
  ["repair"]="aider"
  ["optimize"]="aider"
)

# =========================================================
# CAPABILITY ENVELOPES
# =========================================================

declare -ar AEGIS_READONLY_COGNITION_CAPABILITIES=(
  "filesystem.list_tree"
  "filesystem.read"
  "filesystem.search_symbol"
  "git.status"
  "runtime.read_target_system_profile"
  "runtime.read_epistemic_handover"
)

declare -ar AEGIS_BOUNDED_MUTATION_CAPABILITIES=(
  "filesystem.list_tree"
  "filesystem.read"
  "filesystem.search_symbol"
  "runtime.read_target_system_profile"
  "runtime.read_epistemic_handover"
  "git.diff"
  "git.status"
)

# =========================================================
# MODE → CAPABILITY ENVELOPE
# =========================================================

declare -Ar AEGIS_MODE_CAPABILITY_MAP=(
  ["discovery"]="AEGIS_READONLY_COGNITION_CAPABILITIES"
  ["forensics"]="AEGIS_READONLY_COGNITION_CAPABILITIES"
  ["validation"]="AEGIS_READONLY_COGNITION_CAPABILITIES"
  ["adversarial"]="AEGIS_READONLY_COGNITION_CAPABILITIES"
  ["repair"]="AEGIS_BOUNDED_MUTATION_CAPABILITIES"
  ["optimize"]="AEGIS_BOUNDED_MUTATION_CAPABILITIES"
)

# =========================================================
# CAPABILITY HANDLERS
# =========================================================

declare -Ar AEGIS_CAPABILITY_HANDLERS=(
  ["filesystem.list_tree"]="scripts/capabilities/filesystem/list_tree.sh"
  ["filesystem.read"]="scripts/capabilities/filesystem/read_file.sh"
  ["filesystem.search_symbol"]="scripts/capabilities/filesystem/search_symbol.sh"
  ["git.diff"]="scripts/capabilities/git/git_diff.sh"
  ["git.status"]="scripts/capabilities/git/git_status.sh"
  ["runtime.read_target_system_profile"]="scripts/capabilities/runtime/read_target_system_profile.sh"
  ["runtime.read_epistemic_handover"]="scripts/capabilities/runtime/read_epistemic_handover.sh"
)

# =========================================================
# CAPABILITY CLASSIFICATION
# =========================================================

declare -Ar AEGIS_CAPABILITY_CLASSIFICATION=(
  ["filesystem.list_tree"]="readonly"
  ["filesystem.read"]="readonly"
  ["filesystem.search_symbol"]="readonly"
  ["git.diff"]="readonly"
  ["git.status"]="readonly"
  ["runtime.read_target_system_profile"]="readonly"
  ["runtime.read_epistemic_handover"]="readonly"
)

# =========================================================
# CAPABILITY INVOCATION CONTRACTS
# =========================================================

declare -Ar AEGIS_CAPABILITY_ARGUMENTS=(
  ["filesystem.list_tree"]="."
  ["filesystem.read"]="AGENTS.md"
  ["filesystem.search_symbol"]="AEGIS"
  ["runtime.read_target_system_profile"]="${AEGIS_TARGET_SYSTEM_PROFILE_FILE}"
  ["runtime.read_epistemic_handover"]="${AEGIS_EPISTEMIC_HANDOVER_FILE}"
  ["git.diff"]="HEAD~1"
  ["git.status"]="."
)

# =========================================================
# MODE EVIDENCE PROFILES
# =========================================================

declare -Ar AEGIS_MODE_EVIDENCE_PROFILE=(
  ["discovery"]="AEGIS_DISCOVERY_EVIDENCE"
  ["forensics"]="AEGIS_FORENSICS_EVIDENCE"
  ["validation"]="AEGIS_VALIDATION_EVIDENCE"
  ["adversarial"]="AEGIS_ADVERSARIAL_EVIDENCE"
  ["repair"]="AEGIS_REPAIR_EVIDENCE"
  ["optimize"]="AEGIS_OPTIMIZE_EVIDENCE"
)

declare -ar AEGIS_DISCOVERY_EVIDENCE=(
  "filesystem.list_tree"
  "filesystem.search_symbol"
  "runtime.read_target_system_profile"
  "runtime.read_epistemic_handover"
)

declare -ar AEGIS_FORENSICS_EVIDENCE=(
  "filesystem.search_symbol"
  "git.status"
  "runtime.read_target_system_profile"
  "runtime.read_epistemic_handover"
)

declare -ar AEGIS_VALIDATION_EVIDENCE=(
  "runtime.read_target_system_profile"
  "runtime.read_epistemic_handover"
)

declare -ar AEGIS_ADVERSARIAL_EVIDENCE=(
  "filesystem.search_symbol"
  "runtime.read_target_system_profile"
)

declare -ar AEGIS_REPAIR_EVIDENCE=(
  "filesystem.search_symbol"
  "runtime.read_target_system_profile"
  "runtime.read_epistemic_handover"
  "git.diff"
  "git.status"
)

declare -ar AEGIS_OPTIMIZE_EVIDENCE=(
  "filesystem.search_symbol"
  "runtime.read_target_system_profile"
  "runtime.read_epistemic_handover"
  "git.diff"
  "git.status"
)

# =========================================================
# DISCOVERY DEFAULTS
# =========================================================

: "${AEGIS_DISCOVERY_SYMBOL_QUERY:=AEGIS}"
: "${AEGIS_FORENSICS_SYMBOL_QUERY:=runtime}"
: "${AEGIS_VALIDATION_SYMBOL_QUERY:=protocol}"
: "${AEGIS_ADVERSARIAL_SYMBOL_QUERY:=authority}"

export AEGIS_DISCOVERY_SYMBOL_QUERY
export AEGIS_FORENSICS_SYMBOL_QUERY
export AEGIS_VALIDATION_SYMBOL_QUERY
export AEGIS_ADVERSARIAL_SYMBOL_QUERY

# =========================================================
# GOVERNANCE FLAGS
# =========================================================

export AEGIS_CONSTITUTIONAL_LAYER_FROZEN="true"
export AEGIS_ALLOW_IMPLICIT_CAPABILITY_EXPOSURE="false"
export AEGIS_ALLOW_UNBOUNDED_MUTATION="false"
export AEGIS_ALLOW_HIDDEN_CONTINUITY="false"

# =========================================================
# CONTAINMENT MODEL
# =========================================================

export AEGIS_RUNTIME_AUTHORITY_MODEL="runtime_sovereignty"
export AEGIS_EXECUTION_SURFACE_MODEL="disposable_execution_surface"
export AEGIS_MUTATION_MODEL="bounded_mutation"

# =========================================================
# CONSTITUTIONAL STATES
# =========================================================

declare -a AEGIS_PROVEN_SURFACES=(
  "runtime_external_to_execution_surface"
  "capability_environment_materialization"
  "capability_payload_evidence_materialization"
  "payload_provenance_tracking"
  "readonly_cognition_topology"
  "protocol_oriented_execution"
  "epistemic_handover_explicit_continuity"
  "readonly_execution_surface_elision"
)

declare -a AEGIS_INTENDED_SURFACES=(
  "bounded_mutation_hardening"
  "capability_coercion"
  "strict_schema_validation"
)

declare -a AEGIS_DEFERRED_SURFACES=(
  "distributed_runtime_execution"
  "advanced_capability_sandboxing"
  "cross_provider_protocol_normalization"
)

# =========================================================
# VALIDATION HELPERS
# =========================================================

validate_provider_configuration() {

  [[ -n "${OPENAI_API_BASE}" ]] || {
    echo "[AEGIS][CONFIG][FATAL] missing_openai_api_base" >&2
    return 1
  }

  [[ -n "${OPENAI_MODEL_READONLY_COGNITION}" ]] || {
    echo "[AEGIS][CONFIG][FATAL] missing_readonly_cognition_model" >&2
    return 1
  }

  [[ -n "${AEGIS_PROVIDER_MAX_RETRIES}" ]] || {
    echo "[AEGIS][CONFIG][FATAL] missing_provider_max_retries" >&2
    return 1
  }

  [[ -n "${AEGIS_PROVIDER_RETRY_DELAY}" ]] || {
    echo "[AEGIS][CONFIG][FATAL] missing_provider_retry_delay" >&2
    return 1
  }

  [[ -n "${AEGIS_PROVIDER_CONNECT_TIMEOUT}" ]] || {
    echo "[AEGIS][CONFIG][FATAL] missing_provider_connect_timeout" >&2
    return 1
  }

  [[ -n "${AEGIS_PROVIDER_RESPONSE_TIMEOUT}" ]] || {
    echo "[AEGIS][CONFIG][FATAL] missing_provider_response_timeout" >&2
    return 1
  }
}

validate_evidence_policy() {

  [[ "${AEGIS_EVIDENCE_MAX_TOTAL_BYTES}" -gt 0 ]] || {
    echo "[AEGIS][CONFIG][FATAL] invalid_evidence_total_budget" >&2
    return 1
  }

  [[ "${AEGIS_EVIDENCE_MAX_FILES}" -gt 0 ]] || {
    echo "[AEGIS][CONFIG][FATAL] invalid_evidence_file_budget" >&2
    return 1
  }

  [[ "${AEGIS_CAPABILITY_PAYLOAD_MAX_BYTES}" -gt 0 ]] || {
    echo "[AEGIS][CONFIG][FATAL] invalid_capability_payload_budget" >&2
    return 1
  }
}

validate_capability_registry() {

  local capability

  for capability in "${AEGIS_READONLY_COGNITION_CAPABILITIES[@]}"; do

    [[ -n "${AEGIS_CAPABILITY_HANDLERS[$capability]:-}" ]] || {
      echo "[AEGIS][CONFIG][FATAL] unregistered_capability_handler: ${capability}" >&2
      return 1
    }

    [[ -n "${AEGIS_CAPABILITY_ARGUMENTS[$capability]:-}" ]] || {
      echo "[AEGIS][CONFIG][FATAL] missing_capability_argument_contract: ${capability}" >&2
      return 1
    }

  done

  for capability in "${AEGIS_BOUNDED_MUTATION_CAPABILITIES[@]}"; do

    [[ -n "${AEGIS_CAPABILITY_HANDLERS[$capability]:-}" ]] || {
      echo "[AEGIS][CONFIG][FATAL] unregistered_capability_handler: ${capability}" >&2
      return 1
    }

    [[ -n "${AEGIS_CAPABILITY_ARGUMENTS[$capability]:-}" ]] || {
      echo "[AEGIS][CONFIG][FATAL] missing_capability_argument_contract: ${capability}" >&2
      return 1
    }

  done
}

validate_evidence_profiles() {

  local mode
  local profile_name
  local envelope_name
  local capability
  local envelope_capability
  local capability_is_authorized

  for mode in "${!AEGIS_MODE_EVIDENCE_PROFILE[@]}"; do

    profile_name="${AEGIS_MODE_EVIDENCE_PROFILE[$mode]}"
    envelope_name="${AEGIS_MODE_CAPABILITY_MAP[$mode]:-}"

    [[ -n "${envelope_name}" ]] || {
      echo "[AEGIS][CONFIG][FATAL] missing_capability_envelope_for_mode: ${mode}" >&2
      return 1
    }

    declare -p "${profile_name}" >/dev/null 2>&1 || {
      echo "[AEGIS][CONFIG][FATAL] missing_evidence_profile_array: ${profile_name}" >&2
      return 1
    }

    declare -n profile_ref="${profile_name}"
    declare -n envelope_ref="${envelope_name}"

    [[ "${#profile_ref[@]}" -gt 0 ]] || {
      echo "[AEGIS][CONFIG][FATAL] empty_evidence_profile_array: ${profile_name}" >&2
      return 1
    }

    for capability in "${profile_ref[@]}"; do

      capability_is_authorized="false"

      for envelope_capability in "${envelope_ref[@]}"; do
        if [[ "${envelope_capability}" == "${capability}" ]]; then
          capability_is_authorized="true"
          break
        fi
      done

      [[ "${capability_is_authorized}" == "true" ]] || {
        echo "[AEGIS][CONFIG][FATAL] evidence_capability_outside_envelope: ${mode}:${capability}" >&2
        return 1
      }

    done

  done
}

validate_filesystem_prune_policy() {

  [[ "${#AEGIS_FILESYSTEM_PRUNE_PATHS[@]}" -gt 0 ]] || {
    echo "[AEGIS][CONFIG][FATAL] empty_filesystem_prune_policy" >&2
    return 1
  }
}

validate_aegis_configuration() {

  validate_provider_configuration || return 1
  validate_evidence_policy || return 1
  validate_capability_registry || return 1
  validate_evidence_profiles || return 1
  validate_filesystem_prune_policy || return 1
}

# =========================================================
# VALIDATE IMMEDIATELY
# =========================================================

validate_aegis_configuration