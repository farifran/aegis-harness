# =================================================
# scripts/capabilities/filesystem/read_file.sh
# =================================================

#!/usr/bin/env bash

set -Eeuo pipefail

CAPABILITY="filesystem.read"

TARGET="${1:-}"

fatal() {
  jq -n \
    --arg capability "$CAPABILITY" \
    --arg error "$1" \
    '{
      success: false,
      capability: $capability,
      classification: "readonly",
      payload: null,
      error: $error
    }'
  exit 1
}

[[ -n "$TARGET" ]] \
  || fatal "missing_target"

[[ -f "$TARGET" ]] \
  || fatal "file_not_found"

CONTENT="$(cat "$TARGET")"

jq -n \
  --arg capability "$CAPABILITY" \
  --arg target "$TARGET" \
  --arg content "$CONTENT" \
  '{
    success: true,
    capability: $capability,
    classification: "readonly",
    payload: {
      target: $target,
      content: $content
    },
    error: null
  }'