---
name: resume
description: "Session start and context restoration. Trigger at the START of any session: '/resume', 'resume', 'load context', 'what was I working on', 'where were we', 'catch me up', 'what did I miss', 'morning briefing', 'start of day'. ALSO trigger on greetings that signal session start: 'good morning', 'hello', 'hey', 'hi', 'let's get started', 'what's up', 'let's go'. Reads recent session logs, queries tasks for today, checks today's calendar, reviews active projects, and checks the daily note. Do NOT trigger for: mid-session project loading (use project-load), or weekly review (use weekly)."
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

## Configuration

This skill reads from `~/.claude/skill-configs/resume.yaml` if present. Available options:
- `calendars`: List of calendar names to query (default: all available calendars)
- `lookahead_days`: How many days ahead to show (default: 1)
- `post_steps`: Additional skills to run after resume completes (e.g., server health checks)

If no config file exists, the skill queries all available calendars and skips post_steps.

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

Read the calendar list from `skill-configs/resume.yaml` if it exists. If no config, query all available calendars. If calendar names or a calendar integration is configured:
- Query only the user's configured calendars
- Do NOT query without a calendar filter — respect the user's calendar whitelist
- If a calendar returns no events, skip it silently

If no calendar is configured, skip this section silently.

### Step 4: Check Active Projects + Daily Note

**Projects:** If a vault path is configured, run **two parallel Glob calls:**
- `${VAULT_PATH}/Projects/*.md` — single-file projects (exclude `_template*.md`)
- `${VAULT_PATH}/Projects/*/_project.md` — folder projects (derive project name from parent directory; exclude `Archive/`)

**Important:** Never use `Projects/*/` to find directories — Glob doesn't reliably match directories. Always glob for `_project.md` inside project folders instead.

If no vault is configured, check `${STATE_PATH}/` for any project tracking files, or skip this section. Read each project file with `limit: 5` to get frontmatter. **Only surface projects where `status` is `active`.** Skip `planned`, `on-hold`, `completed`, and `archived`.

**Today's daily note:** Check if today's note exists at `${VAULT_PATH}/Daily Notes/YYYY-MM-DD.md`. If it exists, read it for context. If it does not exist, create it: use `${VAULT_PATH}/_Templates/daily-note.md` if the template exists (substituting `{{date}}` → YYYY-MM-DD and `{{day}}` → day name from `date '+%A'`); otherwise create a minimal note with `# YYYY-MM-DD, Day` and a `## Session Summaries` section. Get the day name via `date '+%A'` (never guess).

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

---

## Post Steps

After all steps complete, check `skill-configs/resume.yaml` for `post_steps` and execute each listed skill.
