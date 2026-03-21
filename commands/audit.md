---
name: audit
description: Scan your project for Claude Code maturity. Usage: /audit [dimension] [--diff] [--fix]
---

Parse the arguments provided to this command and dispatch to the audit-agent accordingly.

## Argument Parsing

Examine the arguments passed after `/audit`:

- **No args**: Run a full maturity scan across all audit dimensions. Produce a complete scorecard.
- **A dimension name**: Run the scan for that single dimension only (e.g., `/audit memory`, `/audit hooks`). Valid dimensions correspond to the rule categories defined in `$CLAUDE_PLUGIN_ROOT/knowledge/audit/rules.json`.
- **`--diff`**: After scanning, compare the current results against the last stored audit snapshot in `.claude-sensei/last-audit.json`. Highlight what improved, what regressed, and what is new since the last scan.
- **`--fix`**: After identifying failing checks, propose auto-fixes for any rules that are automatically remediable. Present each fix to the user with a clear description and ask for confirmation before applying. Never apply fixes silently.
- **Combined flags**: Dimension + `--diff`, dimension + `--fix`, or dimension + `--diff` + `--fix` are all valid combinations.

## Dispatch Instructions

After parsing args, invoke the audit-agent with the following context:

1. The scan scope: `full` or a specific dimension name.
2. Whether `--diff` mode is active.
3. Whether `--fix` mode is active.
4. The audit rules path: `$CLAUDE_PLUGIN_ROOT/knowledge/audit/rules.json`
5. The last audit snapshot path: `.claude-sensei/last-audit.json` (may not exist on first run).
6. The learner profile path: `.claude-sensei/learner-profile.json`

The audit-agent is responsible for:
- Reading the rules from the knowledge base and scanning the project for each applicable check.
- Scoring each dimension on a 0–100 scale based on passing/failing rules.
- Computing an overall maturity score and assigning a maturity tier (e.g., Yellow Belt, Green Belt).
- If `--diff`: loading the previous snapshot and producing a delta report.
- If `--fix`: identifying auto-fixable failures, presenting proposed changes, awaiting confirmation, then applying approved fixes.
- Saving the current scan results to `.claude-sensei/last-audit.json` after the scan.
- Updating the learner profile with the new audit scores.

## Output Format

Present results as a structured scorecard:

```
Claude Code Maturity Audit
==========================
Overall Score: [X/100] — [Tier Name]

Dimension          Score    Status
-----------        -----    ------
Memory             [X/100]  [pass/warn/fail]
Hooks              [X/100]  [pass/warn/fail]
Agents             [X/100]  [pass/warn/fail]
...

Top Issues:
1. [Failing rule description] — [how to fix]
2. ...

Suggested next steps: /tips [lowest-dimension] or /quiz [lowest-dimension]
```

When `--diff` is active, add a "Changes Since Last Audit" section highlighting improvements and regressions.
