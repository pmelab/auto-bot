#!/usr/bin/env bash
set -euo pipefail

# Extract test command from AGENTS.md (strict pattern: "test command: <cmd>")
# Output: plain text command on stdout
# Exit 0: found, Exit 1: not found or AGENTS.md missing

AGENTS_FILE="$(git rev-parse --show-toplevel 2>/dev/null)/AGENTS.md"

if [[ ! -f "$AGENTS_FILE" ]]; then
  echo "AGENTS.md not found at repo root" >&2
  exit 1
fi

CMD=$(grep -m1 '^test command:' "$AGENTS_FILE" | sed 's/^test command: *//')

if [[ -z "$CMD" ]]; then
  echo "No 'test command: <cmd>' line found in AGENTS.md" >&2
  exit 1
fi

echo "$CMD"
