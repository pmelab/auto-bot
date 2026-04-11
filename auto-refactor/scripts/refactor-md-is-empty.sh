#!/usr/bin/env bash
set -euo pipefail

# Check if REFACTOR.md has remaining bullet items
# Exit 0: empty (no bullets), Exit 1: has items, Exit 2: file doesn't exist

REFACTOR_FILE="$(git rev-parse --show-toplevel 2>/dev/null)/REFACTOR.md"

if [[ ! -f "$REFACTOR_FILE" ]]; then
  exit 2
fi

COUNT=$(grep -c '^ *- ' "$REFACTOR_FILE" 2>/dev/null || echo "0")

if [[ "$COUNT" -eq 0 ]]; then
  exit 0
else
  exit 1
fi
