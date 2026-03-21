---
name: progress
description: View your Claude Code learning journey and mastery scores. Usage: /progress [category] [--history]
---

Parse the arguments provided to this command and dispatch to the sensei-agent to render the user's learning progress.

## Argument Parsing

Examine the arguments passed after `/progress`:

- **No args**: Display the full learning dashboard — overall belt level, scores for all categories, recent activity, and next recommended actions.
- **A category name** (`memory`, `hooks`, `agents`, `git`, `prompts`, `commands`, `security`): Display a deep-dive view for that single category, including tips seen, quiz performance, audit scores, and specific gaps remaining.
- **`--history`**: Show how scores have changed over time, drawing from the audit history stored in the learner profile and learning log. Display a timeline or trend summary for each category.
- **Category + `--history`**: Deep-dive into a single category with its full score history.

## Valid Categories

`memory`, `hooks`, `agents`, `git`, `prompts`, `commands`, `security`

## Dispatch Instructions

After parsing args, dispatch to the sensei-agent with the following context:

1. The display mode: `dashboard`, `category-deep-dive`, `history`, or `category-history`.
2. The selected category (if applicable).
3. The learner profile path: `.claude-sensei/learner-profile.json`
4. The learning log path: `.claude-sensei/learning-log.json`

The sensei-agent is responsible for:
- Reading the learner profile to extract belt level, category scores, tips seen count, quiz accuracy by category, and last audit results.
- Reading the learning log to extract recent activity and score change events.
- Rendering the appropriate view based on the parsed mode.

## Dashboard Output Format

```
Claude Sensei — Learning Dashboard
===================================
Belt Level: [Belt Name] ([overall score]/100)

Category Mastery
----------------
Memory       [████████░░] [score]/100  [tips seen]/[total] tips  [quiz accuracy]% quiz
Hooks        [██████░░░░] [score]/100  ...
Agents       [████░░░░░░] [score]/100  ...
Git          [███████░░░] [score]/100  ...
Prompts      [██████████] [score]/100  ...
Commands     [█████░░░░░] [score]/100  ...
Security     [███░░░░░░░] [score]/100  ...

Recent Activity
---------------
- [date]: [activity description]
- [date]: [activity description]

Next Steps
----------
Focus area: [weakest category] — try `/tips [weakest]` or `/quiz [weakest]`
```

## Category Deep-Dive Format

When a specific category is provided, show:
- Category score and trend (improving/stable/declining).
- Tips seen vs total available, with IDs of unseen tips.
- Quiz performance: questions attempted, accuracy rate, most missed question.
- Last audit result for this dimension.
- Specific gaps: what to learn next.

## History Format

When `--history` is provided, show score progression over time for each category (or the selected category). Use the audit snapshots from the learning log, sorted by date. Highlight the biggest improvements and any regressions.
