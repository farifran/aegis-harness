# =================================================
# scripts/capabilities/git/git_status.sh
# =================================================

#!/usr/bin/env bash

set -Eeuo pipefail

CAPABILITY="git.status"

STATUS="$(git status --short)"

jq -n \
  --arg capability "$CAPABILITY" \
  --arg status "$STATUS" \
  '{
    success: true,
    capability: $capability,
    classification: "readonly",
    payload: {
      status: $status
    },
    error: null
  }'