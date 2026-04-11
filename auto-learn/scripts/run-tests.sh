#!/usr/bin/env bash
set -euo pipefail

# Run test command and capture output + exit code
# Input: $1 = test command string
# Output: JSON {"passed": bool, "exit_code": int, "output": "..."} on stdout
# Exit 0: always (test pass/fail encoded in JSON)

CMD="${1:?Usage: run-tests.sh '<test command>'}"

OUTPUT_FILE=$(mktemp)
trap 'rm -f "$OUTPUT_FILE"' EXIT

EXIT_CODE=0
eval "$CMD" > "$OUTPUT_FILE" 2>&1 || EXIT_CODE=$?

# Truncate to last 200 lines
OUTPUT=$(tail -200 "$OUTPUT_FILE")

if [[ $EXIT_CODE -eq 0 ]]; then
  PASSED=true
else
  PASSED=false
fi

jq -n \
  --argjson passed "$PASSED" \
  --argjson exit_code "$EXIT_CODE" \
  --arg output "$OUTPUT" \
  '{"passed": $passed, "exit_code": $exit_code, "output": $output}'
