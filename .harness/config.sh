#!/usr/bin/env bash

# =========================================================
# PROVIDER
# =========================================================

export AEGIS_MODEL="openai/meta/llama-3.3-70b-instruct"

# =========================================================
# EXECUTION
# =========================================================

export AEGIS_EXECUTION_TIMEOUT=300
export AEGIS_EDIT_FORMAT="diff"

# =========================================================
# RUNTIME MODES
# =========================================================

export AEGIS_ANALYSIS_MODES=(
  discovery
  forensics
  validation
  adversarial
)