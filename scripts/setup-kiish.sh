#!/bin/bash

# KIISH Setup Script
# Saves your task and starts the build loop

set -euo pipefail

PROMPT_PARTS=()
MAX_ITERATIONS=0
COMPLETION_PROMISE="null"

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      cat << 'HELP_EOF'
KIISH — Keep Iterating In Smart Harmony

WHAT IT DOES:
  You give KIISH a task. KIISH works on it, round after round, until
  the job is done — or until it hits the limit you set.

HOW TO USE:
  /kiish [YOUR TASK] [OPTIONS]

OPTIONS:
  --max-rounds <number>        Stop after this many rounds (default: no limit)
  --done-when '<phrase>'       The phrase KIISH outputs when finished (use quotes)
  -h, --help                   Show this help

EXAMPLES:
  /kiish Build a Chrome extension with a toggle button --max-rounds 20
  /kiish Fix the login bug --done-when 'FIXED' --max-rounds 10
  /kiish Create a homepage for my product --done-when 'COMPLETE'

HOW TO MONITOR PROGRESS:
  Check which round KIISH is on:
    grep '^iteration:' .claude/kiish.local.md

  See the full state:
    head -10 .claude/kiish.local.md

HOW TO STOP EARLY:
  Run: /cancel-kiish
HELP_EOF
      exit 0
      ;;
    --max-rounds)
      if [[ -z "${2:-}" ]]; then
        echo "❌ You need to provide a number after --max-rounds" >&2
        echo "   Example: --max-rounds 20" >&2
        exit 1
      fi
      if ! [[ "$2" =~ ^[0-9]+$ ]]; then
        echo "❌ --max-rounds must be a whole number (e.g. 10, 20, 50)" >&2
        echo "   You gave: $2" >&2
        exit 1
      fi
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --done-when)
      if [[ -z "${2:-}" ]]; then
        echo "❌ You need to provide a phrase after --done-when" >&2
        echo "   Example: --done-when 'COMPLETE'" >&2
        echo "   Note: Use quotes for multi-word phrases!" >&2
        exit 1
      fi
      COMPLETION_PROMISE="$2"
      shift 2
      ;;
    *)
      PROMPT_PARTS+=("$1")
      shift
      ;;
  esac
done

PROMPT="${PROMPT_PARTS[*]:-}"

if [[ -z "$PROMPT" ]]; then
  echo "❌ You didn't give KIISH a task to work on." >&2
  echo "" >&2
  echo "   Tell KIISH what to build or fix. Examples:" >&2
  echo "     /kiish Build a REST API for todos" >&2
  echo "     /kiish Fix the login bug --max-rounds 10" >&2
  echo "     /kiish --done-when 'DONE' Create a settings page" >&2
  echo "" >&2
  echo "   For full help: /kiish --help" >&2
  exit 1
fi

mkdir -p .claude

if [[ -n "$COMPLETION_PROMISE" ]] && [[ "$COMPLETION_PROMISE" != "null" ]]; then
  COMPLETION_PROMISE_YAML="\"$COMPLETION_PROMISE\""
else
  COMPLETION_PROMISE_YAML="null"
fi

cat > .claude/kiish.local.md <<EOF
---
active: true
iteration: 1
session_id: ${CLAUDE_CODE_SESSION_ID:-}
max_iterations: $MAX_ITERATIONS
completion_promise: $COMPLETION_PROMISE_YAML
started_at: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
---

$PROMPT
EOF

cat <<EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🚀 KIISH is now running
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Round:       1 of $(if [[ $MAX_ITERATIONS -gt 0 ]]; then echo "$MAX_ITERATIONS"; else echo "unlimited"; fi)
  Finish when: $(if [[ "$COMPLETION_PROMISE" != "null" ]]; then echo "\"${COMPLETION_PROMISE//\"/}\" is output (only when truly done!)"; else echo "no finish signal set — runs forever unless you stop it"; fi)

  KIISH will keep working on your task round after round.
  Each round it sees all the work from previous rounds and
  builds on top of it — so it gets better every time.

  To stop early: /cancel-kiish
  To check progress: grep '^iteration:' .claude/kiish.local.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF

if [[ -n "$PROMPT" ]]; then
  echo ""
  echo "$PROMPT"
fi

if [[ "$COMPLETION_PROMISE" != "null" ]]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  FINISH SIGNAL"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "  To mark this task complete, output this exactly:"
  echo "    <promise>$COMPLETION_PROMISE</promise>"
  echo ""
  echo "  ⚠️  Only output this when the work is genuinely done."
  echo "      Do not use it to escape the loop early."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi
