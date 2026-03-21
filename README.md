# Claude Sensei

A Claude Code plugin that teaches you best practices through tips, quizzes, project audits, and a self-learning engine powered by Karpathy's learning loop.

## Features

- **`/tips`** - 115 best practice tips across 3 levels (beginner, intermediate, advanced) and 7 categories
- **`/quiz`** - 70 interactive quiz questions across 7 categories to test your knowledge
- **`/audit`** - Opinionated project scanner with Sensei Score, belt system, and improvement roadmap
- **`/suggest`** - Quick personalized recommendations based on your learning profile
- **`/progress`** - Visual dashboard of your mastery journey with trend tracking
- **`/reset`** - Start fresh with a clean learner profile

## Self-Learning Engine

Claude Sensei gets smarter the more you use it. Built on Karpathy's learning loop:

**Act** (try a skill) -> **Observe** (track outcomes) -> **Reflect** (identify gaps) -> **Adapt** (personalize next steps)

- Tracks quiz scores and audit results over time
- Prioritizes tips for your weakest areas
- Detects learning plateaus and nudges you forward
- Spaced repetition for quiz questions you struggle with

## Belt System

Your Sensei Score determines your belt level:

| Belt | Score | Meaning |
|------|-------|---------|
| White | 0-15 | Just getting started |
| Yellow | 16-35 | Foundations in place |
| Green | 36-55 | Solid practitioner |
| Blue | 56-75 | Advanced user |
| Brown | 76-90 | Near mastery |
| Black | 91-100 | Claude Code sensei |

## Categories

| Category | Tips | Quiz Questions | Audit Rules |
|----------|------|----------------|-------------|
| Memory & Context | 17 | 10 | 5 |
| Hooks & Automation | 16 | 10 | 5 |
| Agents & Skills | 17 | 10 | 5 |
| Git Workflow | 15 | 10 | 5 |
| Prompt Craft | 16 | 10 | 5 |
| Commands | 18 | 10 | 5 |
| Security | 16 | 10 | 5 |
| **Total** | **115** | **70** | **35** |

## Installation

```bash
claude --plugin-dir /path/to/claude-sensei
```

Or add a shell alias for convenience:

```bash
alias claude-sensei='claude --plugin-dir /path/to/claude-sensei'
```

## Architecture

```
claude-sensei/
├── .claude-plugin/plugin.json    # Plugin manifest
├── agents/                       # 4 specialized agents
│   ├── tips-agent.md             # Retrieves and presents tips
│   ├── quiz-agent.md             # Runs interactive quizzes
│   ├── audit-agent.md            # Scans projects, scores maturity
│   └── sensei-agent.md           # Meta-agent, personalizes everything
├── commands/                     # 6 slash commands
├── skills/sensei-coaching/       # Auto-trigger skill for best practice questions
├── knowledge/                    # Structured knowledge base
│   ├── tips/                     # 7 JSON files, 115 tips
│   ├── quizzes/                  # 7 JSON files, 70 questions
│   └── audit/rules.json          # 35 audit rules
├── hooks/                        # SessionStart hook (tip of the day)
└── scripts/bootstrap.sh          # Initializes learner profile
```

## Quick Start

1. Install the plugin (see above)
2. Run `/audit` to get your baseline Sensei Score
3. Run `/tips` to start learning from your weakest area
4. Run `/quiz` to test what you've learned
5. Run `/progress` to see how far you've come

## License

MIT
