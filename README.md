# KIISH
### Keep Iterating In Smart Harmony

**KIISH is a Claude Code plugin that works on your project non-stop — round after round — until the job is done.**

No more prompting Claude once and getting a half-finished answer. You give KIISH a task, and it keeps building, fixing, and improving on its own — using everything it learned in the previous round — until your project is complete.

---

## What Does It Do?

Most AI tools stop as soon as they give you an answer.

KIISH doesn't stop.

When you give KIISH a task, it works on it and then — instead of quitting — loops back and picks up right where it left off. It can see every file it already created, every test it ran, every error it hit. So each round, it gets smarter about your specific project.

You walk away. KIISH keeps building. You come back to something that works.

---

## Who Is This For?

- You want to build something but don't want to babysit Claude through every step
- You have a feature that needs iteration (tests failing, bugs to fix, edge cases to handle)
- You're a non-technical founder who wants to describe what you want and let it run
- You're a developer who wants to delegate long, repetitive build tasks

---

## Quick Start

**Step 1: Install the plugin**

```bash
claude plugin install kiish
```

**Step 2: Go to your project folder**

```bash
cd my-project
```

**Step 3: Give KIISH a task**

```bash
/kiish Build a Chrome extension with an ON/OFF toggle --max-rounds 20 --done-when 'COMPLETE'
```

That's it. KIISH will work until the extension is done or until it hits 20 rounds.

---

## Commands

### `/kiish` — Start a build loop

```
/kiish YOUR TASK [--max-rounds N] [--done-when 'PHRASE']
```

| Option | What it does | Example |
|---|---|---|
| `--max-rounds` | Stop after this many rounds | `--max-rounds 20` |
| `--done-when` | Stop when this phrase is output | `--done-when 'COMPLETE'` |

**Examples:**

```bash
# Build a feature with a 20-round safety limit
/kiish Build a settings page for my app --max-rounds 20

# Fix a bug and stop when it's confirmed fixed
/kiish Fix the login bug in auth.ts --done-when 'FIXED' --max-rounds 10

# Build a full API with tests
/kiish Build a REST API with full test coverage. Output <promise>ALL TESTS PASSING</promise> when done. --done-when 'ALL TESTS PASSING' --max-rounds 40
```

---

### `/cancel-kiish` — Stop early

```bash
/cancel-kiish
```

Stops the loop immediately. Everything KIISH built so far is kept — nothing is deleted.

---

### `/kiish-help` — Full help

```bash
/kiish-help
```

---

## How It Works (Plain English)

1. You run `/kiish` with your task
2. KIISH saves your task to a small file in your project
3. Claude starts working — writing code, running tests, fixing errors
4. When Claude tries to finish, KIISH steps in and sends it back in for another round
5. Claude sees all its previous work (files, git history, test results) and builds on it
6. This continues until:
   - Claude outputs your finish signal (`--done-when`), OR
   - It hits the round limit (`--max-rounds`), OR
   - You stop it with `/cancel-kiish`

---

## Tips for Best Results

**Always set `--max-rounds`** — without it, KIISH runs forever. A good starting number is 15–30.

**Be specific in your task.** The more detail you give, the better the result:

❌ Vague:
```
/kiish Make a website
```

✅ Specific:
```
/kiish Build a landing page for a productivity app. It should have a hero section,
3 feature cards, a pricing table with 2 tiers, and a contact form.
Use Tailwind CSS. Output <promise>COMPLETE</promise> when all sections are done.
--done-when 'COMPLETE' --max-rounds 20
```

**Use a finish signal for quality control.** When you include a `--done-when` phrase, Claude will only stop when it's confident the work meets that bar:

```
/kiish Build a login system with email/password auth.
All tests must pass. Output <promise>ALL TESTS PASSING</promise> when done.
--done-when 'ALL TESTS PASSING' --max-rounds 30
```

---

## Watching Progress

Check what round KIISH is on:
```bash
grep '^iteration:' .claude/kiish.local.md
```

See the full state:
```bash
head -10 .claude/kiish.local.md
```

---

## Real Results

The technique behind KIISH has been used to:
- Generate 6 complete repositories in a single overnight session
- Complete a $50,000 contract for $297 in AI costs
- Build an entire programming language over 3 months, fully autonomously

KIISH brings this approach to everyone — no bash scripting required.

---

## FAQ

**Will it delete my files if something goes wrong?**
No. KIISH only adds and modifies files based on the task you gave it. It does not delete your project.

**What if I want to stop it?**
Run `/cancel-kiish`. Your work is safe.

**What if it runs too long?**
Set `--max-rounds` before you start. If you forget, `/cancel-kiish` always works.

**Does it need internet access?**
No. KIISH runs entirely inside Claude Code on your machine.

**Can I use it on any project?**
Yes — web apps, mobile apps, scripts, APIs, Chrome extensions, anything Claude Code can work on.

---

## Credits

KIISH is built on the [Ralph Loop technique](https://ghuntley.com/ralph/) by Geoffrey Huntley, originally implemented as the Ralph Loop plugin by Anthropic.

KIISH is a rebranded, redesigned, and extended version — focused on making autonomous AI loops accessible to everyone.

Built by [Jeshrum](https://github.com/Jeshrum) · Licensed under Apache 2.0
