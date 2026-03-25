---
name: crystal:feedback
description: This skill should be used immediately and automatically whenever Austin gives a correction, behavioral feedback, or guidance about how Claude should act differently. Trigger on any phrase like "don't say X", "stop doing Y", "never Z", "wrong approach", "instead do this", "I don't want you to", "that's not how", or any moment where Austin is correcting Claude's behavior, tone, output format, or workflow. Also trigger when Austin says something like "remember that..." or "going forward, always...". The goal is to make every correction stick permanently — log it, route it to the right files, and never make Austin repeat himself. Only trigger when Austin is correcting or guiding Claude — NOT when Austin is asking Claude to evaluate or give feedback on his own writing or content.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Grep
---

# Feedback & Correction Handler

When Austin corrects something, route it immediately to the right permanent homes. Don't wait, don't ask. Act and confirm briefly.

## Step 1: Classify the Feedback

Determine what kind of correction this is — it may be more than one:

| Type | Examples | Destination |
|------|---------|------------|
| **Tone/style** | "Don't say 'great idea'", "stop using emojis", "less formal" | `state/behavioral/austin-preferences.md` + global CLAUDE.md if universal |
| **Behavioral** | "Don't ask me to confirm every step", "stop summarizing at end" | `state/operational/corrections.md` + global CLAUDE.md standing orders |
| **Skill-specific** | "In /compress, don't ask for reflections", "email should batch 5 at a time" | Relevant skill's SKILL.md |
| **Workflow pattern** | "When ball is in someone's court, always create follow-up task" | `state/behavioral/` domain files + relevant skill if applicable |
| **Permission/auto-approve** | "Stop asking me to approve X", "auto-allow writes to Y" | `settings.local.json` (vault) or `~/.claude/settings.json` (global) |
| **One-time fix** | "That file path was wrong" | Just acknowledge — no permanent update needed |

If it's a one-time situational fix, skip the logging steps and just fix it.

---

## Step 2: Log to Corrections Log

Always log non-trivial corrections to `state/operational/corrections.md`.

**Format — append a row to the log table:**
```
YYYY-MM-DD | [what was wrong] | [correct behavior] | → Standing Order? [yes/no/maybe]
```

Check if a similar correction already exists before adding. If it's a repeat, note it — two strikes means it needs to become a standing order.

---

## Step 3: Route to Permanent Files

### If tone/style → `state/behavioral/austin-preferences.md`
Add or update the relevant section. Keep it specific and behavioral.

### If behavioral/universal → `~/.claude/CLAUDE.md` (global standing orders)
Read the Standing Orders section and add the rule under the appropriate heading (Communication, Email, Projects, etc.). Be concise — one line, imperative form.

**Only add to global CLAUDE.md if the rule applies across all contexts.** Vault-specific rules go in the vault CLAUDE.md instead.

### If skill-specific → the relevant skill's SKILL.md
Find the right section and update it. If the correction negates an existing instruction, remove or replace it — don't leave contradictory instructions.

### If permission/auto-approve → settings files

Add a rule to the appropriate `permissions.allow` array:

- **Vault-specific** → `.claude/settings.local.json` in the vault root
- **Global (all projects)** → `~/.claude/settings.json`

**Path prefix syntax:**
- `//absolute/path/**` — absolute filesystem path
- `~/path/**` — home directory relative
- `/path/**` — project root relative
- `path/**` — current directory relative

**Rule formats:**
- `Write(path)` / `Edit(path)` — file write/edit by path pattern
- `Read(path)` — file read by path pattern
- `Bash(command*)` — bash commands matching glob (space before `*` matters: `Bash(ls *)` matches `ls -la` but not `lsof`)
- `mcp__server__tool` — specific MCP tool call
- `Skill(name)` — skill invocations
- `WebFetch(domain:example.com)` — fetches to a specific domain
- `WebSearch` — all web searches

Read the existing file first, then append to the `allow` array — never overwrite the whole file.

---

### If cross-session memory → auto-memory feedback file
Write or update a feedback memory file at:
`/Users/Austin/.claude/projects/-Users-Austin-Library-Mobile-Documents-iCloud-md-obsidian-Documents-VaultyBoi/memory/`

Use the standard feedback memory format:
```markdown
---
name: [short name]
description: [one-line — what behavior this corrects]
type: feedback
---

[The rule itself — imperative form]

**Why:** [Austin's reason, even if brief]
**How to apply:** [when/where this kicks in]
```

Then add a pointer to it in `MEMORY.md`.

---

## Step 4: Confirm Briefly

One line. Tell Austin what was updated and where. Don't explain or justify — just report.

**Good:** "Got it — logged to corrections.md and added to Standing Orders."
**Good:** "Updated — removed the reflections prompt from /compress."
**Bad:** "Great feedback! I've carefully noted this correction and will make sure to never..."

---

## What NOT to Do

- Don't ask Austin to confirm before applying the correction
- Don't repeat the correction back to him in full
- Don't apologize excessively
- Don't make it a bigger moment than it is — just fix it and move on
- Don't add corrections to CLAUDE.md that are too narrow to be useful globally
