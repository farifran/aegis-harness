#!/usr/bin/env bash

set -euo pipefail

MODE_FILE="$1"

echo "[AEGIS] Executing mode file: $MODE_FILE"

mkdir -p .harness/runtime

cat > .harness/runtime/result.json <<EOF
{
  "status": "RUNNING"
}
EOF