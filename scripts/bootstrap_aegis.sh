#!/usr/bin/env bash

set -e

echo "== Aegis Harness Bootstrap =="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "[Bootstrap] Installing AST-Grep..."
bash "$SCRIPT_DIR/install_ast_grep.sh"

echo ""
echo "[Bootstrap] Setting up environment..."
bash "$SCRIPT_DIR/setup_environment.sh"

echo ""
echo "[Bootstrap] Validating environment..."
bash "$SCRIPT_DIR/validate_environment.sh"

echo ""
echo "Aegis Harness bootstrap complete."
