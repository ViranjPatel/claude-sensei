---
name: sensei-coaching
description: This skill should be used when the user asks about "Claude Code best practices", "how to improve my Claude Code setup", "what are good Claude Code patterns", "tips for using Claude Code effectively", or mentions wanting to learn Claude Code techniques. Provides contextual coaching that auto-triggers when best practice questions arise.
version: 1.0.0
---

## Purpose

Deliver contextual Claude Code coaching outside the explicit `/tips`, `/quiz`, and `/audit` commands. This skill activates during regular work sessions when best practice questions arise naturally — the user does not need to invoke a specific command. The goal is to meet the user where they are, connect coaching to their current work context, and accelerate their progression through the belt levels.

## When This Skill Activates

Activate this skill when the user:

- Asks a general question about Claude Code best practices (e.g., "What's the best way to structure my CLAUDE.md?").
- Asks how to improve their current Claude Code setup or workflow.
- Asks what patterns experienced Claude Code users follow.
- Mentions wanting to learn techniques for using Claude Code more effectively.
- Expresses frustration with a recurring issue that a best practice would solve (e.g., "Claude keeps forgetting my conventions mid-session").
- Asks about any of the seven knowledge categories: memory, hooks, agents, git, prompts, commands, security.

Do not activate for questions that are clearly about coding in general, unrelated tools, or topics outside Claude Code usage patterns.

## How to Deliver Coaching

### Step 1 — Read the Learner Profile

Before responding, read the learner profile at `.claude-sensei/learner-profile.json`. Extract:

- The user's current belt level (white, yellow, green, blue, black).
- Their strongest and weakest categories.
- The list of tip IDs they have already seen.
- Their recent quiz and audit performance.

If the profile does not exist, treat the user as a White Belt beginner with no prior exposure.

### Step 2 — Identify the Relevant Knowledge

Identify which category the user's question falls into from the seven categories: `memory`, `hooks`, `agents`, `git`, `prompts`, `commands`, `security`.

Read the relevant tips file from `$CLAUDE_PLUGIN_ROOT/knowledge/tips/[category].json`. Identify the most applicable tip for the user's question, taking into account their belt level. Prefer tips they have not yet seen, but do not withhold a directly relevant tip just because they have seen it.

If the question spans multiple categories, pick the primary category and note the secondary one for a follow-up suggestion.

### Step 3 — Deliver Contextual Advice

Respond with coaching that:

1. Directly answers the user's question first — do not make them read through preamble.
2. Connects the advice to their current work context when detectable (e.g., if they are working on a monorepo, reference the layered CLAUDE.md pattern).
3. References the tip by its ID (e.g., `mem-007`) so the user can revisit it with `/tips`.
4. Stays concise — aim for 3–5 sentences of core advice, followed by an example if one significantly aids understanding.
5. Ends with one suggested next action.

### Step 4 — Suggest a Next Command

Close every coaching response with exactly one actionable next step. Choose the most appropriate:

- `/tips [category]` — if the user would benefit from more tips in this area.
- `/quiz [category]` — if they seem to understand the concept and should test retention.
- `/audit` — if the advice relates to a project-level check they have not recently run.
- `/progress` — if they ask about tracking their learning.

## Coaching Approach

### Match Advice to Belt Level

Calibrate the depth and complexity of advice to the user's current belt:

- **White Belt** (0–19): Focus on foundational practices. Explain the "why" clearly. Avoid overwhelming with advanced patterns. Beginner tips only.
- **Yellow Belt** (20–39): Introduce intermediate concepts. Assume they understand the basics. Mix beginner reinforcement with intermediate depth.
- **Green Belt** (40–59): Engage with intermediate and some advanced patterns. Assume comfort with fundamentals. Discuss tradeoffs.
- **Blue Belt** (60–79): Deliver advanced, nuanced guidance. Discuss edge cases and optimization. Treat them as experienced practitioners.
- **Black Belt** (80–100): Peer-level discussion. Reference advanced techniques, emerging patterns, and subtle interactions between features. Focus on mastery and teaching others.

### Connect to Current Work

When the user's question arises during active work (e.g., they are editing a CLAUDE.md, writing a hook, or running an agent), explicitly connect the coaching to what they are doing right now. Specificity beats generality. "Add this to the CLAUDE.md you have open" is better than "add this to your CLAUDE.md."

### Keep It Concise

Respect the user's attention. They are in the middle of work. Deliver the essential insight in the fewest words that preserve accuracy. Use examples only when they substantially reduce ambiguity. Avoid restating things the user clearly already knows from their profile.

### Reference Tip IDs

Always include the tip ID when referencing a specific tip. This allows the user to:
- Recall the full tip later with `/tips`.
- Track which tips have influenced their work.
- Build a personal reference list of tips they find valuable.

## Knowledge Base Location

- Tips: `$CLAUDE_PLUGIN_ROOT/knowledge/tips/[category].json`
- Quizzes: `$CLAUDE_PLUGIN_ROOT/knowledge/quizzes/[category].json`
- Audit rules: `$CLAUDE_PLUGIN_ROOT/knowledge/audit/rules.json`
- Schema reference: `$CLAUDE_PLUGIN_ROOT/skills/sensei-coaching/references/knowledge-schema.md`

Each category has its own file. Load only the file relevant to the current question. Do not load the entire knowledge base for a single coaching interaction.

## Updating the Learner Profile

After delivering coaching, update the learner profile to record the interaction:

- Add the tip ID to the list of seen tips (if a specific tip was referenced).
- Append an entry to `.claude-sensei/learning-log.json` with: timestamp, category, tip ID, and source `"contextual-coaching"`.

Keep profile updates lightweight. Do not block the response on profile writes — complete the response first, then update.

## What Not to Do

- Do not lecture or moralize. Deliver the insight and move on.
- Do not repeat advice the user has already acted on (check the profile).
- Do not trigger a full audit scan during a casual coaching response. Suggest `/audit` instead.
- Do not invent tips that are not in the knowledge base. If a question falls outside the knowledge base, say so honestly and suggest the closest available tip.
- Do not over-qualify or hedge. Be direct.
