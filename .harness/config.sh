#!/usr/bin/env bash

AEGIS_MODEL="openai/meta/llama-3.3-70b-instruct"
AEGIS_EDIT_FORMAT="diff"
AEGIS_EXECUTION_TIMEOUT=300

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

AEGIS_MODE_EDIT_AUTHORITY_discovery="false"
AEGIS_MODE_EDIT_AUTHORITY_forensics="false"
AEGIS_MODE_EDIT_AUTHORITY_validation="false"
AEGIS_MODE_EDIT_AUTHORITY_adversarial="false"
AEGIS_MODE_EDIT_AUTHORITY_repair="true"
AEGIS_MODE_EDIT_AUTHORITY_optimize="true"