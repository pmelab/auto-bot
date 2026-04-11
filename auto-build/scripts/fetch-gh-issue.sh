#!/usr/bin/env bash
set -euo pipefail

# Fetch a GitHub issue body as plain text
# Input: $1 = issue reference (owner/repo#123 or URL)
# Output: title + body on stdout
# Exit 0: success, Exit 1: gh CLI fails

REF="${1:?Usage: fetch-gh-issue.sh <owner/repo#123 or URL>}"

if ! command -v gh &>/dev/null; then
  echo "gh CLI not installed" >&2
  exit 1
fi

gh issue view "$REF" --json title,body | jq -r '"\(.title)\n\n\(.body)"'
