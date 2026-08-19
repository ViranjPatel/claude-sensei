# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

**Layout: single-context.** One `CONTEXT.md` and one `docs/adr/` at the repo root. There is no
`CONTEXT-MAP.md` and no per-package context — claude-sensei is a single declarative plugin, not a
monorepo.

## Before exploring, read these

- **`CONTEXT.md`** at the repo root
- **`docs/adr/`** — read ADRs that touch the area you're about to work in

If any of these files don't exist, **proceed silently**. Don't flag their absence; don't suggest creating them upfront. The `/domain-modeling` skill (reached via `/grill-with-docs` and `/improve-codebase-architecture`) creates them lazily when terms or decisions actually get resolved.

As of this setup, neither exists yet. That is the expected starting state.

## File structure

```
/
├── CLAUDE.md
├── CONTEXT.md          ← created lazily by /domain-modeling
├── docs/
│   ├── adr/            ← created lazily by /domain-modeling
│   └── agents/         ← this directory (skill configuration)
├── agents/
├── commands/
├── knowledge/
└── skills/
```

Note the two distinct `agents`-named directories, which are unrelated:

- **`agents/`** at the root — the plugin's own four Claude Code subagent definitions (product code)
- **`docs/agents/`** — configuration *for* the engineering skills (this file's home)

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `CONTEXT.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal — either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

Existing vocabulary is documented in `CLAUDE.md` today — belt levels, Sensei Score, tips,
quizzes, audit rules, the seven categories. Treat that as the de facto glossary until a
`CONTEXT.md` supersedes it.

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…_
