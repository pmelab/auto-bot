---
name: auto-refactor
description: Extract RF/TODO markers from git diff and REFACTOR.md, interview user on each, then execute refactors with tests and individual commits. Use when user runs /auto-refactor or wants structured refactoring sessions.
---

# Auto-Refactor Skill

SKILL_DIR: `~/.agent/skills/auto-refactor`

## Phase 1: Extract

1. Run: `bash "$SKILL_DIR/scripts/check-dirty-tree.sh" REFACTOR.md`
   - On exit 0: clean, continue
   - On exit 1: abort — show dirty files from stdout, tell user to commit or stash first

2. Run: `bash "$SKILL_DIR/scripts/extract-markers.sh" "$MARKER"`
   - `$MARKER` = first argument or `RF` if none passed
   - Capture JSON array: `[{file, line, text}]`

3. Run: `bash "$SKILL_DIR/scripts/parse-refactor-md.sh"`
   - Capture JSON array: `[{line, text}]`

4. Build unified task list from both sources: `{source, file, line, text}`
5. Present numbered list to user

If both arrays empty → abort: "No `$MARKER` comments in git diff and no REFACTOR.md found."

## Phase 1b: Review Commit

Commit all current changes (RF code comments + REFACTOR.md) as-is:
- Message: `review: <brief summary of items>`
- This preserves the review intent in git history before any refactoring begins

## Phase 2: Interview

For each item (one at a time):

1. Read surrounding code context (±30 lines for code markers; for REFACTOR.md items, explore relevant files)
2. Follow the /grill-me skill procedure to ask clarifying questions:
   - What's the desired end state?
   - Any constraints (backwards compat, API stability, performance)?
   - Should this be combined with another item?
3. After shared understanding is reached, write a concrete execution plan for that item
4. Get user approval on the item's plan

After all items interviewed:
- Analyze dependencies between ALL items
- Present full ordered execution plan (dependency-aware order)
- Get final approval before proceeding

## Phase 2b: Rule Extraction

Run: `echo "$ALL_ITEM_TEXTS" | bash "$SKILL_DIR/scripts/extract-imperative-patterns.sh"`
- Parse JSON array: `[{keyword, sentence}]`
- For each match: follow the /auto-learn skill procedure to turn the learning into deterministic enforcement
- Skip if no matches

## Phase 3: Execute

### Per-item loop (in dependency order)

1. Execute the refactoring per the approved plan (agent judgment)
2. Remove the marker:
   - For code markers: `bash "$SKILL_DIR/scripts/remove-marker-line.sh" "$FILE" "$LINE"`
   - For REFACTOR.md items: `bash "$SKILL_DIR/scripts/remove-refactor-bullet.sh" "$LINE"`
     - On exit 2: REFACTOR.md now empty, will delete in cleanup
3. Follow the /auto-fix skill procedure to run tests and fix failures.
4. If tests are still red after retries → stop, do not proceed
5. Stage all changes for this item
6. Commit: `refactor: <description from item>`

DO NOT proceed to next item if current item's tests are red.

### Cleanup

Run: `bash "$SKILL_DIR/scripts/refactor-md-is-empty.sh"`
- On exit 0: delete REFACTOR.md, include in final refactor commit
- On exit 1: items remain (some were skipped)
- On exit 2: file already gone

## Phase 4: Summary

Report:
- Items completed (with commit hashes)
- Items skipped (with reason)
- Learnings enforced (if any)

## Anti-Patterns

- DO NOT batch refactors. One refactor = one commit.
- DO NOT proceed if tests are red from a prior item.
- DO NOT remove RF comments that haven't been executed yet.
- DO NOT skip the interview phase — every item gets questioned.
- DO NOT leave REFACTOR.md in repo after all items are done.
