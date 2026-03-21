# Knowledge Schema Reference

This document defines the JSON schemas for all knowledge and profile files used by the Claude Sensei plugin. Use this as the authoritative reference when reading, writing, or validating any data file.

---

## Tips Files

**Location:** `$CLAUDE_PLUGIN_ROOT/knowledge/tips/[category].json`

One file per category. Each file is a JSON array of tip objects.

```json
[
  {
    "id": "string",
    "title": "string",
    "level": "beginner | intermediate | advanced",
    "category": "memory | hooks | agents | git | prompts | commands | security",
    "tip": "string",
    "example": "string",
    "why": "string",
    "source": "anthropic-docs | community",
    "tags": ["string"]
  }
]
```

### Field Descriptions — Tips

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique tip identifier. Format: `[category-prefix]-[3-digit-number]` (e.g., `mem-007`, `hk-003`). |
| `title` | string | Short human-readable title for the tip. |
| `level` | enum | Skill level this tip is appropriate for. One of: `beginner`, `intermediate`, `advanced`. |
| `category` | enum | The knowledge domain. One of: `memory`, `hooks`, `agents`, `git`, `prompts`, `commands`, `security`. |
| `tip` | string | The full tip body. Explains the concept and what to do. |
| `example` | string | A concrete code or configuration example illustrating the tip. May be a multiline string. |
| `why` | string | Explains the rationale — why this practice matters and what problem it solves. |
| `source` | enum | Attribution. `anthropic-docs` for tips drawn from official Anthropic documentation; `community` for tips sourced from community best practices. |
| `tags` | array of strings | Free-form searchable keywords for the tip. |

### Valid Enum Values — Tips

- **`level`**: `beginner`, `intermediate`, `advanced`
- **`category`**: `memory`, `hooks`, `agents`, `git`, `prompts`, `commands`, `security`
- **`source`**: `anthropic-docs`, `community`

---

## Quiz Files

**Location:** `$CLAUDE_PLUGIN_ROOT/knowledge/quizzes/[category].json`

One file per category. The top-level object contains the category name and a `questions` array.

```json
{
  "category": "memory | hooks | agents | git | prompts | commands | security",
  "questions": [
    {
      "id": "string",
      "difficulty": "beginner | intermediate | advanced",
      "question": "string",
      "options": ["string", "string", "string", "string"],
      "correct": "A | B | C | D",
      "explanation": "string",
      "tip_ref": "string"
    }
  ]
}
```

### Field Descriptions — Quiz Questions

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique question identifier. Format: `[category-prefix]-q[number]` (e.g., `mem-q1`, `hk-q4`). |
| `difficulty` | enum | Difficulty level of the question. One of: `beginner`, `intermediate`, `advanced`. |
| `question` | string | The full question text presented to the learner. |
| `options` | array of strings | Exactly 4 answer choices. Each string is prefixed with the letter label: `"A) ..."`, `"B) ..."`, `"C) ..."`, `"D) ..."`. |
| `correct` | enum | The letter of the correct answer. One of: `"A"`, `"B"`, `"C"`, `"D"`. |
| `explanation` | string | The full explanation shown after the learner answers. Explains why the correct answer is correct and why common wrong answers are incorrect. |
| `tip_ref` | string | The `id` of the tip in the tips knowledge base that this question relates to. Used to link quiz results back to relevant tips. |

### Valid Enum Values — Quizzes

- **`category`**: `memory`, `hooks`, `agents`, `git`, `prompts`, `commands`, `security`
- **`difficulty`**: `beginner`, `intermediate`, `advanced`
- **`correct`**: `A`, `B`, `C`, `D`

---

## Audit Rules File

**Location:** `$CLAUDE_PLUGIN_ROOT/knowledge/audit/rules.json`

A single JSON object mapping dimension names to arrays of rule objects.

```json
{
  "[dimension]": [
    {
      "id": "string",
      "title": "string",
      "description": "string",
      "check_type": "file_exists | file_contains | file_not_contains | command_succeeds | directory_exists | json_field_exists",
      "target": "string",
      "expected": "string | boolean | null",
      "severity": "error | warning | info",
      "auto_fix": "boolean",
      "fix_description": "string | null",
      "tip_ref": "string | null"
    }
  ]
}
```

