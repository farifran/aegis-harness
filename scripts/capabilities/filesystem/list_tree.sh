# =================================================
# scripts/capabilities/filesystem/list_tree.sh
# =================================================

#!/usr/bin/env bash

set -Eeuo pipefail

CAPABILITY="filesystem.list_tree"

TARGET="${1:-.}"

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

[[ -d "$TARGET" ]] \
  || fatal "directory_not_found"

TREE="$(
  find "$TARGET" \
    -not -path '*/.git/*' \
    -not -path '*/node_modules/*' \
    | sort
)"

jq -n \
  --arg capability "$CAPABILITY" \
  --arg target "$TARGET" \
  --arg tree "$TREE" \
  '{
    success: true,
    capability: $capability,
    classification: "readonly",
    payload: {
      target: $target,
      tree: $tree
    },
    error: null
  }'