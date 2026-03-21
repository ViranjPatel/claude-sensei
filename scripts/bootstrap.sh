#!/usr/bin/env bash
# bootstrap.sh — Initialize .claude-sensei/ learner state in the user's project.
# Called by agents on first run to set up mutable learner state.
#
# Usage:
#   CLAUDE_PROJECT_DIR=/path/to/project bash bootstrap.sh
#   (defaults to current directory if CLAUDE_PROJECT_DIR is not set)

set -euo pipefail

# ── Resolve project directory ────────────────────────────────────────────────
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SENSEI_DIR="${PROJECT_DIR}/.claude-sensei"

# ── Skip if already initialised ─────────────────────────────────────────────
if [ -d "${SENSEI_DIR}" ]; then
  echo "claude-sensei: .claude-sensei/ already exists in ${PROJECT_DIR} — skipping."
  exit 0
fi

# ── Create directory ─────────────────────────────────────────────────────────
mkdir -p "${SENSEI_DIR}"

# ── Determine today's date (ISO-8601) ────────────────────────────────────────
TODAY="$(date -u +%Y-%m-%d)"

# ── Write learner-profile.json ───────────────────────────────────────────────
cat > "${SENSEI_DIR}/learner-profile.json" << 'PROFILE_EOF'
{
  "version": 1,
  "created": "REPLACE_CREATED",
  "last_active": "REPLACE_LAST_ACTIVE",
  "belt": "white",
  "sensei_score": 0,
  "streak_days": 0,
  "total_quizzes": 0,
  "total_tips_seen": 0,
  "tips_seen": [],
  "tips_applied": [],
  "audit_history": [],
  "mastery": {
    "memory":   { "score": 0, "trend": "new", "quizzes_taken": 0, "avg_quiz_score": 0 },
    "hooks":    { "score": 0, "trend": "new", "quizzes_taken": 0, "avg_quiz_score": 0 },
    "agents":   { "score": 0, "trend": "new", "quizzes_taken": 0, "avg_quiz_score": 0 },
    "git":      { "score": 0, "trend": "new", "quizzes_taken": 0, "avg_quiz_score": 0 },
    "prompts":  { "score": 0, "trend": "new", "quizzes_taken": 0, "avg_quiz_score": 0 },
    "commands": { "score": 0, "trend": "new", "quizzes_taken": 0, "avg_quiz_score": 0 },
    "security": { "score": 0, "trend": "new", "quizzes_taken": 0, "avg_quiz_score": 0 }
  }
}
PROFILE_EOF

# ── Stamp dates (cross-platform sed -i) ─────────────────────────────────────
# macOS requires an explicit backup extension for -i; Linux does not.
if [[ "${OSTYPE:-}" == darwin* ]]; then
  sed -i '' "s/REPLACE_CREATED/${TODAY}/" "${SENSEI_DIR}/learner-profile.json"
  sed -i '' "s/REPLACE_LAST_ACTIVE/${TODAY}/" "${SENSEI_DIR}/learner-profile.json"
else
  sed -i "s/REPLACE_CREATED/${TODAY}/" "${SENSEI_DIR}/learner-profile.json"
  sed -i "s/REPLACE_LAST_ACTIVE/${TODAY}/" "${SENSEI_DIR}/learner-profile.json"
fi

# ── Write learning-log.json ──────────────────────────────────────────────────
echo '[]' > "${SENSEI_DIR}/learning-log.json"

# ── Update .gitignore ────────────────────────────────────────────────────────
GITIGNORE="${PROJECT_DIR}/.gitignore"
GITIGNORE_ENTRY=".claude-sensei/"

if [ ! -f "${GITIGNORE}" ]; then
  # Create a new .gitignore with the entry
  echo "${GITIGNORE_ENTRY}" > "${GITIGNORE}"
else
  # Only add if not already present (exact line match)
  if ! grep -qxF "${GITIGNORE_ENTRY}" "${GITIGNORE}"; then
    # Ensure the file ends with a newline before appending
    if [ -s "${GITIGNORE}" ] && [ "$(tail -c1 "${GITIGNORE}" | wc -c)" -gt 0 ]; then
      # Check if last char is a newline
      last_char="$(tail -c1 "${GITIGNORE}" | od -An -tx1 | tr -d ' \n')"
      if [ "${last_char}" != "0a" ]; then
        echo "" >> "${GITIGNORE}"
      fi
    fi
    echo "${GITIGNORE_ENTRY}" >> "${GITIGNORE}"
  fi
fi

# ── Done ─────────────────────────────────────────────────────────────────────
echo "claude-sensei: Initialized .claude-sensei/ in ${PROJECT_DIR}"
echo "  - learner-profile.json (belt: white, all categories at score 0)"
echo "  - learning-log.json (empty)"
echo "  - .gitignore updated (${GITIGNORE_ENTRY} added)"
