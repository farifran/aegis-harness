#!/usr/bin/env bash

# =================================================
# AEGIS HARNESS — CENTRAL RUNTIME CONFIGURATION
# =================================================
#
# Purpose:
# - centralized operational topology
# - capability registry
# - execution engine mapping
# - runtime protocol configuration
# - deterministic grounding parameters
#
# This file intentionally contains:
# - parameters
# - topology declarations
# - capability mappings
#
# This file intentionally avoids:
# - orchestration logic
# - semantic reasoning
# - runtime behavior
#
# =================================================

# =================================================
# PROVIDER CONFIGURATION
# =================================================

export OPENAI_API_KEY="${OPENAI_API_KEY:-}"

export OPENAI_API_BASE="${OPENAI_API_BASE:-https://integrate.api.nvidia.com/v1}"

# =================================================
# MODEL CONFIGURATION
# =================================================

export AEGIS_MODEL="meta/llama-3.3-70b-instruct"

export AEGIS_EDIT_FORMAT="diff"

export AEGIS_EXECUTION_TIMEOUT="120"

# =================================================
# PROTOCOL CONFIGURATION
# =================================================

export AEGIS_PROTOCOL_RUNTIME_OWNS_FRAMING="true"

export AEGIS_PROTOCOL_REQUIRE_SINGLE_JSON_OBJECT="true"

export AEGIS_PROTOCOL_REJECT_PROSE="true"

export AEGIS_PROTOCOL_REJECT_CONVERSATIONAL_OUTPUT="true"

# =================================================
# RUNTIME PATHS
# =================================================

export AEGIS_RUNTIME_DIR=".harness/runtime"

export AEGIS_CAPABILITY_ENV_DIR=".harness/runtime/capability_env"

export AEGIS_CAPABILITY_PAYLOAD_DIR=".harness/runtime/capability_payloads"

export AEGIS_ACTIVE_TASK_FILE=".harness/runtime/active_task.md"

export AEGIS_LAST_GOOD_TASK_FILE=".harness/runtime/last_good_active_task.md"

# =================================================
# EXECUTION SUBSTRATES
# =================================================

export AEGIS_SUBSTRATE_RAW="raw"

export AEGIS_SUBSTRATE_AIDER="aider"

# =================================================
# MODE LISTS
# =================================================

AEGIS_ANALYSIS_MODES=(
  discovery
  forensics
  validation
  adversarial
)

AEGIS_MUTATION_MODES=(
  repair
  optimize
)

# =================================================
# EXECUTION ENGINE MAPPING
# =================================================

export AEGIS_MODE_EXECUTION_ENGINE_discovery="raw"

export AEGIS_MODE_EXECUTION_ENGINE_forensics="raw"

export AEGIS_MODE_EXECUTION_ENGINE_validation="raw"

export AEGIS_MODE_EXECUTION_ENGINE_adversarial="raw"

export AEGIS_MODE_EXECUTION_ENGINE_repair="aider"

export AEGIS_MODE_EXECUTION_ENGINE_optimize="aider"

# =================================================
# EDIT AUTHORITY
# =================================================

export AEGIS_MODE_EDIT_AUTHORITY_discovery="false"

export AEGIS_MODE_EDIT_AUTHORITY_forensics="false"

export AEGIS_MODE_EDIT_AUTHORITY_validation="false"

export AEGIS_MODE_EDIT_AUTHORITY_adversarial="false"

export AEGIS_MODE_EDIT_AUTHORITY_repair="true"

export AEGIS_MODE_EDIT_AUTHORITY_optimize="true"

# =================================================
# CAPABILITY REGISTRY
# =================================================
#
# IMPORTANT:
# bash arrays MUST NOT use export.
#
# Arrays are runtime-local topology declarations.
#
# =================================================

# -------------------------------------------------
# DISCOVERY
# -------------------------------------------------

AEGIS_MODE_CAPABILITIES_discovery=(
  filesystem.list_tree
  filesystem.read
  filesystem.search_symbol
  topology.read_graph
  runtime.read_active_task
)

# -------------------------------------------------
# FORENSICS
# -------------------------------------------------

AEGIS_MODE_CAPABILITIES_forensics=(
  filesystem.list_tree
  filesystem.read
  filesystem.search_symbol
  git.status
  git.diff
  topology.read_graph
  runtime.read_active_task
)

# -------------------------------------------------
# VALIDATION
# -------------------------------------------------

AEGIS_MODE_CAPABILITIES_validation=(
  filesystem.list_tree
  filesystem.read
  git.status
  topology.read_graph
  runtime.read_active_task
)

