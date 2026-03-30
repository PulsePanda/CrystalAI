---
name: resume
description: This skill should be used when the user asks to "resume memory", "load context", "check stored memory", "what was I working on", "restore previous context", or starts a session and wants to know where they left off. Reads recent session logs, checks today's calendar and tasks, reviews active projects, and checks the daily note. Use this at the start of any session to restore context.
version: 2.0.0
allowed-tools: Read, Bash, Grep, Glob
---

# Resume Memory from Vault

Restore context from the previous session and orient for today's work.

> CLAUDE.md files are auto-loaded — no need to re-read them. Use the context already in scope.

## Arguments

- `/resume` — today's tasks, calendar, active projects, last session context
- `/resume [keyword]` — standard resume + grep for keyword in session logs
- `/resume [N] [keyword]` — standard resume + grep for keyword in last N sessions

---

## Steps

Run Steps 0-4 in parallel, then present the summary.

### Step 0: Get Current Time

```bash
date '+%I:%M %p, %A %B %e'
```

Include this in the summary header.

### Step 1: Read Last Session (for "Where We Left Off")

```
Glob: ${STATE_PATH}/sessions/*.md
```

Glob returns files sorted by modification time (newest first). Read **only the most recent session's** Quick Reference section (topics, projects, outcome) — this populates the "Where We Left Off" summary. Do not list or read additional sessions unless a search filter argument was provided.

### Step 2: Query Task Manager (if configured)

Check `${CONFIG_PATH}` for task manager configuration. If configured:
- Pull today's tasks using the configured integration
- Present them in the summary

If no task manager is configured, skip this section silently.

### Step 3: Query Today's Calendar (if configured)

Check `${CONFIG_PATH}` for calendar configuration. If calendar names or a calendar integration is configured:
- Query only the user's configured calendars
- Do NOT query without a calendar filter — respect the user's calendar whitelist
- If a calendar returns no events, skip it silently

If no calendar is configured, skip this section silently.

### Step 4: Check Active Projects + Daily Note

**Projects:** If a vault path is configured, glob `${VAULT_PATH}/Projects/*.md` and `${VAULT_PATH}/Projects/*/`, exclude templates and `Archive/`. If no vault is configured, check `${STATE_PATH}/` for any project tracking files, or skip this section. Read each project file with `limit: 5` to get frontmatter. **Only surface projects where `status` is `active`.** Skip `planned`, `on-hold`, `completed`, and `archived`.

**Today's daily note:** Check if today's note exists at `${VAULT_PATH}/Daily Notes/YYYY-MM-DD.md`. If it exists, read it for context. If a daily note template is configured and the note doesn't exist, create it from the template. Get the day name via `date '+%A'` (never guess).

---

## Summary Format

```markdown
## Session Start — [HH:MM AM/PM, Day]

## Where We Left Off
[Last session outcome — 1-2 sentences]

## Today's Calendar
- HH:MM — Event Name [Calendar]
(omit section if no calendar configured or no events)

## Today's Tasks
- [ ] Task name
- [ ] Task name
(omit section if no task manager configured)

## Active Projects
- **Project Name** — [one-line status + next step]
```

Keep it tight — this is orientation, not a report. Lead with what matters most.

---

## Search Filter (if argument provided)

If a search term was given, use the Grep tool to search `${STATE_PATH}/sessions/` for matching sessions. Read those sessions' Quick Reference sections and surface relevant context.

---

## Error Handling

- **No session logs:** First session — skip that section, show tasks and projects
- **Task manager unavailable:** Note it, continue with vault context
- **Calendar unavailable:** Note it, continue
- **No active projects:** Skip the projects section
