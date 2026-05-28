#!/usr/bin/env bash

set -Eeuo pipefail

readonly EXECUTION_ID="${AEGIS_EXECUTION_ID:-unknown}"

readonly GENERATED_AT="$(
  date -u +"%Y-%m-%dT%H:%M:%SZ"
)"

DIFF_OUTPUT="$(
  git diff --no-color || true
)"

jq -n \
  --arg capability "git.diff" \
  --arg classification "readonly" \
  --arg execution_id "${EXECUTION_ID}" \
  --arg generated_at "${GENERATED_AT}" \
  --arg diff "${DIFF_OUTPUT}" \
  '{
    success: true,
    capability: $capability,
    classification: $classification,
    execution_id: $execution_id,
    generated_at: $generated_at,
    payload: {
      diff: $diff
    },
    error: null
  }'