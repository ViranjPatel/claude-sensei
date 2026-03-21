---
name: suggest
description: Get quick personalized Claude Code improvement recommendations. Usage: /suggest
---

Provide fast, personalized improvement recommendations without running a full project audit. This command is intentionally lightweight — do not perform file-system scanning or load heavy knowledge base files.

## What to Read

Read only these two sources:

1. `.claude-sensei/learner-profile.json` — to understand the user's current belt level, category scores, and recent activity.
2. `.claude-sensei/learning-log.json` — to see recent interactions, tips viewed, quiz results, and audit history (last 10 entries are sufficient).

Do not read audit rules, full tips files, or quiz banks. Speed is the priority.

## Dispatch Instructions

After reading the profile and log, dispatch to the sensei-agent with the following instruction: generate exactly 3 improvement recommendations tailored to this specific user.

## The 3 Recommendation Types

Structure the output as exactly three items:

**1. Quick Win**
Something the user can do right now, in under 5 minutes, that will immediately improve their Claude Code setup. Base this on the lowest-scoring category in their profile or a recently failed audit check. Keep it concrete and actionable.

**2. Project Improvement**
A medium-effort improvement (15–60 minutes) tied to their current project context if detectable, or their overall skill gaps. Reference a specific tip ID if applicable.

**3. Habit to Build**
A recurring practice or behavioral pattern that will compound over time. Base this on learning-log patterns — for example, if the user rarely runs `/audit`, suggest making it a weekly habit.

## Output Format

```
Here are 3 personalized suggestions for you:

Quick Win
---------
[Specific action, e.g., "Add your test command to CLAUDE.md right now — open it and add a ## Validation Commands section."]

Project Improvement
-------------------
[Medium-effort suggestion tied to their profile/project]
Tip reference: [tip-id if applicable]

Habit to Build
--------------
[Recurring practice recommendation]
```

End with a brief note about which command to run next if they want to go deeper: `/tips`, `/quiz`, `/audit`, or `/progress`.
