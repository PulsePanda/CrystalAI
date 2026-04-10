---
name: resume
description: "Session start and context restoration. Trigger at the START of any session: '/resume', 'resume', 'load context', 'what was I working on', 'where were we', 'catch me up', 'what did I miss', 'morning briefing', 'start of day'. ALSO trigger on greetings that signal session start: 'good morning', 'hello', 'hey', 'hi', 'let's get started', 'what's up', 'let's go'. Reads recent session logs, queries tasks for today, checks today's calendar, reviews active projects, and checks the daily note. Do NOT trigger for: mid-session project loading (use project-load), or weekly review (use weekly)."
version: 2.0.0
allowed-tools: Read, Bash, Grep, Glob
---

# Resume Memory from Vault

Restore context from the previous session and orient for today's work.

> CLAUDE.md files are auto-loaded — no need to re-read them. Use the context already in scope.

## Execution Mode

**Run silently.** Do not output anything to the user while gathering data — no status updates, no intermediate results, no "checking calendar..." narration. Gather everything quietly, then produce the Summary Format (below) as a single final report. That report is the only user-facing output from this skill.

## Arguments

- `/resume` — today's tasks, calendar, active projects, last session context
- `/resume [keyword]` — standard resume + grep for keyword in session logs
- `/resume [N] [keyword]` — standard resume + grep for keyword in last N sessions

---

## Configuration

This skill reads from `~/.claude/skill-configs/resume.yaml` if present. Available options:
- `lookahead_days`: How many days ahead to show (default: 1)
- `calendars`: list of calendar account commands to query for today's agenda (see Step 3). If unset, Step 3 is skipped silently.
- `calendar_whitelist`: optional list of calendar display names. When set, events from any calendar not on the list are silently discarded.
- `briefing_file`: path to an email/briefing file to include in Step 3b. If unset, Step 3b is skipped silently.
- `post_steps`: Additional skills to run after resume completes (e.g., server health checks)

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

Read `calendars` from `~/.claude/skill-configs/resume.yaml`. If unset or empty, skip this step silently.

Each entry in `calendars` is a shell command that returns today's agenda as a table with a `calendar` column. Example:

```yaml
calendars:
  - "<your-calendar-cli> personal calendar +agenda --today --format table"
  - "<your-calendar-cli> work calendar +agenda --today --format table"
calendar_whitelist:
  - Personal
  - Work
```

Run every configured command in parallel (one Bash call each). NEVER use osascript, Calendar.app, or any other method — the configured commands are the source of truth.

If `calendar_whitelist` is set, only show events whose calendar name exactly matches an entry in the list. Silently discard everything else. If `calendar_whitelist` is unset, show every event returned.

If any command errors (auth failure, timeout), skip it silently and continue with the others. If all commands error or return no events after filtering, show "Clear day — no events scheduled."

### Step 3b: Briefing Digest (if configured)

Read `briefing_file` from `~/.claude/skill-configs/resume.yaml`. If unset, skip this step silently.

Read the file at the configured path. If the file doesn't exist or contains only a header comment block (no run entries), skip this step silently.

If briefing entries exist:
1. Parse all run blocks delimited by `---`
2. Synthesize across ALL runs into a high-level executive summary:
   - Count totals: "Handled X emails (Y archived, Z forwarded)" (or the equivalent for whatever the briefing tracks)
   - Separate handled items into tiers when the data supports it (rule-based vs. classifier-based, for example) so the user can spot-check automated decisions
   - For surfaced items: present sender/source, what they want, and any context available
   - For errors: mention which sources had issues
3. Present using this format:

```markdown
### Briefing
**Handled:** X items since last session (Y archived, Z forwarded)
- [Aggregate summary — 1 sentence]
- [Individual judgment-based items, if any — one line each with source + summary]

**Needs You** (N items):
- **Source Name** (context) — What they want/said [Classification]
```

Tone: a personal assistant giving a morning briefing — a few sentences that convey the shape of the day, not a dump of every entry.

4. After presenting, clear the briefing file — reset it to just the header comment block (preserve the header, remove all run blocks)

### Step 4: Check Active Projects + Daily Note

**Projects:** Run **two parallel Glob calls** against `~/Documents/Projects/`:
- `~/Documents/Projects/*/_project.md` — folder projects (the current layout; derive project name from the parent directory; exclude `_template/` and any `archive/` or `_archive/` paths)
- `~/Documents/Projects/*.md` — legacy single-file projects, for backwards compatibility (exclude `_template*.md`)

**Important:** Never use `Projects/*/` to find directories — Glob doesn't reliably match directories. Always glob for `_project.md` inside project folders instead.

Read each project file with `limit: 5` to get frontmatter. **Only surface projects where `status` is `active`.** Skip `planned`, `on-hold`, `completed`, and `archived`.

**Today's daily note:** Check if today's note exists at `${VAULT_PATH}/Daily Notes/YYYY-MM-DD.md`. If it exists, read it for context. If it does not exist, create it: use `${VAULT_PATH}/_Templates/daily-note.md` if the template exists (substituting `{{date}}` → YYYY-MM-DD and `{{day}}` → day name from `date '+%A'`); otherwise create a minimal note with `# YYYY-MM-DD, Day` and a `## Session Summaries` section. Get the day name via `date '+%A'` (never guess).

### Step 5: Check Wiki Pending Ingest (if enabled)

Check two sources for pending ingest material:

1. `~/.claude/wiki/raw/` — files waiting to be ingested. Count them, note oldest file date. If the directory doesn't exist, skip this source.
2. **Task manager `@capture` label** (if a task manager is configured in `${CONFIG_PATH}`) — quick captures added on the go. Query via the configured integration and count them. If no task manager is configured, skip this source.

Also check `~/.claude/wiki/log.md` if it exists — read the last entry to see when the last ingest or lint happened.

If both sources are empty (or unavailable), omit the Wiki section from the summary entirely. Otherwise, combine the counts in the briefing.

---

## Summary Format

```markdown
## Session Start — [HH:MM AM/PM, Day]

## Where We Left Off
[Last session outcome — 1-2 sentences]

## Today's Calendar
- HH:MM — Event Name [Calendar]
(omit section if no calendar configured or no events)

### Briefing
**Handled:** X items since last session (Y archived, Z forwarded)
- [Thematic summary]

**Needs You** (N items):
- **Source Name** (context) — What they want/said [Classification]
(omit entire section if no `briefing_file` is configured or the file is empty)

## Today's Tasks
- [ ] Task name
- [ ] Task name
(omit section if no task manager configured)

## Active Projects
- **Project Name** — [one-line status + next step]

## Wiki
X sources pending ingest (N in raw/, M in `@capture`). Last activity: [date — ingest/lint/bootstrap].
(omit section if both sources are empty or unavailable)
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
