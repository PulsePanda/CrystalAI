---
name: crystal:weekly
description: This skill should be used when the user asks to "weekly review", "run weekly review", "end of week", or types "/weekly". Synthesizes the week's session logs into permanent memory, checks project hygiene, promotes patterns to standing orders, and surfaces upcoming commitments.
version: 1.0
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# /weekly - Weekly Review

Synthesize the past week's work into durable knowledge. Keeps the brain clean, promotes patterns, and surfaces what's coming up.

## When to Run

Every Monday morning (or Friday afternoon). Takes ~5 minutes. Creates a brief digest of the week and ensures nothing falls through the cracks.

## Step-by-Step Workflow

### Step 1: Load Current Memory State

Read in parallel:
- `state/behavioral/` domain files (standing orders, decomposed)
- `state/operational/corrections.md`
- `state/operational/known-errors.md`
- `state/behavioral/austin-preferences.md`

This establishes the baseline — we're looking for what's changed this week and what should be promoted.

### Step 2: Scan This Week's Sessions

```
Glob: state/sessions/*.md
```

Take all session logs from the past 7 days (filter by filename date prefix). Read each one — focus on:
- **Key Learnings** section
- **Decisions Made** section
- Any corrections or errors mentioned in Raw Session Log

Compile a flat list of learnings and patterns across all sessions.

### Step 3: Promote Learnings to Permanent Memory

For each learning or pattern identified in Step 2:

**Is it already captured somewhere?**
- Check `state/behavioral/` domain files, `state/operational/known-errors.md`, `state/behavioral/austin-preferences.md`
- If yes → skip
- If no → add it to the appropriate file:
  - Behavioral rule → `state/behavioral/` domain files
  - Error + fix → `state/operational/known-errors.md`
  - Style/preference → `state/behavioral/austin-preferences.md`
  - Vault/workflow pattern → vault root `CLAUDE.md`

**Promoting a correction to a Standing Order:**
- Check `state/operational/corrections.md` — if any entry appears 2+ times, it must become a Standing Order
- Add to appropriate `state/behavioral/` domain file and mark `→ Standing Order? ✅` in corrections table

### Step 4: Project Hygiene Audit

```
Glob: Projects/*.md (exclude _template.md)
```

Review projects in three groups:

**Active projects (status: active):**
1. **Last Updated** — is it within the last 2 weeks? If stale, flag it.
2. **Waiting On table** — are all rows still accurate? Has anything resolved that should be cleared?
3. **Things3 follow-up tasks** — does every row in the Waiting On table have a Things3 task? If not, create one.
4. **Future dates in Next section** — does each have a Things3 task?

**On-hold projects (status: on-hold):**
1. Has the blocking condition resolved? (third party responded, trigger date passed, etc.)
2. If yes → recommend promoting to `active`
3. If still blocked → leave as-is, note the blocker

**Planned projects (status: planned):**
1. Has anything changed that makes this ready to start? (dependency met, bandwidth freed up, related work completed)
2. If yes → recommend promoting to `active`
3. If not → leave as-is

Present a brief project health summary:
```
Active:
  ✅ spectrum-voip — up to date, waiting on Kim (task set for 3/24)
  ⚠️  raptor-visitorsafe — Last Updated is 3 weeks ago, review needed

On-hold (3):
  🔄 fastbridge-clever-sync — still waiting on Orry, leave as-is
  ➡️  insurance-switch — trigger date passed, recommend → active

Planned (2):
  💤 youtube-transcript-skill — no change, leave as-is
  💤 tax-financial-agent — no change, leave as-is
```

### Step 5: Review Things3 — Overdue & Upcoming

Use the **`things3` tool skill** to query:
1. `view-todos("Today")` — anything still sitting there that wasn't completed
2. `view-todos("Upcoming")` — tasks due in the next 7 days

Present as:
```
Overdue (needs attention):
- Task name (was due March X)

Coming up this week:
- Task name (due March X)
```

### Step 6: Playbook Learning Log → New Sender Rules

Read `${CLAUDE_PLUGIN_ROOT}/skills/process-email/references/playbook.md` Learning Log table.

For any new entries added this week:
1. Should this become a permanent sender rule? (If same sender appears 2+ times → yes)
2. If yes → add to Sender Rules table in playbook
3. If it's an archive rule → add to `${CLAUDE_PLUGIN_ROOT}/skills/process-email/references/gmail-filters.xml`

### Step 7: Review Known Errors

Read `state/operational/known-errors.md`.

Check session logs for any new errors encountered this week that aren't yet documented. Add them.

### Step 8: Calendar Look-Ahead

Use the calendar skill to pull the next 7 days:
```
start_date: today T00:00:00
end_date: today+7 T23:59:59
```

Filter to Austin's calendars only (same rule as /resume). Present upcoming events with anything that needs prep flagged.

### Step 9: Automation Ideas Review

Read `~/.claude/projects/-Users-Austin-Library-Mobile-Documents-iCloud-md-obsidian-Documents-VaultyBoi/memory/automation-ideas.md`.

For each entry with status `idea` or `scoped`:
1. Has it appeared in multiple session logs this week (grep session logs for the idea name/topic)?
2. Does the context suggest it's now practical to build (related work was done, tooling is in place, etc.)?

Flag anything that meets either condition as **ready to surface**. Include it in the weekly digest under "Automation Candidates" with a one-line recommendation.

For anything flagged as ready, update its status in `automation-ideas.md` from `idea` → `scoped` if it hasn't been scoped yet.

If nothing is ready to surface, omit the section from the digest entirely.

---

### Step 10: Present Weekly Digest

```markdown
# Weekly Review — Week of YYYY-MM-DD

## This Week's Sessions
- Session 1 summary (1 line)
- Session 2 summary (1 line)
...

## Promoted to Permanent Memory
- [List anything added to standing-orders, known-errors, preferences, etc.]
- (nothing new) if all learnings were already captured

## Project Health
- ✅/⚠️ [project] — [status note]

## Overdue Tasks
- [task] — was due [date]

## Coming Up This Week
- [date] — [event or task]

## Playbook Updates
- Added X new sender rules / nothing new

## Automation Candidates
- [idea] — [one-line recommendation] _(omit section if nothing is ready)_

## Brain Health
- [Any corrections promoted to Standing Orders?]
- [Any known errors added?]
```

## Output Format

Keep it scannable. No walls of text. The goal is a 2-minute read that tells Austin:
- What happened this week
- What the brain learned
- What needs attention
- What's coming up

---

**Last Updated:** 2026-03-20
