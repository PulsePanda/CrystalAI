---
name: crystal:resume
description: This skill should be used when the user asks to "resume memory", "load context", "check stored memory", "what was I working on", "restore previous context", or starts a session and wants to know where they left off. Reads recent session logs, queries Things3 for today's tasks, checks today's calendar, reviews active projects, and checks the daily note. Use this at the start of any session to restore context.
version: 2.0.0
allowed-tools: Read, Bash, Grep, Glob
---

# Resume Memory from Vault

Restore context from the previous session and orient for today's work.

> CLAUDE.md (vault root) and ~/.claude/CLAUDE.md are auto-loaded — no need to re-read them. Use the context already in scope.

## Arguments

- `/resume` — today's tasks, calendar, active projects, last session context
- `/resume auth` — standard resume + grep for "auth" in session logs
- `/resume 10 voip` — standard resume + grep for "voip" in last 10 sessions

---

## Steps

Run Steps 0–6 in parallel, then present the summary.

### Step 0: Get Current Time

```bash
date '+%I:%M %p, %A %B %e'
```

Include this in the summary header. Use it to inform tone and context — e.g., if it's past 6:30 AM on a school day, the user is likely already on-site or in transit, not at their desk.

### Step 1: Read Last Session (for "Where We Left Off")

```
Glob: ${CLAUDE_PLUGIN_ROOT}/state/sessions/*.md
```

Glob returns files sorted by modification time (newest first). Read **only the most recent session's** Quick Reference section (topics, projects, outcome) — this populates the "Where We Left Off" summary. Do not list or read additional sessions unless a search filter argument was provided.

### Step 2: Query Things3 for Today's Tasks

Use the **`things3` tool skill** — Pull a list of all the tasks marked for today. 

### Step 3: Query Today's Calendar

Use the **`calendar` tool skill** — Query each of the user's 7 approved calendars individually using the `calendar_name` parameter:

1. `TCGIS`
2. `KESA`
3. `Personal`
4. `Umbrella - Personal`
5. `GIS`
6. `SJA`
7. `Umbrella Internal`

**CRITICAL:** Do NOT query without a `calendar_name` filter. Do NOT include results from any other calendar (e.g., `INTERNAL Staff Calendar TCGIS`, `PUBLIC Twin Cities German Immersion School`, Chromebook Cart calendars, `Formula 1`, `Office/Admin Staff Calendar`). If a calendar returns no events, skip it silently.

### Step 5: Process Heart Queue

Read `${CLAUDE_PLUGIN_ROOT}/state/operational/heart-queue.md`. If any entries exist with `status: pending`, execute each one:
- **`things3-task` type:** Create the Things3 task using the things3 skill.
- After successful execution, remove the YAML block (between and including its `---` markers) from the file.
- If execution fails, add `last-error:` to the entry and leave it in place.
- Include a "Heart Queue" section in the summary if any tasks were processed.

### Step 5.5: Check Heart Notifications

Read `${CLAUDE_PLUGIN_ROOT}/state/operational/heart-notifications.md`. Count the rows in the table (ignore the header row).

- If rows exist: include a **Heart Notifications** section in the summary with the count and a brief list (account + subject, max 5 shown)
- Do not execute anything — just surface so the user knows to run `/process-email`
- If no rows, skip silently.

### Step 6: Read Cached Server Health

Read `${CLAUDE_PLUGIN_ROOT}/state/operational/health-check-results.md`. This file is updated daily by a launchd job (`com.crystalos.health-check`) that runs at 6 AM and on login.

- Parse the frontmatter: `overall`, `heart`, `canopy`, `content` status fields
- Parse `last-check-local` to show when the check ran
- If all statuses are `OK`: include a single line in the summary ("Servers: OK as of HH:MM AM")
- If any status is `WARN` or `FAIL`: include a **Server Health** section with the per-server status and the specific non-OK rows from the tables
- If the file doesn't exist or `last-check` is older than 48 hours, note "Health check stale — run `/server-health-check` for live results"

### Step 4: Check Active Projects + Daily Note

**Projects:** Glob `Projects/*.md`, exclude `_template.md`. Read each with `limit: 5` to get frontmatter. **Only surface projects where `status` is `active`.** Skip `planned`, `on-hold`, `completed`, and `archived` — those are reviewed during `/weekly`, not `/resume`.

**Today's daily note:** If today's note doesn't exist yet, create it from `_Templates/Daily Notes Template v2.md`. Get the day name via `date '+%A'` (never guess). Populate date fields and write it.

---

## Summary Format

```markdown
## Session Start — [HH:MM AM/PM, Day]

## Where We Left Off
[Last session outcome — 1-2 sentences]

## Today's Calendar
- HH:MM — Event Name [Calendar]
(omit if nothing on the user's calendars)

## Today's Tasks (Things3)
- [ ] Task name
- [ ] Task name

## Active Projects
- **Project Name** — [one-line status + next step]

## Server Health
Servers: OK (6:00 AM) | Heart: OK, Canopy: OK, Content: OK
(or if issues: show per-server WARN/FAIL with one-line detail)

## Heart Notifications
- N email items pending — run `/process-email` to resolve
  - [Account] Subject (max 5 shown)
```

Keep it tight — this is orientation, not a report. Lead with what matters most.

---

## Search Filter (if argument provided)

If a search term was given, use the Grep tool to search `${CLAUDE_PLUGIN_ROOT}/state/sessions/` for matching sessions. Read those sessions' Quick Reference sections and surface relevant context.

---

## Error Handling

- **No session logs:** First session — skip that section, show tasks and projects
- **Things3 unavailable:** Note it, continue with vault context
- **Calendar unavailable:** Note it, continue
- **No active projects:** Skip the projects section