### Field Descriptions — Audit Rules

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique rule identifier. Format: `[dimension-prefix]-[3-digit-number]` (e.g., `mem-r001`, `hk-r002`). |
| `title` | string | Short name for the rule, used in scorecard output. |
| `description` | string | Full description of what the rule checks and why it matters. |
| `check_type` | enum | The type of check to perform. See valid values below. |
| `target` | string | The file path, directory path, command, or JSON path to check. May contain variables like `$PROJECT_ROOT`. |
| `expected` | string, boolean, or null | The expected value or condition. Interpretation depends on `check_type`. |
| `severity` | enum | How critical a failure is. `error` = major gap, `warning` = improvement opportunity, `info` = informational only. |
| `auto_fix` | boolean | Whether this rule can be automatically remediated by the `--fix` flag. |
| `fix_description` | string or null | Human-readable description of what the auto-fix will do. Required if `auto_fix` is `true`. |
| `tip_ref` | string or null | The `id` of a tip that addresses this rule's concern, for linking audit failures to learning resources. |

### Valid Enum Values — Audit Rules

- **`check_type`**:
  - `file_exists` — Check that a file exists at `target`.
  - `file_contains` — Check that the file at `target` contains the string or pattern in `expected`.
  - `file_not_contains` — Check that the file at `target` does NOT contain the string or pattern in `expected`.
  - `command_succeeds` — Run the command in `target` and check that it exits with code 0.
  - `directory_exists` — Check that a directory exists at `target`.
  - `json_field_exists` — Check that the JSON file at `target` contains the field path specified in `expected`.
- **`severity`**: `error`, `warning`, `info`

---

## Learner Profile

**Location:** `.claude-sensei/learner-profile.json`

The per-user profile stored in the project's `.claude-sensei/` directory (gitignored).

```json
{
  "version": "string",
  "created_at": "ISO 8601 timestamp",
  "updated_at": "ISO 8601 timestamp",
  "belt": "white | yellow | green | blue | black",
  "overall_score": "number (0–100)",
  "categories": {
    "[category]": {
      "score": "number (0–100)",
      "trend": "improving | stable | declining | new",
      "tips_seen": ["tip-id"],
      "quiz_attempts": "number",
      "quiz_correct": "number",
      "last_quiz_at": "ISO 8601 timestamp | null",
      "last_audit_score": "number (0–100) | null",
      "last_audit_at": "ISO 8601 timestamp | null"
    }
  },
  "last_activity_at": "ISO 8601 timestamp | null",
  "onboarding_complete": "boolean"
}
```

### Field Descriptions — Learner Profile

| Field | Type | Description |
|-------|------|-------------|
| `version` | string | Schema version for the profile format. Used for migration if the schema changes. |
| `created_at` | ISO 8601 string | Timestamp when the profile was first created (bootstrap time). |
| `updated_at` | ISO 8601 string | Timestamp of the most recent update to the profile. |
| `belt` | enum | The user's current belt level, derived from `overall_score`. |
| `overall_score` | number | Weighted average score across all categories (0–100). |
| `categories` | object | A map of category name to per-category data. Keys are the seven category names. |
| `categories.[cat].score` | number | Composite mastery score for this category (0–100). Derived from tips seen, quiz accuracy, and audit results. |
| `categories.[cat].trend` | enum | Whether the score is improving, stable, or declining compared to the previous snapshot. `new` for categories with no prior history. |
| `categories.[cat].tips_seen` | array of strings | List of tip IDs the user has been shown for this category. |
| `categories.[cat].quiz_attempts` | number | Total number of quiz questions attempted in this category. |
| `categories.[cat].quiz_correct` | number | Number of quiz questions answered correctly in this category. |
| `categories.[cat].last_quiz_at` | ISO 8601 string or null | Timestamp of the most recent quiz question in this category. |
| `categories.[cat].last_audit_score` | number or null | Score from the most recent audit scan for this dimension. Null if never audited. |
| `categories.[cat].last_audit_at` | ISO 8601 string or null | Timestamp of the most recent audit for this dimension. |
| `last_activity_at` | ISO 8601 string or null | Timestamp of the most recent interaction with any sensei command or skill. |
| `onboarding_complete` | boolean | Whether the user has completed the initial onboarding tip sequence. |

