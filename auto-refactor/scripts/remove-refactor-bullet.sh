#!/usr/bin/env bash
set -euo pipefail

# Remove a bullet from REFACTOR.md by line number
# Input: $1 = line number
# Exit 0: success, Exit 1: file not found, Exit 2: file now empty

LINE="${1:?Usage: remove-refactor-bullet.sh <line-number>}"
REFACTOR_FILE="$(git rev-parse --show-toplevel 2>/dev/null)/REFACTOR.md"

if [[ ! -f "$REFACTOR_FILE" ]]; then
  echo "REFACTOR.md not found" >&2
  exit 1
fi

sed -i'' "${LINE}d" "$REFACTOR_FILE"

# Check if any bullets remain
if ! grep -q '^ *- ' "$REFACTOR_FILE" 2>/dev/null; then
  exit 2
fi

exit 0
