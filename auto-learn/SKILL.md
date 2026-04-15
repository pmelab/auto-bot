---
name: auto-learn
description: Turn a learning into deterministic enforcement (types, linters, new tools) or AGENTS.md rule. Use when recurring errors are escalated, when refactoring extracts imperative rules, or when user wants to codify a lesson.
---

# Auto-Learn Skill

SKILL_DIR: `~/.agent/skills/auto-learn`

## Phase 1: Normalize Input

Input may be:
- Natural language rule from user (e.g. "never use any types")
- Error entry from test-fix escalation (`{ error_output, first_seen, last_seen, count, test_command }`)
- Imperative rule extracted during refactoring (e.g. "always validate inputs with zod")

Extract the core learning as a single imperative statement: "Never X" / "Always Y" / "Prefer X over Y". (agent judgment)

Present the extracted learning to user for confirmation before proceeding.

## Phase 2: Explore Enforcement Options

1. Run: `bash "$SKILL_DIR/scripts/discover-toolchain.sh"`
   - Parse JSON checklist: `{eslint, biome, prettier, ruff, clippy, golangci, typescript, mypy, pyright, ci_github, package_manager}`

2. Using the toolchain checklist, find up to 3 enforcement options ranked by determinism (agent judgment):
   a. **Type system** — can a type constraint prevent this?
   b. **Existing linter rule** — is there a built-in or plugin rule that catches this?
   c. **New tool/plugin** — would adding a linter, plugin, or custom rule catch this?
   d. **AGENTS.md** — fallback: add as a rule for the agent to follow

3. For each option, describe:
   - What it enforces
   - What changes are needed (config, install, types)
   - Existing violations it would surface (count, not full list)

## Phase 3: Propose to User

Present ranked options using AskUserQuestion:
- Each option: name + what it enforces + effort
- AGENTS.md always last (unless it's the only option)
- User can pick one, pick multiple, or suggest alternative

If user suggests alternative → re-analyze, propose concrete implementation, get approval, loop until agreement.

## Phase 4: Execute

For the chosen enforcement:

1. **If deterministic (type/linter/tool):**
   - Install packages if needed
   - Add/enable rule or type constraint
   - Run the linter/type checker to report existing violations (list them, do not fix)
   - Commit: `chore: add <tool> rule for <learning summary>`

2. **If AGENTS.md:**
   - Run: `bash "$SKILL_DIR/scripts/check-agents-md.sh" "$RULE"`
     - On exit 0: duplicate found — show matching line, skip
     - On exit 1: not found — append rule to AGENTS.md (create if missing)
   - Format: `- <imperative rule>`
   - Do NOT add to AGENTS.md if enforcement is deterministic
   - Commit: `chore: add rule to AGENTS.md — <learning summary>`

## Phase 5: Verify

Follow the /auto-fix skill procedure to run tests and fix failures. Confirm:
- Tests still pass after config changes
- New rule/type constraint is active

If still failing → fix config issues only (not existing violations), then ask user.

## Phase 6: Report

Output:
- Learning: the imperative statement
- Enforcement: what was added (tool + rule, or AGENTS.md)
- Violations: count of existing violations found (if any)
- Commits: list of commits made

## Anti-Patterns

- DO NOT fix existing violations — only configure enforcement + report them.
- DO NOT add to AGENTS.md if a deterministic enforcement was applied.
- DO NOT skip user approval — always present options first.
- DO NOT execute without confirming the extracted learning is correct.
- DO NOT suggest tools that conflict with the project's existing toolchain.
