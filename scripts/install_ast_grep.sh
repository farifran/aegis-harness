#!/usr/bin/env bash

set -e

echo "== Installing AST-Grep =="

if command -v brew >/dev/null 2>&1; then
    echo "Detected Homebrew."
    brew install ast-grep
    exit 0
fi

if command -v cargo >/dev/null 2>&1; then
    echo "Detected Rust Cargo."
    cargo install ast-grep
    exit 0
fi

if command -v npm >/dev/null 2>&1; then
    echo "Using npm fallback."
    npm install -g @ast-grep/cli
    exit 0
fi

echo "No supported installer detected."
exit 1
