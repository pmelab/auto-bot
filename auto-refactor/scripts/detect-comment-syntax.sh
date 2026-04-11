#!/usr/bin/env bash
set -euo pipefail

# Return comment prefix for a given file extension
# Input: $1 = file path or extension (e.g. .ts, foo.py)
# Output: comment prefix string on stdout
# Exit 0: known, Exit 1: unknown extension

INPUT="${1:?Usage: detect-comment-syntax.sh <file-or-ext>}"

# Extract extension
EXT="${INPUT##*.}"
EXT="${EXT,,}" # lowercase

case "$EXT" in
  js|ts|tsx|jsx|java|c|cpp|cs|go|rs|swift|kt|kts)
    echo "//"
    ;;
  py|rb|sh|bash|zsh|fish|yaml|yml|toml|pl|r)
    echo "#"
    ;;
  lua|sql|hs|elm)
    echo "--"
    ;;
  html|xml|svelte|vue|md)
    echo "<!--"
    ;;
  css|scss|less)
    echo "/*"
    ;;
  *)
    echo "Unknown extension: $EXT" >&2
    exit 1
    ;;
esac
