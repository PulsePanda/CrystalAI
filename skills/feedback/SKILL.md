---
name: feedback
description: ALWAYS use this skill the moment the user corrects the assistant's behavior or sets a new rule for how the assistant should operate. This is the permanent correction handler — it logs corrections, routes them to the right files, and ensures the user never has to repeat themselves. Trigger on corrections ("no thats wrong", "stop doing X", "don't do that", "wrong approach"), new standing rules ("from now on", "going forward always", "whenever you do X make sure to Y"), behavioral directives ("stop asking me to confirm", "just do it without asking", "less formal", "be more concise"), factual corrections ("remember that X is actually Y", "the right path is X not Y"), style/tone rules ("don't say 'great idea'", "no emojis"), output format changes ("put X before Y", "use this format instead"), and permission/workflow changes ("auto-allow writes to X", "stop confirming before Y"). The key signal is that the user is telling the assistant to CHANGE its behavior, not asking the assistant to evaluate something. Do NOT trigger when the user asks the assistant to review, critique, or give feedback on the user's own work — that's content review, not behavioral correction.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Grep
---

# Feedback & Correction Handler

When the user corrects something, route it immediately to the right permanent homes. Don't wait, don't ask. Act and confirm briefly.

## Step 1: Classify the Feedback

Determine what kind of correction this is — it may be more than one:

| Type | Examples | Destination |
|------|---------|------------|
| **Tone/style** | "Don't say 'great idea'", "stop using emojis", "less formal" | `${STATE_PATH}/behavioral/user-preferences.md` + global CLAUDE.md if universal |
| **Behavioral** | "Don't ask me to confirm every step", "stop summarizing at end" | `${STATE_PATH}/operational/corrections.md` + global CLAUDE.md standing orders |
| **Skill-specific** | "In /compress, don't ask for reflections", "email should batch 5 at a time" | Relevant skill's SKILL.md |
| **Workflow pattern** | "When ball is in someone's court, always create follow-up task" | `${STATE_PATH}/behavioral/` domain files + relevant skill if applicable |
| **Permission/auto-approve** | "Stop asking me to approve X", "auto-allow writes to Y" | `settings.local.json` (project) or `~/.claude/settings.json` (global) |
| **One-time fix** | "That file path was wrong" | Just acknowledge — no permanent update needed |

If it's a one-time situational fix, skip the logging steps and just fix it.

---

## Step 2: Log to Corrections Log

Always log non-trivial corrections to `${STATE_PATH}/operational/corrections.md`.

**Format — append a row to the log table:**
```
YYYY-MM-DD | [what was wrong] | [correct behavior] | → Standing Order? [yes/no/maybe]
```

Check if a similar correction already exists before adding. If it's a repeat, note it — two strikes means it needs to become a standing order.

---

## Step 3: Route to Permanent Files

### If tone/style → `${STATE_PATH}/behavioral/user-preferences.md`
Add or update the relevant section. Keep it specific and behavioral.

### If behavioral/universal → global CLAUDE.md (standing orders)
Read the Standing Orders section and add the rule under the appropriate heading. Be concise — one line, imperative form.

**Only add to global CLAUDE.md if the rule applies across all contexts.** Project-specific rules go in the project CLAUDE.md instead.

### If skill-specific → the relevant skill's SKILL.md
Find the right section and update it. If the correction negates an existing instruction, remove or replace it — don't leave contradictory instructions.

### If permission/auto-approve → settings files

Add a rule to the appropriate `permissions.allow` array:

- **Project-specific** → `.claude/settings.local.json` in the project root
- **Global (all projects)** → `~/.claude/settings.json`

**Path prefix syntax:**
- `//absolute/path/**` — absolute filesystem path
- `~/path/**` — home directory relative
- `/path/**` — project root relative
- `path/**` — current directory relative

**Rule formats:**
- `Write(path)` / `Edit(path)` — file write/edit by path pattern
- `Read(path)` — file read by path pattern
- `Bash(command*)` — bash commands matching glob
- `mcp__server__tool` — specific MCP tool call
- `Skill(name)` — skill invocations
- `WebFetch(domain:example.com)` — fetches to a specific domain
- `WebSearch` — all web searches

Read the existing file first, then append to the `allow` array — never overwrite the whole file.

---

### If cross-session memory → auto-memory feedback file
Write or update a feedback memory file in the Claude Code auto-memory directory for this project.

Use the standard feedback memory format:
```markdown
---
name: [short name]
description: [one-line — what behavior this corrects]
type: feedback
---

[The rule itself — imperative form]

**Why:** [the user's reason, even if brief]
**How to apply:** [when/where this kicks in]
```

Then add a pointer to it in `MEMORY.md`.

---

## Step 4: Confirm Briefly

One line. Tell the user what was updated and where. Don't explain or justify — just report.

**Good:** "Got it — logged to corrections.md and added to Standing Orders."
**Good:** "Updated — removed the reflections prompt from /compress."
**Bad:** "I've updated the corrections log at state/operational/corrections.md, added a new standing order to CLAUDE.md under the Communication section, and also made a note in the user-preferences file. Let me know if you'd like me to change anything about how I recorded this."

---

## What NOT to Do

- Don't ask the user to confirm before applying the correction
- Don't repeat the correction back to them in full
- Don't apologize excessively
- Don't make it a bigger moment than it is — just fix it and move on
- Don't add corrections to CLAUDE.md that are too narrow to be useful globally
