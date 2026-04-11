#!/usr/bin/env bash
set -euo pipefail

# Compute MD5 hash of repo identity for error file keying
# Output: 32-char hex hash on stdout
# Exit 0: success, Exit 1: not a git repo

if ! git rev-parse --show-toplevel &>/dev/null; then
  echo "Not a git repository" >&2
  exit 1
fi

REPO_ID=$(git remote get-url origin 2>/dev/null || pwd)

if command -v md5 &>/dev/null; then
  echo -n "$REPO_ID" | md5 -q
elif command -v md5sum &>/dev/null; then
  echo -n "$REPO_ID" | md5sum | cut -d' ' -f1
else
  echo "Neither md5 nor md5sum found" >&2
  exit 1
fi
