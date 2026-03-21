#!/bin/bash
set -euo pipefail

# Claude Sensei — Session Start Tip
# Displays a personalized one-liner based on learner profile weaknesses

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
SENSEI_DIR="$PROJECT_DIR/.claude-sensei"
PROFILE="$SENSEI_DIR/learner-profile.json"
MARKER="$SENSEI_DIR/.session-tip-shown"

# Skip if not initialized
if [ ! -f "$PROFILE" ]; then
  exit 0
fi

# Skip if already shown this session (marker file less than 1 hour old)
if [ -f "$MARKER" ]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    marker_age=$(( $(date +%s) - $(stat -f %m "$MARKER" 2>/dev/null || echo 0) ))
  else
    marker_age=$(( $(date +%s) - $(stat -c %Y "$MARKER" 2>/dev/null || echo 0) ))
  fi
  if [ "$marker_age" -lt 3600 ]; then
    exit 0
  fi
fi

# Find weakest category and display tip
if command -v jq &> /dev/null; then
  weakest=$(jq -r '.mastery | to_entries | min_by(.value.score) | .key' "$PROFILE" 2>/dev/null || echo "")
  score=$(jq -r ".mastery.\"$weakest\".score // 0" "$PROFILE" 2>/dev/null || echo "0")
  belt=$(jq -r '.belt // "white"' "$PROFILE" 2>/dev/null || echo "white")
else
  # Fallback without jq
  echo "Sensei: Run /progress to see your learning journey." >&2
  touch "$MARKER"
  exit 0
fi

if [ -z "$weakest" ] || [ "$weakest" = "null" ]; then
  echo "Sensei: Welcome! Run /tips to start learning Claude Code best practices." >&2
else
  echo "Sensei [$belt belt]: Your $weakest score is ${score}%. Try /tips intermediate $weakest to level up." >&2
fi

# Mark as shown
touch "$MARKER"
exit 0
