#!/usr/bin/env bash
set -euo pipefail

# Read error file for a repo hash, create if missing
# Input: $1 = repo hash
# Output: JSON on stdout
# Exit 0: always (creates empty structure if missing)

HASH="${1:?Usage: error-file-read.sh <repo-hash>}"
ERROR_DIR="$HOME/.agent/errors"
ERROR_FILE="$ERROR_DIR/$HASH.json"

mkdir -p "$ERROR_DIR"

if [[ ! -f "$ERROR_FILE" ]]; then
  REPO_URL=$(git remote get-url origin 2>/dev/null || pwd)
  jq -n --arg url "$REPO_URL" '{"repo_url": $url, "errors": []}' > "$ERROR_FILE"
fi

jq . "$ERROR_FILE"
