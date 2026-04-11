#!/usr/bin/env bash
set -euo pipefail

# Find the first unchecked item in TODO.md with phase context
# Output: JSON {line, text, phase} on stdout
# Exit 0: found, Exit 1: no unchecked items, Exit 2: TODO.md not found

TODO_FILE="$(git rev-parse --show-toplevel 2>/dev/null)/TODO.md"

if [[ ! -f "$TODO_FILE" ]]; then
  echo "TODO.md not found" >&2
  exit 2
fi

# Find first unchecked item
MATCH=$(grep -n '^ *- \[ \]' "$TODO_FILE" | head -1 || true)

if [[ -z "$MATCH" ]]; then
  exit 1
fi

LINE_NUM=$(echo "$MATCH" | cut -d: -f1)
TEXT=$(echo "$MATCH" | cut -d: -f2- | sed 's/^[[:space:]]*- \[ \][[:space:]]*//')

# Find phase header by scanning backwards
PHASE=""
for ((i=LINE_NUM-1; i>=1; i--)); do
  HEADER=$(sed -n "${i}p" "$TODO_FILE")
  if [[ "$HEADER" =~ ^##[[:space:]]+(Phase[[:space:]]+[0-9]+.*) ]]; then
    PHASE="${BASH_REMATCH[1]}"
    break
  fi
done

jq -n \
  --argjson line "$LINE_NUM" \
  --arg text "$TEXT" \
  --arg phase "$PHASE" \
  '{"line": $line, "text": $text, "phase": $phase}'
