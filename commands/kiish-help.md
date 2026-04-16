---
description: "Get help with KIISH — what it does and how to use it"
---

# KIISH Help

Explain the following to the user in plain, friendly language:

---

## What is KIISH?

**KIISH** stands for **Keep Iterating In Smart Harmony**.

It's a tool that lets Claude Code work on a task non-stop — round after round — until the job is done.

Think of it like this: instead of asking Claude once and hoping for the best, you set KIISH on a task and it keeps going, improving its own work each time, until everything is working correctly.

---

## How It Works (Non-Technical Explanation)

1. You give KIISH a task (e.g. "Build me a Chrome extension with a toggle button")
2. Claude works on it and tries to finish
3. Instead of stopping, KIISH sends it back in for another round
4. Each time, Claude can see all the files it already created, the tests it ran, the errors it hit
5. It keeps improving until:
   - It outputs the finish signal you specified, OR
   - It hits the round limit you set

It's like having an AI developer who doesn't give up — it just keeps going until the code is clean and working.

---

## Commands

### /kiish — Start a new build loop

```
/kiish Build a Chrome extension --max-rounds 20 --done-when 'COMPLETE'
```

**Options:**
- `--max-rounds <number>` — How many rounds before it automatically stops (recommended: always set this)
- `--done-when '<phrase>'` — The phrase Claude outputs when it's truly finished

**Examples:**
```
/kiish Build a landing page for my SaaS product --max-rounds 15
/kiish Fix the bug in the login form --done-when 'FIXED' --max-rounds 10
/kiish Build a REST API with tests --done-when 'ALL TESTS PASSING' --max-rounds 30
```

---

### /cancel-kiish — Stop the loop early

```
/cancel-kiish
```

Immediately stops the active KIISH loop. No data is lost — all files created so far are kept.

---

### /kiish-help — Show this help page

```
/kiish-help
```

---

## Tips for Getting the Best Results

**Always set --max-rounds** — this is your safety net. Without it, KIISH runs forever.

**Be specific in your task** — the clearer your instructions, the better KIISH performs.

**Include a finish signal** — tell KIISH exactly when it's done:
```
/kiish Build a todo app. When all features work, output <promise>COMPLETE</promise>. --done-when 'COMPLETE'
```

**Great tasks for KIISH:**
- Building new features from scratch
- Getting tests to pass
- Refactoring messy code
- Debugging until it works

**Not ideal for KIISH:**
- Tasks that need your input or opinions
- One-line changes (just ask Claude directly)
- Tasks where you can't tell if they're done automatically

---

## Real-World Example

```
/kiish Build a Chrome extension that applies Bionic Reading to any webpage.
It should have an ON/OFF toggle in the popup.
Output <promise>COMPLETE</promise> when the extension loads and the toggle works.
--done-when 'COMPLETE' --max-rounds 25
```

KIISH will scaffold the extension, fix any errors, test it, and keep going until it works.
