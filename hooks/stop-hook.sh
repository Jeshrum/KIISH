#!/bin/bash

# KIISH Stop Hook
# Keeps the build loop alive — checks if the job is done, then either stops cleanly or feeds the task back in for the next round.

set -euo pipefail

HOOK_INPUT=$(cat)

KIISH_STATE_FILE=".claude/kiish.local.md"

if [[ ! -f "$KIISH_STATE_FILE" ]]; then
  exit 0
fi

FRONTMATTER=$(sed -n '/^---$/,/^---$/{ /^---$/d; p; }' "$KIISH_STATE_FILE")
ITERATION=$(echo "$FRONTMATTER" | grep '^iteration:' | sed 's/iteration: *//')
MAX_ITERATIONS=$(echo "$FRONTMATTER" | grep '^max_iterations:' | sed 's/max_iterations: *//')
COMPLETION_PROMISE=$(echo "$FRONTMATTER" | grep '^completion_promise:' | sed 's/completion_promise: *//' | sed 's/^"\(.*\)"$/\1/')

STATE_SESSION=$(echo "$FRONTMATTER" | grep '^session_id:' | sed 's/session_id: *//' || true)
HOOK_SESSION=$(echo "$HOOK_INPUT" | jq -r '.session_id // ""')
if [[ -n "$STATE_SESSION" ]] && [[ "$STATE_SESSION" != "$HOOK_SESSION" ]]; then
  exit 0
fi

if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
  echo "⚠️  KIISH: State file looks corrupted." >&2
  echo "   File: $KIISH_STATE_FILE" >&2
  echo "   The iteration counter is invalid (got: '$ITERATION')." >&2
  echo "   KIISH is stopping. Run /kiish again to restart." >&2
  rm "$KIISH_STATE_FILE"
  exit 0
fi

if [[ ! "$MAX_ITERATIONS" =~ ^[0-9]+$ ]]; then
  echo "⚠️  KIISH: State file looks corrupted." >&2
  echo "   File: $KIISH_STATE_FILE" >&2
  echo "   The max-iterations setting is invalid (got: '$MAX_ITERATIONS')." >&2
  echo "   KIISH is stopping. Run /kiish again to restart." >&2
  rm "$KIISH_STATE_FILE"
  exit 0
fi

if [[ $MAX_ITERATIONS -gt 0 ]] && [[ $ITERATION -ge $MAX_ITERATIONS ]]; then
  echo "🛑 KIISH: Reached the limit of $MAX_ITERATIONS rounds. Stopping now."
  rm "$KIISH_STATE_FILE"
  exit 0
fi

TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path')

if [[ ! -f "$TRANSCRIPT_PATH" ]]; then
  echo "⚠️  KIISH: Could not find the session transcript." >&2
  echo "   Expected: $TRANSCRIPT_PATH" >&2
  echo "   KIISH is stopping." >&2
  rm "$KIISH_STATE_FILE"
  exit 0
fi

if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
  echo "⚠️  KIISH: No AI responses found in this session yet." >&2
  echo "   KIISH is stopping." >&2
  rm "$KIISH_STATE_FILE"
  exit 0
fi

LAST_LINES=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -n 100)
if [[ -z "$LAST_LINES" ]]; then
  echo "⚠️  KIISH: Could not read AI responses." >&2
  echo "   KIISH is stopping." >&2
  rm "$KIISH_STATE_FILE"
  exit 0
fi

set +e
LAST_OUTPUT=$(echo "$LAST_LINES" | jq -rs '
  map(.message.content[]? | select(.type == "text") | .text) | last // ""
' 2>&1)
JQ_EXIT=$?
set -e

if [[ $JQ_EXIT -ne 0 ]]; then
  echo "⚠️  KIISH: Could not parse the session transcript." >&2
  echo "   Error: $LAST_OUTPUT" >&2
  echo "   KIISH is stopping." >&2
  rm "$KIISH_STATE_FILE"
  exit 0
fi

if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' 2>/dev/null || echo "")

  if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" = "$COMPLETION_PROMISE" ]]; then
    echo "✅ KIISH: Task complete! Detected <promise>$COMPLETION_PROMISE</promise>"
    rm "$KIISH_STATE_FILE"
    exit 0
  fi
fi

NEXT_ITERATION=$((ITERATION + 1))

PROMPT_TEXT=$(awk '/^---$/{i++; next} i>=2' "$KIISH_STATE_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
  echo "⚠️  KIISH: Could not find the task description in the state file." >&2
  echo "   File: $KIISH_STATE_FILE" >&2
  echo "   KIISH is stopping. Run /kiish again to restart." >&2
  rm "$KIISH_STATE_FILE"
  exit 0
fi

TEMP_FILE="${KIISH_STATE_FILE}.tmp.$$"
sed "s/^iteration: .*/iteration: $NEXT_ITERATION/" "$KIISH_STATE_FILE" > "$TEMP_FILE"
mv "$TEMP_FILE" "$KIISH_STATE_FILE"

if [[ "$COMPLETION_PROMISE" != "null" ]] && [[ -n "$COMPLETION_PROMISE" ]]; then
  SYSTEM_MSG="🔁 KIISH Round $NEXT_ITERATION — Still working. To finish, output <promise>$COMPLETION_PROMISE</promise> (only when the work is truly done)"
else
  SYSTEM_MSG="🔁 KIISH Round $NEXT_ITERATION — No finish signal set. Loop runs until you set a limit or stop manually."
fi

jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
