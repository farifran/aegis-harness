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
# - grounding budgets
# - evidence exposure policy
# - mode grounding profiles
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
export AEGIS_GROUNDING_MODEL="runtime_exposed_capabilities"

# =========================================================
# RUNTIME TOPOLOGY
# =========================================================

export AEGIS_RUNTIME_DIR=".harness/runtime"
export AEGIS_WORKTREE_ROOT=".harness/worktrees"

export AEGIS_CAPABILITY_ENV_DIR=".harness/runtime/capability_env"
export AEGIS_CAPABILITY_PAYLOAD_DIR=".harness/runtime/capability_payloads"

export AEGIS_ACTIVE_TASK_FILE=".harness/runtime/active_task.md"
export AEGIS_LAST_GOOD_TASK_FILE=".harness/runtime/last_good_active_task.md"

# =========================================================
# ARTIFACT PROTOCOL
# =========================================================

export AEGIS_ARTIFACT_BEGIN_MARKER="AEGIS_ARTIFACT_BEGIN"
export AEGIS_ARTIFACT_END_MARKER="AEGIS_ARTIFACT_END"

# =========================================================
# PROVIDER DEFAULTS
# =========================================================

: "${OPENAI_API_BASE:=https://integrate.api.nvidia.com/v1}"
: "${OPENAI_MODEL_ANALYSIS:=meta/llama-3.3-70b-instruct}"
: "${OPENAI_MODEL_MUTATION:=meta/llama-3.3-70b-instruct}"

export OPENAI_API_BASE
export OPENAI_MODEL_ANALYSIS
export OPENAI_MODEL_MUTATION

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

: "${AEGIS_RUNTIME_REMOVE_WORKTREE:=true}"
: "${AEGIS_RUNTIME_REMOVE_CAPABILITY_ENV:=true}"
: "${AEGIS_RUNTIME_REMOVE_CAPABILITY_PAYLOADS:=true}"

export AEGIS_RUNTIME_REMOVE_WORKTREE
export AEGIS_RUNTIME_REMOVE_CAPABILITY_ENV
export AEGIS_RUNTIME_REMOVE_CAPABILITY_PAYLOADS

# =========================================================
# GROUNDING BUDGETS
# =========================================================

: "${AEGIS_GROUNDING_MAX_FILES:=25}"
: "${AEGIS_GROUNDING_MAX_PAYLOAD_BYTES:=200000}"
: "${AEGIS_GROUNDING_MAX_TOTAL_BYTES:=1500000}"
: "${AEGIS_GROUNDING_MAX_TREE_LINES:=300}"
: "${AEGIS_GROUNDING_MAX_MATCH_LINES:=100}"
: "${AEGIS_GROUNDING_MAX_READ_BYTES:=50000}"
: "${AEGIS_GROUNDING_MAX_GRAPH_BYTES:=100000}"
: "${AEGIS_GROUNDING_MAX_ACTIVE_TASK_BYTES:=25000}"
: "${AEGIS_GROUNDING_MAX_MANIFEST_BYTES:=75000}"

export AEGIS_GROUNDING_MAX_FILES
export AEGIS_GROUNDING_MAX_PAYLOAD_BYTES
export AEGIS_GROUNDING_MAX_TOTAL_BYTES
export AEGIS_GROUNDING_MAX_TREE_LINES
export AEGIS_GROUNDING_MAX_MATCH_LINES
export AEGIS_GROUNDING_MAX_READ_BYTES
export AEGIS_GROUNDING_MAX_GRAPH_BYTES
export AEGIS_GROUNDING_MAX_ACTIVE_TASK_BYTES
export AEGIS_GROUNDING_MAX_MANIFEST_BYTES

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
  ".harness/worktrees"
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

declare -ar AEGIS_ANALYSIS_CAPABILITIES=(
  "filesystem.list_tree"
  "filesystem.read"
  "filesystem.search_symbol"
  "topology.read_graph"
  "runtime.read_active_task"
)

declare -ar AEGIS_MUTATION_CAPABILITIES=(
  "filesystem.list_tree"
  "filesystem.read"
  "filesystem.search_symbol"
  "topology.read_graph"
  "runtime.read_active_task"
  "git.diff"
  "git.status"
)

# =========================================================
# MODE → CAPABILITY ENVELOPE
# =========================================================

declare -Ar AEGIS_MODE_CAPABILITY_MAP=(
  ["discovery"]="AEGIS_ANALYSIS_CAPABILITIES"
  ["forensics"]="AEGIS_ANALYSIS_CAPABILITIES"
  ["validation"]="AEGIS_ANALYSIS_CAPABILITIES"
  ["adversarial"]="AEGIS_ANALYSIS_CAPABILITIES"
  ["repair"]="AEGIS_MUTATION_CAPABILITIES"
  ["optimize"]="AEGIS_MUTATION_CAPABILITIES"
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
  ["topology.read_graph"]="scripts/capabilities/topology/read_graph.sh"
  ["runtime.read_active_task"]="scripts/capabilities/runtime/read_active_task.sh"
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
  ["topology.read_graph"]="readonly"
  ["runtime.read_active_task"]="readonly"
)

# =========================================================
# CAPABILITY INVOCATION CONTRACTS
# =========================================================

