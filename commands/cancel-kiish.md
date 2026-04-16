---
description: "Stop an active KIISH build loop"
allowed-tools: ["Bash(test -f .claude/kiish.local.md:*)", "Bash(rm .claude/kiish.local.md)", "Read(.claude/kiish.local.md)"]
hide-from-slash-command-tool: "true"
---

# Cancel KIISH

Stop any active KIISH build loop in this project.

Steps:
1. Check if `.claude/kiish.local.md` exists: `test -f .claude/kiish.local.md && echo "EXISTS" || echo "NOT_FOUND"`

2. **If NOT_FOUND**: Tell the user: "No active KIISH loop found in this project."

3. **If EXISTS**:
   - Read `.claude/kiish.local.md` to get the current `iteration:` value
   - Delete the file: `rm .claude/kiish.local.md`
   - Tell the user: "KIISH stopped. It had completed N round(s) before stopping."
