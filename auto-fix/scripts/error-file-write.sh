#!/usr/bin/env bash
set -euo pipefail

# Write updated error JSON to error file (atomic)
# Input: $1 = repo hash, stdin = full JSON content
# Exit 0: success, Exit 1: invalid JSON or write failure

HASH="${1:?Usage: error-file-write.sh <repo-hash>}"
ERROR_DIR="$HOME/.agent/errors"
ERROR_FILE="$ERROR_DIR/$HASH.json"
TMP_FILE="$ERROR_FILE.tmp.$$"

mkdir -p "$ERROR_DIR"

# Read stdin, validate JSON, write atomically
JSON=$(cat)

if ! echo "$JSON" | jq . > "$TMP_FILE" 2>/dev/null; then
  rm -f "$TMP_FILE"
  echo "Invalid JSON" >&2
  exit 1
fi

mv "$TMP_FILE" "$ERROR_FILE"
