#!/usr/bin/env bash

set -e

echo "== Aegis Harness Environment Setup =="

echo ""
echo "[1/5] Installing project dependencies..."
npm install

echo ""
echo "[2/5] Installing global tooling..."
npm install -g typescript eslint @ast-grep/cli

echo ""
echo "[3/5] Installing aider..."
python3 -m pip install --user aider-chat

echo ""
echo "[4/5] Ensuring runtime permissions..."
chmod +x runtime_aegis.sh

echo ""
echo "[5/5] Environment setup complete."

echo ""
echo "Run validate_environment.sh to verify installation."
