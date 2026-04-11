#!/usr/bin/env bash
set -euo pipefail

# Extract bullet items from REFACTOR.md
# Output: JSON array [{line, text}] on stdout
# Exit 0: success (empty array if no file or no bullets)
# Exit 1: read error

REFACTOR_FILE="$(git rev-parse --show-toplevel 2>/dev/null)/REFACTOR.md"

if [[ ! -f "$REFACTOR_FILE" ]]; then
  echo "[]"
  exit 0
fi

RESULTS="[]"

while IFS= read -r match; do
  LINE_NUM=$(echo "$match" | cut -d: -f1)
  TEXT=$(echo "$match" | cut -d: -f2- | sed 's/^[[:space:]]*-[[:space:]]*//')
  RESULTS=$(echo "$RESULTS" | jq --argjson l "$LINE_NUM" --arg t "$TEXT" '. + [{"line": $l, "text": $t}]')
done < <(grep -n '^ *- ' "$REFACTOR_FILE" || true)

echo "$RESULTS" | jq .