# -------------------------------------------------
# ADVERSARIAL
# -------------------------------------------------

AEGIS_MODE_CAPABILITIES_adversarial=(
  filesystem.list_tree
  filesystem.read
  filesystem.search_symbol
  git.status
  git.diff
  topology.read_graph
  runtime.read_active_task
)

# -------------------------------------------------
# REPAIR
# -------------------------------------------------

AEGIS_MODE_CAPABILITIES_repair=(
  filesystem.list_tree
  filesystem.read
  filesystem.search_symbol
  git.status
  git.diff
  topology.read_graph
  runtime.read_active_task
)

# -------------------------------------------------
# OPTIMIZE
# -------------------------------------------------

AEGIS_MODE_CAPABILITIES_optimize=(
  filesystem.list_tree
  filesystem.read
  filesystem.search_symbol
  git.status
  git.diff
  topology.read_graph
  runtime.read_active_task
)

# =================================================
# CAPABILITY HANDLER REGISTRY
# =================================================

export AEGIS_CAPABILITY_HANDLER_FILESYSTEM_READ="scripts/capabilities/filesystem/read_file.sh"

export AEGIS_CAPABILITY_HANDLER_FILESYSTEM_LIST_TREE="scripts/capabilities/filesystem/list_tree.sh"

export AEGIS_CAPABILITY_HANDLER_FILESYSTEM_SEARCH_SYMBOL="scripts/capabilities/filesystem/search_symbol.sh"

export AEGIS_CAPABILITY_HANDLER_GIT_DIFF="scripts/capabilities/git/git_diff.sh"

export AEGIS_CAPABILITY_HANDLER_GIT_STATUS="scripts/capabilities/git/git_status.sh"

export AEGIS_CAPABILITY_HANDLER_RUNTIME_READ_ACTIVE_TASK="scripts/capabilities/runtime/read_active_task.sh"

export AEGIS_CAPABILITY_HANDLER_TOPOLOGY_READ_GRAPH="scripts/capabilities/topology/read_graph.sh"

# =================================================
# CAPABILITY GROUNDING DEFAULTS
# =================================================
#
# Purpose:
# - deterministic grounding
# - runtime-owned evidence injection
# - explicit capability payload generation
#
# Runtime owns:
# - grounding defaults
# - capability payload parameters
#
# =================================================

export AEGIS_DISCOVERY_SYMBOL_QUERY="AEGIS"

export AEGIS_FORENSICS_SYMBOL_QUERY="runtime"

export AEGIS_VALIDATION_SYMBOL_QUERY="protocol"

export AEGIS_ADVERSARIAL_SYMBOL_QUERY="authority"

# =================================================
# CAPABILITY PAYLOAD POLICY
# =================================================

export AEGIS_CAPABILITY_PAYLOAD_INJECTION="true"

export AEGIS_CAPABILITY_PAYLOAD_VALIDATE_JSON="true"

export AEGIS_CAPABILITY_PAYLOAD_REQUIRE_SUCCESS="true"

# =================================================
# PROVIDER HARDENING
# =================================================

export AEGIS_PROVIDER_RESPONSE_FORMAT="json_object"

export AEGIS_PROVIDER_TEMPERATURE="0"

export AEGIS_PROVIDER_TOP_P="1"

export AEGIS_PROVIDER_MAX_TOKENS="4096"

# =================================================
# WORKTREE EXECUTION MODEL
# =================================================
#
# Runtime authority remains outside worktree.
#
# Worktrees are:
# - bounded operational surfaces
# - bounded mutation surfaces
#
# Worktrees are NOT:
# - runtime authority contexts
# - topology ownership contexts
#
# =================================================

export AEGIS_RUNTIME_OWNS_EXECUTION_AUTHORITY="true"

export AEGIS_WORKTREE_IS_EXECUTION_SURFACE="true"

# =================================================
# RUNTIME SELF-CONSISTENCY
# =================================================

AEGIS_REQUIRED_RUNTIME_FILES=(
  "runtime_aegis.sh"
  "scripts/execute_mode.sh"
  ".harness/config.sh"
  "AGENTS.md"
)

AEGIS_REQUIRED_RUNTIME_DIRECTORIES=(
  ".skills"
  "scripts/capabilities"
  "scripts/substrates"
  ".harness/runtime"
)

# =================================================
# ARCHITECTURAL POSITION
# =================================================
#
# Aegis configuration defines:
# - authority topology
# - capability topology
# - execution topology
# - grounding topology
#
# Runtime consumes topology from config.
#
# Model consumes bounded runtime environments.
#
# =================================================