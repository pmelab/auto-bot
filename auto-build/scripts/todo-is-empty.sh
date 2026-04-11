#!/usr/bin/env bash
set -euo pipefail

# Check if all TODO.md items are checked off
# Exit 0: all done, Exit 1: unchecked items remain, Exit 2: TODO.md not found

TODO_FILE="$(git rev-parse --show-toplevel 2>/dev/null)/TODO.md"

if [[ ! -f "$TODO_FILE" ]]; then
  exit 2
fi

COUNT=$(grep -c '^ *- \[ \]' "$TODO_FILE" 2>/dev/null || echo "0")

if [[ "$COUNT" -eq 0 ]]; then
  exit 0
else
  exit 1
fi
