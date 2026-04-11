# auto-bot

Agent-agnostic skills for automated development workflows. Each skill is a self-contained procedure that any AI coding agent can follow — no vendor lock-in.

## Skills

| Skill | What it does |
|---|---|
| **auto-fix** | Run tests, auto-fix failures, track recurring errors per repo. Escalates persistent errors for deterministic enforcement. |
| **auto-learn** | Turn a lesson into deterministic enforcement — type constraints, linter rules, or AGENTS.md rules. Prefers machine-checkable enforcement over prose rules. |
| **auto-build** | Build features from brief instructions, GH issues, or todo files. Interviews user on design, executes vertical work packages with test-fix loops and individual commits. |
| **auto-refactor** | Extract RF/TODO markers from code and REFACTOR.md, interview user on each, execute refactors with tests and individual commits. |

## How they work together

Skills reference each other through action-oriented prose rather than hard dependencies. If a companion skill is installed, the agent will use it. If not, the agent improvises.

```
auto-build ──interviews user──▶ (grill-me if available)
     │
     ├──run tests, auto-fix──▶ (auto-fix if available)
     │
auto-refactor ──interviews user──▶ (grill-me if available)
     │
     ├──run tests, auto-fix──▶ (auto-fix if available)
     ├──enforce learning──▶ (auto-learn if available)
     │
auto-fix ──escalate error──▶ (auto-learn if available)
     │
auto-learn ──verify──▶ (auto-fix if available)
```

## Setup

Each skill expects a test command in your project's `AGENTS.md`:

```
test command: npm test
```

## Recommended companion skills

These external skills pair well with auto-bot. Install from [mattpocock/skills](https://github.com/mattpocock/skills):

| Skill | Why |
|---|---|
| **[grill-me](https://github.com/mattpocock/skills/tree/main/grill-me)** | auto-build and auto-refactor use interview prose that triggers this skill when installed. Provides structured design interrogation. |
| **[tdd](https://github.com/mattpocock/skills/tree/main/tdd)** | Complements auto-fix's test-fix loop with red-green-refactor discipline. |
| **[improve-codebase-architecture](https://github.com/mattpocock/skills/tree/main/improve-codebase-architecture)** | Finds refactoring opportunities — natural feeder for auto-refactor. |
| **[setup-pre-commit](https://github.com/mattpocock/skills/tree/main/setup-pre-commit)** | Pairs with auto-learn's enforcement philosophy — pre-commit hooks as deterministic enforcement. |
| **[write-a-skill](https://github.com/mattpocock/skills/tree/main/write-a-skill)** | For extending the auto-bot suite with new skills. |
