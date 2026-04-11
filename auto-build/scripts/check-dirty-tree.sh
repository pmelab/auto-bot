#!/usr/bin/env bash
set -euo pipefail

# Check if working tree has uncommitted changes (beyond allowlisted files)
# Input: $@ = allowlisted file patterns (e.g. REFACTOR.md)
# Exit 0: clean (or only allowlisted), Exit 1: dirty with non-allowlisted files
# stdout: list of dirty files when exit 1

ALLOWLIST=("$@")

DIRTY_FILES=$(git status --porcelain | awk '{print $2}')

if [[ -z "$DIRTY_FILES" ]]; then
  exit 0
fi

NON_ALLOWED=""
while IFS= read -r file; do
  ALLOWED=false
  for pattern in "${ALLOWLIST[@]}"; do
    if [[ "$file" == $pattern ]]; then
      ALLOWED=true
      break
    fi
  done
  if [[ "$ALLOWED" == false ]]; then
    NON_ALLOWED+="$file"$'\n'
  fi
done <<< "$DIRTY_FILES"

if [[ -z "$NON_ALLOWED" ]]; then
  exit 0
fi

echo -n "$NON_ALLOWED"
exit 1
