---
name: quiz
description: Test your Claude Code knowledge with interactive quizzes. Usage: /quiz [category] or /quiz all
---

Parse the arguments provided to this command and dispatch to the quiz-agent accordingly.

## Argument Parsing

Examine the arguments passed after `/quiz`:

- **No args**: Identify the user's weakest category by reading `.claude-sensei/learner-profile.json`. The weakest category is the one with the lowest mastery score or the most unanswered questions. Run a quiz session for that category.
- **A category name** (`memory`, `hooks`, `agents`, `git`, `prompts`, `commands`, `security`): Run a quiz session focused exclusively on that category.
- **`all`**: Run a mixed quiz of 10 questions drawn across all categories, weighted toward weaker areas based on the learner profile.

## Valid Categories

`memory`, `hooks`, `agents`, `git`, `prompts`, `commands`, `security`

## Dispatch Instructions

After parsing args, invoke the quiz-agent with the following context:

1. The resolved quiz mode: `targeted` (specific category), `weakest` (auto-detected), or `mixed` (all categories).
2. The selected category or categories.
3. The path to the learner profile: `.claude-sensei/learner-profile.json`
4. The quizzes knowledge base location: `$CLAUDE_PLUGIN_ROOT/knowledge/quizzes/`

The quiz-agent is responsible for:
- Loading the appropriate quiz file(s) from the knowledge base.
- Selecting questions the user has not recently answered correctly, prioritizing gaps.
- For each question: presenting the question, the multiple-choice options (A/B/C/D), waiting for the user's answer, then revealing whether it is correct with a full explanation.
- After each answer, updating the learner profile with the result (correct/incorrect, timestamp, question ID).
- At the end of the session, providing a summary: score, categories covered, areas to review, and a suggested next command.

## Quiz Session Format

Present one question at a time. Use this structure:

```
Question [N] — [Category] ([difficulty])

[Question text]

A) [Option A]
B) [Option B]
C) [Option C]
D) [Option D]

Your answer:
```

After the user responds, reveal the correct answer and explanation before moving to the next question.

## Session Length

- Targeted or weakest-category mode: 5 questions by default.
- Mixed (`all`) mode: 10 questions across all categories.

End with a score summary and suggest follow-up actions such as `/tips [weak-category]` or `/audit`.
