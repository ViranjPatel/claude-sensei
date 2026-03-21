# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

claude-sensei is a Claude Code plugin that teaches best practices through tips, quizzes, project audits, and a self-learning engine. It has no build step, no runtime dependencies, and no tests — it is entirely declarative (JSON knowledge base + markdown agents/commands/skills).

## Plugin Architecture

The plugin follows Claude Code's plugin spec with auto-discovery:

- **`.claude-plugin/plugin.json`** — manifest (name, version, author)
- **`agents/`** — 4 specialized agents, each with YAML frontmatter (`name`, `description` with `<example>` blocks, `model: inherit`, `color`, `tools`)
- **`commands/`** — 6 slash commands with YAML frontmatter (`name`, `description`), each dispatches to an agent
- **`skills/sensei-coaching/`** — auto-trigger skill with `SKILL.md` + `references/` directory
- **`hooks/hooks.json`** — SessionStart hook that runs `hooks/scripts/session-tip.sh`
- **`knowledge/`** — read-only JSON data files (tips, quizzes, audit rules)
- **`scripts/bootstrap.sh`** — initializes `.claude-sensei/` in the user's project (gitignored)

## Agent Dispatch Model

Commands are thin dispatchers — they parse arguments and invoke agents:

| Command | Agent | Purpose |
|---------|-------|---------|
| `/tips` | tips-agent | Presents tips filtered by level/category/profile |
| `/quiz` | quiz-agent | Runs interactive quiz sessions |
| `/audit` | audit-agent | Scans project, computes Sensei Score |
| `/suggest` | sensei-agent | Quick personalized recommendations |
| `/progress` | sensei-agent | Learning dashboard with mastery bars |
| `/reset` | (direct) | Wipes `.claude-sensei/` and re-bootstraps |

The `sensei-coaching` skill auto-triggers during regular work when users ask about best practices — it does NOT require a slash command.

## Knowledge Base Conventions

All content lives in `knowledge/` as structured JSON. The schema is defined in `skills/sensei-coaching/references/knowledge-schema.md`.

- **Tips**: `knowledge/tips/[category].json` — arrays of tip objects. 7 files, 115 tips total. ID format: `mem-001`, `hooks-003`, `agent-012`, etc.
- **Quizzes**: `knowledge/quizzes/[category].json` — objects with `category` + `questions` array. 7 files, 70 questions. 4 options per question, `correct` is `"A"|"B"|"C"|"D"`.
- **Audit rules**: `knowledge/audit/rules.json` — keyed by dimension. 35 rules across 7 dimensions. Check types: `file_exists`, `file_contains`, `file_not_contains`, `command_succeeds`, `directory_exists`, `json_field_exists`.

Categories used everywhere: `memory`, `hooks`, `agents`, `git`, `prompts`, `commands`, `security`.

## Self-Learning State

Per-project state stored in `.claude-sensei/` (gitignored, created by `scripts/bootstrap.sh`):

- `learner-profile.json` — belt level, per-category mastery scores, tips seen, quiz accuracy, audit history
- `learning-log.json` — append-only event journal for the Karpathy loop (act/observe/reflect/adapt)

Belt thresholds: White 0-19, Yellow 20-39, Green 40-59, Blue 60-79, Black 80-100.

## Key Conventions When Editing

- Tip IDs must be unique within their category file and follow `[prefix]-[3-digit]` format
- Quiz `tip_ref` fields must reference valid tip IDs
- Audit rule `tip_ref` fields link failures to learning tips
- Agent `color` values must be unique across all 4 agents (currently: cyan, green, yellow, magenta)
- Agents use `model: inherit` — never hardcode a model
- The `$CLAUDE_PLUGIN_ROOT` variable resolves to this repo's root at runtime

## How to Run Locally

```bash
claude --plugin-dir "/path/to/claude-sensei"
```

No build, install, or compile step needed. Use `/reload-plugins` inside a session after editing files.