### Valid Enum Values — Learner Profile

- **`belt`**: `white`, `yellow`, `green`, `blue`, `black`
- **`trend`**: `improving`, `stable`, `declining`, `new`

### Belt Level Thresholds

| Belt | Score Range |
|------|-------------|
| White | 0–19 |
| Yellow | 20–39 |
| Green | 40–59 |
| Blue | 60–79 |
| Black | 80–100 |

---

## Learning Log

**Location:** `.claude-sensei/learning-log.json`

An append-only array of interaction events. Each entry records one learning activity.

```json
[
  {
    "id": "string",
    "timestamp": "ISO 8601 timestamp",
    "event_type": "tip_viewed | quiz_answered | audit_run | suggestion_shown | coaching_delivered | profile_reset",
    "category": "memory | hooks | agents | git | prompts | commands | security | null",
    "tip_ref": "string | null",
    "quiz_question_id": "string | null",
    "quiz_correct": "boolean | null",
    "audit_score": "number | null",
    "audit_dimension": "string | null",
    "source": "tips-command | quiz-command | audit-command | suggest-command | progress-command | contextual-coaching | session-hook",
    "notes": "string | null"
  }
]
```

### Field Descriptions — Learning Log

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique identifier for this log entry. Format: `log-[timestamp-ms]` or a UUID. |
| `timestamp` | ISO 8601 string | When this event occurred. |
| `event_type` | enum | The type of learning event. See valid values below. |
| `category` | enum or null | The knowledge category involved, if applicable. Null for events not tied to a category. |
| `tip_ref` | string or null | The tip ID referenced in this event, if any. |
| `quiz_question_id` | string or null | The quiz question ID, if this event is a quiz answer. |
| `quiz_correct` | boolean or null | Whether the quiz answer was correct. Null for non-quiz events. |
| `audit_score` | number or null | The score recorded during an audit event. Null for non-audit events. |
| `audit_dimension` | string or null | The audit dimension scanned. Null for non-audit events. |
| `source` | enum | Which command or mechanism generated this log entry. |
| `notes` | string or null | Optional free-text notes, used for contextual coaching entries to record what the user asked. |

### Valid Enum Values — Learning Log

- **`event_type`**:
  - `tip_viewed` — A tip was delivered to the user.
  - `quiz_answered` — The user answered a quiz question.
  - `audit_run` — An audit scan was performed.
  - `suggestion_shown` — A `/suggest` response was delivered.
  - `coaching_delivered` — A contextual coaching response was delivered by the sensei-coaching skill.
  - `profile_reset` — The learner profile was reset.
- **`source`**:
  - `tips-command` — Triggered by the `/tips` command.
  - `quiz-command` — Triggered by the `/quiz` command.
  - `audit-command` — Triggered by the `/audit` command.
  - `suggest-command` — Triggered by the `/suggest` command.
  - `progress-command` — Triggered by the `/progress` command.
  - `contextual-coaching` — Triggered by the `sensei-coaching` skill during regular work.
  - `session-hook` — Triggered by a hook (e.g., the session-start tip hook).

---

## File Naming Conventions

| File Pattern | Description |
|---|---|
| `knowledge/tips/[category].json` | Tips for one category. Category name matches the enum values. |
| `knowledge/quizzes/[category].json` | Quiz questions for one category. |
| `knowledge/audit/rules.json` | All audit rules in one file, keyed by dimension. |
| `.claude-sensei/learner-profile.json` | User's learning profile. Per-project, gitignored. |
| `.claude-sensei/learning-log.json` | Append-only event log. Per-project, gitignored. |
| `.claude-sensei/last-audit.json` | Snapshot of the most recent full audit result. Used by `--diff`. |
