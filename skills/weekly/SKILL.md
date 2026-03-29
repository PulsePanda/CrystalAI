---
name: crystal:weekly
description: "This skill should be used when the user asks to 'weekly review', 'run weekly review', 'end of week', or types '/weekly'. Synthesizes the week's session logs into permanent memory, consolidates and compresses state, writes weekly digest files, checks project hygiene, and surfaces upcoming commitments. Also runs a monthly rollup if it's the first weekly run of a new month."
version: 2.0
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# /weekly — Weekly Review + Dream Consolidation

Two jobs in one: (1) the weekly review surfaces what happened and what's coming, (2) the dream pass consolidates, compresses, and cleans state — like sleep consolidation for the brain.

Run every Friday afternoon or Monday morning.

## Paths

All state paths are relative to `${CLAUDE_PLUGIN_ROOT}`:
- **Sessions:** `state/sessions/`
- **Weekly digests:** `state/sessions/digests/weekly/`
- **Monthly digests:** `state/sessions/digests/monthly/`
- **Behavioral:** `state/behavioral/`
- **Operational:** `state/operational/`
- **Memory:** `state/memory/`
- **Contacts:** `state/memory/contacts.md`

Create digest directories if they don't exist.

---

## Step 1: Load Current State

Read in parallel:
- `state/behavioral/` — all domain files
- `state/operational/corrections.md`
- `state/operational/known-errors.md`
- `state/memory/contacts.md` (if exists)

This is the baseline for detecting what's new and what's stale.

## Step 2: Scan Sessions + Write Weekly Digest

Glob `state/sessions/*.md`. Filter to the past 7 days by filename date prefix. Read each — extract:
- Key learnings and decisions
- Errors or corrections
- People mentioned (names, emails, roles) — hold for Step 3
- Projects touched

**Write the weekly digest** to `state/sessions/digests/weekly/YYYY-WXX.md`:

```markdown
---
type: weekly-digest
week: YYYY-WXX
date-range: YYYY-MM-DD to YYYY-MM-DD
sessions: N
---

# Weekly Digest — Week of YYYY-MM-DD

## Summary
[2-4 sentence narrative: what was the shape of this week? Main themes,
biggest wins, key shifts. Written for someone skimming months later.]

## Decisions & Outcomes
[Organized by project/area, not by date. Each entry is a decision or
outcome with enough context to be useful standalone.]

### [Project/Area Name]
- **[Decision/Outcome]** — [Context: why, what changed, what it affects]

### [Another Area]
- **[Decision/Outcome]** — [Context]

## Open Threads
- [Anything started but not resolved this week, with current state]
```

The digest is the persistent artifact. The live presentation to the user (Step 10) is separate.

## Step 3: Memory Maintenance

Three passes on the same state files:

### 3a: Promote New Learnings
For each learning from Step 2, check if it's already captured in `state/behavioral/` or `state/operational/`. If not, add it to the appropriate file:
- Behavioral rule → `state/behavioral/[domain].md`
- Error + fix → `state/operational/known-errors.md`
- Preference → `state/behavioral/user-preferences.md`

Corrections appearing 2+ times in `state/operational/corrections.md` → promote to Standing Order in the appropriate behavioral domain file.

### 3b: Consolidate Redundant State
Read all `state/behavioral/` files and `state/memory/` files. Look for:
- **Duplicate rules** — same guidance stated differently in two files → merge into one, delete the other
- **Contradictory rules** — conflicting guidance → keep the more recent one, note the resolution
- **Verbose entries** — rules that can be stated more concisely without losing meaning → tighten them
- **Orphaned references** — rules referencing files, paths, or tools that no longer exist → remove or update

Don't be aggressive — only consolidate when the redundancy is clear. When in doubt, leave it.

### 3c: Extract Contacts
From this week's sessions, extract any people mentioned with identifying info (name, email, role, organization). Update `state/memory/contacts.md`:

```markdown
---
type: reference
description: Known contacts extracted from sessions
last-updated: YYYY-MM-DD
---

# Contacts

| Name | Email | Role | Org | Last Seen |
|------|-------|------|-----|-----------|
| Jesse | jesse@example.com | Co-owner | Umbrella | 2026-03-27 |
```

Merge with existing entries — update Last Seen, add new info, don't duplicate.

## Step 4: Project Hygiene

Glob `Projects/*.md` (exclude `_template.md`) from the vault.

