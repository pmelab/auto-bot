#!/usr/bin/env bash
set -euo pipefail

# Scan stdin text for imperative language patterns
# Input: stdin = text to scan
# Output: JSON array [{keyword, sentence}] on stdout
# Exit 0 always

INPUT=$(cat)

if [[ -z "$INPUT" ]]; then
  echo "[]"
  exit 0
fi

RESULTS="[]"

while IFS= read -r line; do
  # Extract the keyword that matched
  KEYWORD=$(echo "$line" | grep -oiE '\b(always|never|must|don.t|do not|prefer|avoid|ensure|require)\b' | head -1 | tr '[:upper:]' '[:lower:]')
  SENTENCE=$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
  if [[ -n "$KEYWORD" && -n "$SENTENCE" ]]; then
    RESULTS=$(echo "$RESULTS" | jq --arg k "$KEYWORD" --arg s "$SENTENCE" '. + [{"keyword": $k, "sentence": $s}]')
  fi
done < <(echo "$INPUT" | grep -iE '\b(always|never|must|don.t|do not|prefer|avoid|ensure|require)\b' || true)

echo "$RESULTS" | jq .
