# =================================================
# scripts/capabilities/git/git_diff.sh
# =================================================

#!/usr/bin/env bash

set -Eeuo pipefail

CAPABILITY="git.diff"

DIFF="$(git diff --minimal)"

jq -n \
  --arg capability "$CAPABILITY" \
  --arg diff "$DIFF" \
  '{
    success: true,
    capability: $capability,
    classification: "readonly",
    payload: {
      diff: $diff
    },
    error: null
  }'