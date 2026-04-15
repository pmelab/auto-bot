#!/usr/bin/env bash
set -euo pipefail

# Check off a TODO.md item by line number: - [ ] → - [x]
# Input: $1 = line number
# Exit 0: success, Exit 1: line doesn't contain - [ ]

LINE="${1:?Usage: todo-checkbox.sh <line-number>}"
TODO_FILE="$(git rev-parse --show-toplevel 2>/dev/null)/TODO.md"

if [[ ! -f "$TODO_FILE" ]]; then
  echo "TODO.md not found" >&2
  exit 1
fi

# Verify line contains unchecked box
if ! sed -n "${LINE}p" "$TODO_FILE" | grep -q '\- \[ \]'; then
  echo "Line $LINE does not contain '- [ ]'" >&2
  exit 1
fi

sed "${LINE}s/- \[ \]/- [x]/" "$TODO_FILE" > "$TODO_FILE.tmp" && mv "$TODO_FILE.tmp" "$TODO_FILE"
