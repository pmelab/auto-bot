---
name: auto-fix
description: Run tests, auto-fix failures, track recurring errors per repo. Use when running tests, or invoked by other skills (e.g. refactor). Escalates persistent errors for deterministic enforcement.
---

# Auto-Fix Skill

SKILL_DIR: `~/.agent/skills/auto-fix`

## Phase 1: Setup

1. Run: `bash "$SKILL_DIR/scripts/get-test-command.sh"`
   - On exit 0: capture stdout as `$TEST_CMD`
   - On exit 1: abort — "No test command found in AGENTS.md. Add `test command: <cmd>` before running /auto-fix."

2. Run: `bash "$SKILL_DIR/scripts/get-repo-hash.sh"`
   - On exit 0: capture stdout as `$REPO_HASH`

3. Run: `bash "$SKILL_DIR/scripts/error-file-read.sh" "$REPO_HASH"`
   - Capture JSON as `$ERROR_DATA`

## Phase 2: Run + Fix Loop

1. Run: `bash "$SKILL_DIR/scripts/run-tests.sh" "$TEST_CMD"`
   - Parse JSON output: `{passed, exit_code, output}`
2. If `passed == true` → go to Phase 3
3. If `passed == false`:
   a. Analyze failure output (agent judgment)
   b. Apply fix (agent judgment)
   c. Run: `bash "$SKILL_DIR/scripts/run-tests.sh" "$TEST_CMD"` again
   d. Repeat up to 5 attempts total
   e. After 5 failures → ask user for help, then stop

Return result: `{ passed: boolean, error_output?: string }`

## Phase 3: Error Tracking

1. Run: `bash "$SKILL_DIR/scripts/error-file-read.sh" "$REPO_HASH"` to get current entries
2. For each distinct error in test output (agent judgment — match by similarity of error message/type, ignoring line numbers, timestamps, file paths):
   a. If match found in existing entries → increment `count`, update `last_seen`
   b. If no match → add new entry with `count: 1`, `first_seen: now`, `last_seen: now`
3. Check for escalation: if any entry has `count >= 3`:
   - Follow the /auto-learn skill procedure to turn the error into deterministic enforcement, passing the full error entry as input. Then remove the entry.
   - If enforcement cannot be applied: log warning, keep entry
4. Write updated JSON:
   Run: `echo '$UPDATED_JSON' | bash "$SKILL_DIR/scripts/error-file-write.sh" "$REPO_HASH"`

## Phase 4: Report

Output:
- Test result: pass/fail
- Errors tracked (new + recurring with counts)
- Escalations triggered (if any)

## Anti-Patterns

- DO NOT guess test command — require it in AGENTS.md with exact format `test command: <cmd>`.
- DO NOT retry more than 5 times — ask user after 5.
- DO NOT skip error tracking even if tests pass (pass = no new errors, but still report).
- DO NOT use heuristic matching — agent judges error similarity.
- DO NOT delete error file — only remove individual entries on escalation.
