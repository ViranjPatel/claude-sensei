# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

claude-sensei is a Claude Code plugin that teaches best practices through tips, quizzes, project audits, and a self-learning engine. It has **no build step, no runtime dependencies, and no tests** — it is entirely declarative: JSON knowledge base + markdown agents/commands/skills + two bash scripts.

Because there is nothing to compile, "correctness" here means *internal consistency*: valid JSON, unique IDs, and cross-file references that actually resolve. Validate by hand or with a throwaway script (see [Validating Changes](#validating-changes)).

## Repository Layout

```
.claude-plugin/plugin.json   manifest (name, version, description, author, license, keywords)
agents/                      4 agent definitions (markdown + YAML frontmatter)
commands/                    6 slash commands (thin dispatchers)
skills/sensei-coaching/      auto-trigger skill: SKILL.md + references/
hooks/hooks.json             SessionStart hook registration
hooks/scripts/session-tip.sh prints a one-line personalized nudge to stderr
knowledge/tips/              7 files, 115 tips
knowledge/quizzes/           7 files, 70 questions
knowledge/audit/rules.json   35 rules across 7 dimensions
scripts/bootstrap.sh         creates .claude-sensei/ in the user's project
```

Everything is auto-discovered by directory convention — `plugin.json` lists no paths, so adding a file to `agents/`, `commands/`, or `knowledge/` is enough to register it.

`$CLAUDE_PLUGIN_ROOT` resolves to this repo's root at runtime; `$CLAUDE_PROJECT_DIR` resolves to the *user's* project. Never hardcode either.

## Agent Dispatch Model

Commands parse arguments and hand off to an agent; agents own all logic and state writes.

| Command | Dispatches to | Purpose |
|---------|---------------|---------|
| `/tips [level] [category]` \| `next`\|`random`\|`list` | tips-agent | Present an unseen tip filtered by level/category/profile |
| `/quiz [category]` \| `all` | quiz-agent | Interactive quiz (5 questions, or 10 for `all`) |
| `/audit [dimension] [--diff] [--fix]` | audit-agent | Scan project, compute Sensei Score |
| `/suggest` | sensei-agent | Exactly 3 recommendations (quick win / project / habit) |
| `/progress [category] [--history]` | sensei-agent | Mastery dashboard |
| `/reset [--confirm]` | *(none — inline)* | Wipes `.claude-sensei/`, re-runs bootstrap |

`/reset` is the one command with no agent: it acts directly and must never delete outside `.claude-sensei/`.

The `sensei-coaching` skill auto-triggers during ordinary work when a user asks about best practices — no slash command required.

### Agent frontmatter

All 4 agents use `name`, `description` (with `<example>` blocks), `model: inherit`, `color`, and an explicit `tools` list.

| Agent | color | tools |
|-------|-------|-------|
| tips-agent | cyan | Read, Edit, Glob, Grep |
| quiz-agent | green | Read, Edit, Glob, Grep |
| audit-agent | yellow | Read, Edit, Write, Glob, Grep, **Bash** |
| sensei-agent | magenta | Read, Edit, Glob, Grep |

- `color` must stay unique across the 4 agents.
- Always `model: inherit` — never hardcode a model.
- audit-agent is the only agent with `Bash` (it needs it for `git_check` rules and `bootstrap.sh`). Don't grant Bash to the others.
- The `<example>` blocks in `description` are load-bearing: they are how Claude Code decides when to route to the agent. Keep the `Context:` / `user:` / `assistant:` / `commentary:` shape when adding one.

## Knowledge Base Conventions

The seven categories are used everywhere and must match exactly:
`memory`, `hooks`, `agents`, `git`, `prompts`, `commands`, `security`

### Tips — `knowledge/tips/[category].json`

A JSON **array** of tip objects. Fields: `id`, `title`, `level`, `category`, `tip`, `example`, `why`, `source`, `tags[]`.
Enums: `level` = beginner|intermediate|advanced; `source` = anthropic-docs|community.

**⚠ Tip ID prefixes are not the category names.** This is the single most common mistake when editing this repo:

| Category | ID prefix | File |
|----------|-----------|------|
| memory | `mem-` | `memory.json` (17 tips) |
| hooks | `hooks-` | `hooks.json` (16) |
| agents | `agent-` | `agents.json` (17) |
| git | `git-` | `git.json` (15) |
| prompts | `prompt-` | `prompts.json` (16) |
| commands | `cmd-` | `commands.json` (18) |
| security | `sec-` | `security.json` (16) |

Format is `[prefix]-[3-digit]` (`mem-001`, `agent-012`). IDs must be unique across the **whole** knowledge base, not just within a file.

### Quizzes — `knowledge/quizzes/[category].json`

A JSON **object**: `{ "category": ..., "questions": [...] }`. 10 questions per file.
Question fields: `id` (`mem-q1`), `difficulty`, `question`, `options[]`, `correct`, `explanation`, `tip_ref`.

- `options` must be exactly 4 strings, each self-labelled `"A) ..."` through `"D) ..."`.
- `correct` is the bare letter `"A"|"B"|"C"|"D"`.
- `tip_ref` must resolve to a real tip ID. All 70 currently do.

### Audit rules — `knowledge/audit/rules.json`

One file, top-level shape `{ "version": 1, "dimensions": {...}, "rules": [...] }`.

`dimensions` maps each of the 7 categories to `{ weight, display }`. The weights are the overall Sensei Score weighting and **must sum to 100**:

| Dimension | weight | display |
|-----------|--------|---------|
| memory | 17 | Memory & Context |
| agents | 17 | Agents & Skills |
| security | 14 | Security & Safety |
| hooks / git / prompts / commands | 13 each | Hooks & Automation / Git Workflow / Prompt Craft / Commands & Config |

`rules` is a **flat array** of 35 rules (5 per dimension), each with:
`id` (`rule-mem-01`), `dimension`, `name`, `weight`, `check`, `pass_msg`, `fail_msg`, `fix_tip`, `belt_min`, plus check-specific fields (`path`, `pattern`, `command`, `field`, `expected`).

Valid `check` values and how audit-agent executes them:

| check | Tool | Passes when |
|-------|------|-------------|
| `glob_exists` (14) | Glob | any file matches `pattern` |
| `file_contains` (11) | Grep | `pattern` found in `path` |
| `json_field_exists` (6) | Read + parse | `field` exists and is non-null in `path` |
| `directory_structure` (2) | Glob | expected layout exists |
| `file_not_contains` (1) | Grep | `pattern` is **absent** (absence is the goal) |
| `git_check` (1) | Bash | the git condition holds |

Scoring: `dimension_score = passing weight / total weight in dimension * 100`, then `sensei_score = Σ(dimension_score × dimension_weight)`. Per-dimension rule weights deliberately do **not** sum to 100 — they are relative within a dimension only.

Note the field name asymmetry: audit rules link to tips via **`fix_tip`**, while quiz questions use **`tip_ref`**. Don't swap them.

## Cross-File Reference Graph

Three link types must always resolve:

- quiz `tip_ref` → tip `id`
- audit rule `fix_tip` → tip `id`
- audit rule `dimension` → key in `dimensions` → category name

## Known Inconsistencies

These are real, present in `master`, and worth knowing before you "fix" something that looks wrong elsewhere.

**1. Ten audit rules have broken `fix_tip` references.** All 10 use the category name instead of the tip ID prefix:

- `rule-agents-01`…`05` point at `agents-001`…`agents-005`; the real IDs are `agent-001`…`agent-005`.
- `rule-prompts-01`…`05` point at `prompts-001`…`prompts-005`; the real IDs are `prompt-001`…`prompt-005`.

The other 25 rules and all 70 quiz `tip_ref`s resolve correctly.

**2. Belt thresholds disagree across four files.** There is no single source of truth today:

| Source | Belts | Thresholds |
|--------|-------|-----------|
| `knowledge-schema.md`, `SKILL.md` | 5 (no Brown) | White 0–19, Yellow 20–39, Green 40–59, Blue 60–79, Black 80–100 |
| `agents/audit-agent.md` | 6 | White 0–20, Yellow 21–40, Green 41–60, Blue 61–80, Brown 81–95, Black 96–100 |
| `README.md` | 6 | White 0–15, Yellow 16–35, Green 36–55, Blue 56–75, Brown 76–90, Black 91–100 |

`rules.json` uses `belt_min: "brown"` on 3 rules, so the 6-belt model is baked into the data — but the profile `belt` enum in `knowledge-schema.md` omits Brown. Touching belts means reconciling all four.

**3. `knowledge-schema.md` is stale in two sections.** It is accurate for **tips**, **quizzes**, and the **learning log**, but its *Audit Rules* and *Learner Profile* sections describe formats that were never shipped:

- It documents rules as an object keyed by dimension with fields `title`/`description`/`check_type`/`target`/`severity`/`auto_fix`/`tip_ref`. The real file uses the flat `rules[]` array described above.
- It documents a profile with `created_at`/`updated_at`/`overall_score`/`categories`/`onboarding_complete`. `bootstrap.sh` actually writes `created`/`last_active`/`sensei_score`/`mastery`.

**When these conflict, `rules.json` and `bootstrap.sh` are the source of truth** — they are what the code reads and writes. `agents/audit-agent.md` also documents the real rule format correctly.

## Self-Learning State

Per-project, created by `scripts/bootstrap.sh` in the **user's** project (not this repo), and gitignored. Agents run the script themselves when `learner-profile.json` is missing.

- **`.claude-sensei/learner-profile.json`** — as written by bootstrap:
  `version`, `created`, `last_active`, `belt`, `sensei_score`, `streak_days`, `total_quizzes`, `total_tips_seen`, `tips_seen[]`, `tips_applied[]`, `audit_history[]`, and `mastery` — a map of the 7 categories to `{ score, trend, quizzes_taken, avg_quiz_score }`. `trend` ∈ improving|stable|declining|new.
- **`.claude-sensei/learning-log.json`** — append-only array, seeded as `[]`. Event fields include `id`, `timestamp`, `event_type`, `category`, `tip_ref`, `quiz_question_id`, `quiz_correct`, `audit_score`, `audit_dimension`, `source`, `notes`.
  `event_type` ∈ tip_viewed|quiz_answered|audit_run|suggestion_shown|coaching_delivered|profile_reset.
  `source` ∈ tips-command|quiz-command|audit-command|suggest-command|progress-command|contextual-coaching|session-hook.
- **`.claude-sensei/last-audit.json`** — snapshot written by audit-agent, read by `/audit --diff`. Not created by bootstrap; absent until the first audit.
- **`.claude-sensei/.session-tip-shown`** — marker touched by `session-tip.sh` to rate-limit the startup nudge to once per hour.

`bootstrap.sh` is idempotent (exits early if `.claude-sensei/` exists) and appends `.claude-sensei/` to the user's `.gitignore`.

## Shell Script Conventions

Both scripts use `set -euo pipefail` and must stay portable between macOS and Linux — the existing code branches on `$OSTYPE` for `stat` (`-f %m` vs `-c %Y`) and `sed -i` (`''` argument vs none). Preserve that pattern.

`session-tip.sh` must **fail open**: it exits 0 when the profile is missing, when `jq` is unavailable, and when a `jq` query returns nothing. A SessionStart hook that errors degrades every session, so never let it exit non-zero. Its output goes to **stderr** (that is what surfaces in the session), and its `timeout` is 10s in `hooks/hooks.json`.

## Validating Changes

There is no test suite, so run these checks after editing `knowledge/`:

```bash
# JSON parses
find knowledge -name '*.json' -exec python3 -c "import json,sys;json.load(open(sys.argv[1]))" {} \;

# Tip IDs unique + all cross-references resolve
python3 - << 'EOF'
import json, glob
tips = {}
for f in glob.glob('knowledge/tips/*.json'):
    for t in json.load(open(f)):
        assert t['id'] not in tips, f"duplicate id {t['id']}"
        tips[t['id']] = t
for f in glob.glob('knowledge/quizzes/*.json'):
    for q in json.load(open(f))['questions']:
        assert len(q['options']) == 4 and q['correct'] in 'ABCD', q['id']
        if q['tip_ref'] not in tips: print('broken tip_ref', q['id'], q['tip_ref'])
d = json.load(open('knowledge/audit/rules.json'))
assert sum(v['weight'] for v in d['dimensions'].values()) == 100
for r in d['rules']:
    if r.get('fix_tip') not in tips: print('broken fix_tip', r['id'], r['fix_tip'])
print(len(tips), 'tips OK')
EOF
```

Also confirm `bash -n scripts/bootstrap.sh hooks/scripts/session-tip.sh` after shell edits.

## How to Run Locally

```bash
claude --plugin-dir "/path/to/claude-sensei"
```

No build, install, or compile step. Use `/reload-plugins` inside a session after editing files. Changes to `hooks/hooks.json` require a fresh session to take effect.

## When Adding Content

- **A new tip**: append to the right `knowledge/tips/[category].json`, use the correct ID prefix from the table above, take the next free number, and fill all 9 fields — `example` and `why` are not optional.
- **A new quiz question**: append to `questions`, use `[prefix]-q[n]`, provide 4 self-labelled options, and point `tip_ref` at a real tip.
- **A new audit rule**: append to the flat `rules[]` array, set `dimension` to one of the 7 categories, pick a `check` from the supported list, and point `fix_tip` at a real tip. Adding a rule changes that dimension's weight denominator, so scores shift.
- **A new category**: this is a wide change — it touches both `knowledge/` subdirectories, `dimensions` in `rules.json` (rebalance weights back to 100), the `mastery` map in `bootstrap.sh`, the category lists in all 6 commands and 4 agents, and `SKILL.md`.

## Agent skills

### Issue tracker

Issues live in GitHub Issues on `ViranjPatel/claude-sensei`, via the `gh` CLI where available and the `mcp__github__*` tools where it isn't. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical roles, each label string equal to its name (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — `CONTEXT.md` at the repo root is the domain glossary; ADRs go in `docs/adr/` (created lazily). See `docs/agents/domain.md`.
