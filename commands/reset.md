---
name: reset
description: Reset your Claude Sensei learner profile and start fresh. Usage: /reset [--confirm]
---

Reset the Claude Sensei learner profile, wiping all learning history and starting the onboarding process fresh.

## Argument Parsing

Examine the arguments passed after `/reset`:

- **No args**: Do NOT immediately reset. Ask the user for explicit confirmation first. Display a clear warning message explaining what will be deleted and what cannot be undone. Wait for the user to confirm before proceeding.
- **`--confirm`**: Skip the confirmation prompt and proceed directly with the reset. This flag is intended for scripted or automated use cases.

## Confirmation Message (No Args)

When no args are provided, display:

```
Are you sure you want to reset your Claude Sensei profile?

This will permanently delete:
  - .claude-sensei/learner-profile.json  (all belt progress, scores, and mastery data)
  - .claude-sensei/learning-log.json     (all activity history and quiz results)

This action cannot be undone.

To proceed, run: /reset --confirm
To cancel, do nothing.
```

Do not proceed with any deletions until the user explicitly runs `/reset --confirm`.

## Reset Procedure (When Confirmed)

When `--confirm` is provided (or when the user confirms interactively):

1. Delete `.claude-sensei/learner-profile.json` if it exists.
2. Delete `.claude-sensei/learning-log.json` if it exists.
3. Re-run the bootstrap process to create a fresh default profile. Invoke `$CLAUDE_PLUGIN_ROOT/scripts/bootstrap.sh` or, if unavailable, create a new default learner profile from scratch with all scores at zero, belt at "White Belt", and empty seen-tips and quiz-history fields.
4. Display a confirmation message:

```
Profile reset complete.

Your Claude Sensei profile has been cleared and reset to White Belt.
All previous progress, quiz history, and audit scores have been removed.

Run /tips to get your first tip and begin your learning journey.
```

## Safety Rules

- Never silently delete files. Always log what was deleted and confirm completion.
- If a file does not exist, skip it without error — a missing file is not a failure condition.
- If the bootstrap script is not found, create a minimal valid default profile inline rather than failing.
- Do not touch any files outside `.claude-sensei/`. Never delete knowledge base files, hook scripts, or any other plugin files.