**Active projects:** Flag if Last Updated > 2 weeks. Check Waiting On tables — anything resolved? Ensure Things3 tasks exist for all waiting items and future dates.

**On-hold projects:** Has the blocker resolved? Recommend promoting to active if so.

**Planned projects:** Has anything changed that makes it ready to start?

## Step 5: Things3 Review

Use the **things3 tool skill**:
1. `view-todos("Today")` — overdue items
2. `view-todos("Upcoming")` — next 7 days

## Step 6: Playbook Learning

Read `${CLAUDE_PLUGIN_ROOT}/skills/process-email/references/playbook.md` Learning Log. Promote any sender appearing 2+ times to a permanent Sender Rule.

## Step 7: State Hygiene

Three checks in one pass:

**Known errors:** Read `state/operational/known-errors.md`. Add any new errors from this week's sessions.

**Stale references:** Grep `state/` for file paths and check if they still exist. Flag or remove dead references.

**Frontmatter validation:** Spot-check `state/` files for valid YAML frontmatter (type, description, purpose fields present). Flag files missing required fields.

## Step 8: Calendar Look-Ahead

Use the **calendar skill** — pull the next 7 days. Filter to the user's approved calendars only. Flag events that need prep.

## Step 9: Automation Ideas

Read `automation-ideas.md` from the Claude Code auto-memory directory. For each `idea` or `scoped` entry, check if it appeared in this week's sessions or if related work makes it practical now. Update status to `scoped` if ready. Omit section from digest if nothing surfaces.

**Implementation type lens:** For each candidate, classify what shape the automation takes:
- **Hook** — "every time X happens, check/validate/block Y" patterns. PreToolUse guards, PostToolUse validations, Stop-event cleanups. These are event-driven and reactive.
- **Skill** — multi-step workflows invoked by the user or another skill. These are intentional and orchestrated.
- **Script** — standalone automation that runs on a schedule or trigger (cron, n8n, heartbeat job). These are autonomous and recurring.

Include the type in the recommendation so candidates accumulate in the right bucket.

## Step 10: Monthly Rollup (Conditional)

Check: does a monthly digest exist for last month? Glob `state/sessions/digests/monthly/YYYY-MM.md`.

If we're in a new month and last month's digest doesn't exist, create it:

1. Read all weekly digests from last month (`state/sessions/digests/weekly/YYYY-W*.md`)
2. Synthesize into `state/sessions/digests/monthly/YYYY-MM.md`:

```markdown
---
type: monthly-digest
month: YYYY-MM
weeks: [WXX, WXX, WXX, WXX]
sessions: N
---

# Monthly Digest — YYYY Month Name

## Summary
[3-5 sentence narrative of the month's arc — what moved, what shipped,
what shifted. Written for someone reading this 6 months from now.]

## Key Decisions & Outcomes
[Same structure as weekly: organized by project/area, not chronologically.
Elevated from weekly digests — only include decisions that still matter
at month scale. Skip small fixes and routine maintenance.]

### [Project/Area]
- **[Decision]** — [Context]

## Open Threads Carried Forward
- [Threads still open at month end]
```

## Step 11: Present Weekly Digest

Present a scannable summary to the user:

```markdown
# Weekly Review — Week of YYYY-MM-DD

## This Week (N sessions)
- [1-line summary per session]

## Promoted to Memory
- [What was added to behavioral/operational/preferences]
- (nothing new) if already captured

## Consolidated
- [Merged N redundant entries, removed N stale references]
- (nothing to consolidate) if state was clean

## Project Health
- [status icon] [project] — [note]

## Overdue Tasks
- [task] — was due [date]

## Coming Up
- [date] — [event or task]

## Playbook Updates
- [sender rules added / nothing new]

## Automation Candidates
- [idea] — [recommendation] (omit if none)

## Brain Health
- Corrections promoted: N
- Known errors added: N
- Contacts updated: N
- State files cleaned: N
- Monthly rollup: [created / not due]
```

Also write this digest to the weekly digest file if not already written in Step 2 (Step 2 writes the A+C digest; this is the full operational summary shown live).

---

## Digest Retrieval Pattern

When searching for past work, use the digest tree in reverse:
1. Monthly digests → find the right month
2. Weekly digests → find the right week
3. Individual sessions → find the exact session

This is faster than grepping 150+ session files for context.

---

**Last Updated:** 2026-03-27
