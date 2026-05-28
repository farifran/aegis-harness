#!/usr/bin/env bash

# =========================================================
# AEGIS HARNESS — OPERATIONAL TOPOLOGY CONFIGURATION
# =========================================================
#
# Version: 2.3
# Layer: Constitutional Runtime Topology
# Status: Hardened
#
# Responsibilities:
#
# - runtime topology source
# - capability registry
# - execution engine registry
# - provider operational policy
# - substrate defaults
# - protocol constants
# - deterministic runtime defaults
# - operational hardening defaults
#
# This file intentionally acts as:
#
# - declarative runtime topology;
# - centralized execution registry;
# - capability authority registry;
# - substrate configuration source;
# - provider policy source.
#
# This file intentionally avoids:
#
# - runtime lifecycle logic;
# - execution orchestration logic;
# - substrate implementation;
# - capability implementation;
# - provider-specific runtime logic.
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
export AEGIS_SYSTEM_VERSION="2.3"

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

#
# Provider credentials remain environment-owned.
# Defaults are intentionally explicit and minimal.
#

: "${OPENAI_API_BASE:=https://integrate.api.nvidia.com/v1}"
: "${OPENAI_MODEL_ANALYSIS:=meta/llama-3.3-70b-instruct}"
: "${OPENAI_MODEL_MUTATION:=meta/llama-3.3-70b-instruct}"

export OPENAI_API_BASE
export OPENAI_MODEL_ANALYSIS
export OPENAI_MODEL_MUTATION

# =========================================================
# RAW SUBSTRATE POLICY
# =========================================================

#
# Raw substrate is the analysis-only cognition path.
#

: "${AEGIS_RAW_SUBSTRATE_TEMPERATURE:=0}"
: "${AEGIS_RAW_SUBSTRATE_TIMEOUT_SECONDS:=120}"
: "${AEGIS_RAW_SUBSTRATE_MAX_RETRIES:=1}"

export AEGIS_RAW_SUBSTRATE_TEMPERATURE
export AEGIS_RAW_SUBSTRATE_TIMEOUT_SECONDS
export AEGIS_RAW_SUBSTRATE_MAX_RETRIES

# =========================================================
# PROVIDER POLICY
# =========================================================

#
# Provider policy is separate from substrate policy.
# This allows classification of connectivity vs response failures.
#

: "${AEGIS_PROVIDER_MAX_RETRIES:=3}"
: "${AEGIS_PROVIDER_RETRY_DELAY:=2}"
: "${AEGIS_PROVIDER_CONNECT_TIMEOUT:=15}"
: "${AEGIS_PROVIDER_RESPONSE_TIMEOUT:=120}"

export AEGIS_PROVIDER_MAX_RETRIES
export AEGIS_PROVIDER_RETRY_DELAY
export AEGIS_PROVIDER_CONNECT_TIMEOUT
export AEGIS_PROVIDER_RESPONSE_TIMEOUT

# =========================================================
# PAYLOAD GROUNDING DEFAULTS
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
# CLEANUP POLICY
# =========================================================

: "${AEGIS_RUNTIME_REMOVE_WORKTREE:=true}"
: "${AEGIS_RUNTIME_REMOVE_CAPABILITY_ENV:=true}"
: "${AEGIS_RUNTIME_REMOVE_CAPABILITY_PAYLOADS:=true}"

export AEGIS_RUNTIME_REMOVE_WORKTREE
export AEGIS_RUNTIME_REMOVE_CAPABILITY_ENV
export AEGIS_RUNTIME_REMOVE_CAPABILITY_PAYLOADS

# =========================================================
# EXECUTION ENGINES
# =========================================================
#
# IMPORTANT:
# Bash arrays MUST NOT use export.
#
# Arrays are not exportable and are validated
# with declare -p by the runtime.
#

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
# MODE → ENVELOPE MAP
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
# EXTENSION SURFACES
# =========================================================

declare -a AEGIS_FUTURE_CAPABILITY_CLASSES=(
  "dependency"
  "artifact"
  "policy"
  "validation"
)

declare -a AEGIS_FUTURE_SUBSTRATES=(
  "sandboxed_raw"
  "bounded_codegen"
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

validate_capability_registry() {

  local capability

  for capability in "${AEGIS_ANALYSIS_CAPABILITIES[@]}"; do

    [[ -n "${AEGIS_CAPABILITY_HANDLERS[$capability]:-}" ]] || {
      echo "[AEGIS][CONFIG][FATAL] unregistered_capability_handler: ${capability}" >&2
      return 1
    }

  done

  for capability in "${AEGIS_MUTATION_CAPABILITIES[@]}"; do

    [[ -n "${AEGIS_CAPABILITY_HANDLERS[$capability]:-}" ]] || {
      echo "[AEGIS][CONFIG][FATAL] unregistered_capability_handler: ${capability}" >&2
      return 1
    }

  done
}

validate_aegis_configuration() {

  validate_provider_configuration || return 1

  validate_capability_registry || return 1
}

# =========================================================
# VALIDATE IMMEDIATELY
# =========================================================

validate_aegis_configuration