---
description: "Start a KIISH build loop — give it a task and it works until done"
argument-hint: "YOUR TASK [--max-rounds N] [--done-when 'PHRASE']"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/setup-kiish.sh:*)"]
hide-from-slash-command-tool: "true"
---

# KIISH — Keep Iterating In Smart Harmony

Run the setup script to start your build loop:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/setup-kiish.sh" $ARGUMENTS
```

Work on the task described above. When you finish a round and try to exit, KIISH will bring you right back with the same task — and you'll be able to see everything you built in previous rounds. Keep building and improving until the task is truly complete.

IMPORTANT: If a finish signal (--done-when) is set, only output it when the work is genuinely and completely done. Do not output a false signal just to stop the loop.