declare -Ar AEGIS_CAPABILITY_ARGUMENTS=(
  ["filesystem.list_tree"]="."
  ["filesystem.read"]="AGENTS.md"
  ["filesystem.search_symbol"]="AEGIS"
  ["topology.read_graph"]=".harness/architecture_graph.json"
  ["runtime.read_active_task"]="${AEGIS_ACTIVE_TASK_FILE}"
  ["git.diff"]="HEAD~1"
  ["git.status"]="."
)

# =========================================================
# MODE GROUNDING PROFILES
# =========================================================

declare -Ar AEGIS_MODE_GROUNDING_PROFILE=(
  ["discovery"]="AEGIS_DISCOVERY_GROUNDING"
  ["forensics"]="AEGIS_FORENSICS_GROUNDING"
  ["validation"]="AEGIS_VALIDATION_GROUNDING"
  ["adversarial"]="AEGIS_ADVERSARIAL_GROUNDING"
  ["repair"]="AEGIS_REPAIR_GROUNDING"
  ["optimize"]="AEGIS_OPTIMIZE_GROUNDING"
)

declare -ar AEGIS_DISCOVERY_GROUNDING=(
  "topology.read_graph"
)

declare -ar AEGIS_FORENSICS_GROUNDING=(
  "topology.read_graph"
  "filesystem.search_symbol"
  "runtime.read_active_task"
)

declare -ar AEGIS_VALIDATION_GROUNDING=(
  "topology.read_graph"
  "runtime.read_active_task"
)

declare -ar AEGIS_ADVERSARIAL_GROUNDING=(
  "topology.read_graph"
  "filesystem.search_symbol"
)

declare -ar AEGIS_REPAIR_GROUNDING=(
  "filesystem.search_symbol"
  "runtime.read_active_task"
  "git.diff"
  "git.status"
)

declare -ar AEGIS_OPTIMIZE_GROUNDING=(
  "filesystem.search_symbol"
  "runtime.read_active_task"
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
export AEGIS_ALLOW_IMPLICIT_GROUNDING="false"
export AEGIS_ALLOW_UNBOUNDED_MUTATION="false"
export AEGIS_ALLOW_HIDDEN_CONTINUITY="false"

# =========================================================
# CONTAINMENT MODEL
# =========================================================

export AEGIS_RUNTIME_AUTHORITY_MODEL="runtime_sovereignty"
export AEGIS_EXECUTION_SURFACE_MODEL="disposable_worktree"
export AEGIS_MUTATION_MODEL="bounded_mutation"

# =========================================================
# CONSTITUTIONAL STATES
# =========================================================

declare -a AEGIS_PROVEN_SURFACES=(
  "runtime_external_to_execution_surface"
  "capability_environment_materialization"
  "capability_payload_grounding"
  "readonly_analysis_topology"
  "protocol_oriented_execution"
)

declare -a AEGIS_INTENDED_SURFACES=(
  "bounded_mutation_hardening"
  "payload_provenance_tracking"
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

  [[ -n "${OPENAI_MODEL_ANALYSIS}" ]] || {
    echo "[AEGIS][CONFIG][FATAL] missing_analysis_model" >&2
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

validate_grounding_policy() {

  [[ "${AEGIS_GROUNDING_MAX_TOTAL_BYTES}" -gt 0 ]] || {
    echo "[AEGIS][CONFIG][FATAL] invalid_grounding_total_budget" >&2
    return 1
  }

  [[ "${AEGIS_GROUNDING_MAX_FILES}" -gt 0 ]] || {
    echo "[AEGIS][CONFIG][FATAL] invalid_grounding_file_budget" >&2
    return 1
  }

  [[ "${AEGIS_GROUNDING_MAX_PAYLOAD_BYTES}" -gt 0 ]] || {
    echo "[AEGIS][CONFIG][FATAL] invalid_grounding_payload_budget" >&2
    return 1
  }
}

validate_capability_registry() {

  local capability

  for capability in "${AEGIS_ANALYSIS_CAPABILITIES[@]}"; do

    [[ -n "${AEGIS_CAPABILITY_HANDLERS[$capability]:-}" ]] || {
      echo "[AEGIS][CONFIG][FATAL] unregistered_capability_handler: ${capability}" >&2
      return 1
    }

    [[ -n "${AEGIS_CAPABILITY_ARGUMENTS[$capability]:-}" ]] || {
      echo "[AEGIS][CONFIG][FATAL] missing_capability_argument_contract: ${capability}" >&2
      return 1
    }

  done

  for capability in "${AEGIS_MUTATION_CAPABILITIES[@]}"; do

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

validate_grounding_profiles() {

  local mode
  local profile_name

  for mode in "${!AEGIS_MODE_GROUNDING_PROFILE[@]}"; do

    profile_name="${AEGIS_MODE_GROUNDING_PROFILE[$mode]}"

    declare -p "${profile_name}" >/dev/null 2>&1 || {
      echo "[AEGIS][CONFIG][FATAL] missing_grounding_profile_array: ${profile_name}" >&2
      return 1
    }

    declare -n profile_ref="${profile_name}"

    [[ "${#profile_ref[@]}" -gt 0 ]] || {
      echo "[AEGIS][CONFIG][FATAL] empty_grounding_profile_array: ${profile_name}" >&2
      return 1
    }

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
  validate_grounding_policy || return 1
  validate_capability_registry || return 1
  validate_grounding_profiles || return 1
  validate_filesystem_prune_policy || return 1
}

# =========================================================
# VALIDATE IMMEDIATELY
# =========================================================

validate_aegis_configuration