#!/usr/bin/env bash
set -euo pipefail

# Remove a specific line from a file and clean consecutive blank lines
# Input: $1 = file path, $2 = line number
# Exit 0: success, Exit 1: failure

FILE="${1:?Usage: remove-marker-line.sh <file> <line-number>}"
LINE="${2:?Usage: remove-marker-line.sh <file> <line-number>}"

if [[ ! -f "$FILE" ]]; then
  echo "File not found: $FILE" >&2
  exit 1
fi

# Delete the line
sed "${LINE}d" "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"

# Clean consecutive blank lines (collapse to single)
sed '/^$/N;/^\n$/d' "$FILE" > "$FILE.tmp" && mv "$FILE.tmp" "$FILE"
