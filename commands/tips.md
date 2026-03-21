---
name: tips
description: Learn Claude Code best practices. Usage: /tips [level] [category] or /tips next|random|list
---

Parse the arguments provided to this command and dispatch to the tips-agent accordingly.

## Argument Parsing

Examine the arguments passed after `/tips`:

- **No args**: Deliver a personalized tip based on the learner profile. Read `.claude-sensei/learner-profile.json` to determine the user's current belt level and weakest category, then surface a tip they have not yet seen.
- **`next`**: Deliver the next unseen tip in the current learning sequence (based on profile progress).
- **`random`**: Pick a random tip from the full knowledge base, regardless of level or category.
- **`list`**: Display a summary index of all available tips, grouped by category and level, with IDs.
- **Single arg matching a level** (`beginner`, `intermediate`, `advanced`): Filter tips to that level and pick the most relevant unseen one for the user.
- **Single arg matching a category** (`memory`, `hooks`, `agents`, `git`, `prompts`, `commands`, `security`): Filter tips to that category and deliver the most relevant unseen one.
- **Two args — level then category** (e.g., `/tips intermediate hooks`): Deliver a tip matching both the specified level and category.
- **Two args — category then level** (e.g., `/tips hooks intermediate`): Same behavior as above, order-independent.

## Valid Categories

`memory`, `hooks`, `agents`, `git`, `prompts`, `commands`, `security`

## Valid Levels

`beginner`, `intermediate`, `advanced`

## Dispatch Instructions

After parsing args, invoke the tips-agent with the following context:

1. The resolved filter parameters (level, category, or "personalized").
2. The path to the learner profile: `.claude-sensei/learner-profile.json`
3. The tips knowledge base location: `$CLAUDE_PLUGIN_ROOT/knowledge/tips/`

The tips-agent is responsible for:
- Reading the appropriate category file(s) from the knowledge base.
- Selecting the correct tip based on the filter and the user's seen-tips list in the profile.
- Presenting the tip with: title, the tip body, a concrete example, the "why", and the tip ID.
- Updating the learner profile to mark the tip as seen and record the interaction timestamp.
- Suggesting a related follow-up action (e.g., a quiz question or an audit check).

## Format

Present tips in a clear, readable format. Include the tip ID (e.g., `mem-007`) so the user can reference it later. End with a brief prompt suggesting next steps such as `/quiz memory` or `/audit`.
