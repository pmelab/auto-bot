#!/usr/bin/env bash
set -euo pipefail

# Extract marker comments from git diff added lines
# Input: $1 = marker name (default: RF)
# Output: JSON array [{file, line, text}] on stdout
# Exit 0 always (empty array if none found)

MARKER="${1:-RF}"

# Get diff of staged + unstaged changes
DIFF=$(git diff HEAD 2>/dev/null || git diff 2>/dev/null || echo "")

if [[ -z "$DIFF" ]]; then
  echo "[]"
  exit 0
fi

RESULTS="[]"
CURRENT_FILE=""
LINE_NUM=0

while IFS= read -r line; do
  # Track current file from diff headers
  if [[ "$line" =~ ^diff\ --git\ a/.*\ b/(.*) ]]; then
    CURRENT_FILE="${BASH_REMATCH[1]}"
    LINE_NUM=0
    continue
  fi

  # Track line numbers from hunk headers
  if [[ "$line" =~ ^@@.*\+([0-9]+) ]]; then
    LINE_NUM="${BASH_REMATCH[1]}"
    continue
  fi

  # Count lines in the new file
  if [[ "$line" =~ ^[^-] ]]; then
    if [[ "$line" =~ ^\+ ]]; then
      # Added line — check for marker
      CONTENT="${line:1}"
      if echo "$CONTENT" | grep -qE "\b${MARKER}:" 2>/dev/null; then
        # Extract the marker text (everything after MARKER:)
        TEXT=$(echo "$CONTENT" | sed -E "s/.*\b${MARKER}:\s*//" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
        RESULTS=$(echo "$RESULTS" | jq --arg f "$CURRENT_FILE" --argjson l "$LINE_NUM" --arg t "$TEXT" '. + [{"file": $f, "line": $l, "text": $t}]')
      fi
      ((LINE_NUM++)) || true
    elif [[ "$line" =~ ^[^\\] ]]; then
      # Context line (not added, not removed)
      ((LINE_NUM++)) || true
    fi
    # Removed lines (starting with -) don't increment line counter
  fi
done <<< "$DIFF"

echo "$RESULTS" | jq .
