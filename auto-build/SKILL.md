---
name: auto-build
description: Build features from brief instructions, GH issues, or todo files. Interviews user on design, creates TODO.md with vertical work packages, executes each with test-fix loops and individual commits. Use when user runs /auto-build or wants structured feature development.
---

# Auto-Build Skill

SKILL_DIR: `~/.agent/skills/auto-build`

## Phase 1: Input

1. Run: `bash "$SKILL_DIR/scripts/check-dirty-tree.sh"`
   - On exit 0: clean, continue
   - On exit 1: abort — show dirty files from stdout, tell user to commit or stash first

2. Accept input from one of:
   - Brief text instructions (argument or user message)
   - GitHub issue reference → Run: `bash "$SKILL_DIR/scripts/fetch-gh-issue.sh" "$REF"`
     - On exit 0: capture stdout as input text
     - On exit 1: abort with error
   - Path to a todo/spec file — read contents

3. If TODO.md exists in repo root:
   - Run: `bash "$SKILL_DIR/scripts/todo-read-next.sh"` to check for unchecked items
     - On exit 0 (items remain): ask user — resume from unchecked items, or start fresh?
       - If resume → skip to Phase 3 (execute from first unchecked)
       - If fresh → delete existing TODO.md, continue
     - On exit 1 (all checked): start fresh, delete TODO.md
     - On exit 2: no TODO.md, continue normally

## Phase 2: Plan

1. Interview the user relentlessly about every aspect of the raw input until reaching shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. (agent judgment)
2. After reaching shared understanding, build TODO.md:

### TODO.md Structure

```
# <feature summary>

## Decisions

- <key decision from grill>: <answer>
- ...

## Phase 1: <vertical slice name>

- [ ] <work package description>
- [ ] <work package description>

## Phase 2: <vertical slice name>

- [ ] <work package description>
- ...
```

3. Write TODO.md to repo root
4. Commit: `plan: <feature summary>`

## Phase 3: Execute

### Baseline check

Before first package: run tests, auto-fix failures (retry up to 5 times).
- If fixed → commit: `fix: resolve pre-existing test failures`
- If errors cannot be resolved → abort. Do not start packages on a red baseline.

### Per-package loop (in phase order)

1. Run: `bash "$SKILL_DIR/scripts/todo-read-next.sh"`
   - On exit 0: parse JSON `{line, text, phase}` — this is the next package
   - On exit 1: all packages done → go to Cleanup

2. Execute the work package using test-driven development — write tests first, then implement (red-green-refactor). (agent judgment)

3. Run: `bash "$SKILL_DIR/scripts/todo-checkbox.sh" "$LINE"`
   - On exit 1: error — line mismatch, investigate

4. Run tests, auto-fix failures (retry up to 5 times)
5. If tests are still red after retries:
   - Ask user for help
   - If user resolves → re-run tests, continue if green
   - If user says stop → halt execution, report progress

6. Stage all changes (code + TODO.md update)
7. Commit with context-aware prefix: `<prefix>: <package description>`
   - Agent picks prefix based on content: feat:, fix:, refactor:, chore:, etc.

DO NOT proceed to next package if current package's tests are red.

### Cleanup

Run: `bash "$SKILL_DIR/scripts/todo-is-empty.sh"`
- On exit 0: all done — delete TODO.md, include deletion in final package's commit
- On exit 1: unchecked items remain (some skipped)

## Phase 4: Summary

Report:
- Packages completed (with commit hashes)
- Packages skipped (with reason)
- Total commits made

## Anti-Patterns

- DO NOT skip the interview phase — every build gets questioned first.
- DO NOT batch packages. One package = one commit.
- DO NOT proceed if tests are red from a prior package.
- DO NOT leave TODO.md in repo after all packages are done.
- DO NOT interact with GitHub issues post-completion.
- DO NOT start with uncommitted changes in working tree.
