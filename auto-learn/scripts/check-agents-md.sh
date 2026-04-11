#!/usr/bin/env bash
set -euo pipefail

# Check if a rule already exists in AGENTS.md (case-insensitive substring match)
# Input: $1 = rule text to search for
# Exit 0: rule found (duplicate), stdout = matching line
# Exit 1: not found or AGENTS.md missing

RULE="${1:?Usage: check-agents-md.sh '<rule text>'}"
AGENTS_FILE="$(git rev-parse --show-toplevel 2>/dev/null)/AGENTS.md"

if [[ ! -f "$AGENTS_FILE" ]]; then
  exit 1
fi

MATCH=$(grep -Fi "$RULE" "$AGENTS_FILE" || true)

if [[ -n "$MATCH" ]]; then
  echo "$MATCH"
  exit 0
else
  exit 1
fi
