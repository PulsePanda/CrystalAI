---
name: crystal:compress
description: This skill should be used when the user asks to "compress this session", "save session log", "end session", "wrap up", or any time a working session is wrapping up and needs to be saved. Saves the session as a searchable log, extracts pending tasks to Things3, updates the daily note, and runs a hygiene pass to keep the vault clean. Use this at the end of any meaningful work session.
version: 2.0.0
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Compress Session to Memory

Save the current session as a searchable log, extract tasks to Things3, update the daily note, and run hygiene.

## Steps

1. Analyze conversation
2. Check for brag book wins (Step 1b)
3. Extract and create Things3 tasks
4. Generate session log
5. Save to vault
6. Update daily note
7. Hygiene pass

---

## Step 1: Analyze Current Conversation

Review the conversation and identify:
- **Topics** — main subjects (keywords for search)
- **Projects** — which active projects were involved
- **Outcome** — what was accomplished (one sentence)
- **Decisions made** — important choices and rationale
- **Key learnings** — non-obvious insights
- **Pending tasks** — action items not yet done
- **Files modified** — code or docs changed
- **Errors/workarounds** — problems solved

### Step 1b: Detect Brag Book Wins

Look for accomplishments that delivered value to GIS or SJA:
- Cost savings, avoided costs, problems fixed, reliability improvements, security enhancements, projects completed

**If wins detected:**
1. List each with a brief description
2. Ask: "Add to brag book? Which school? (gis/sja/skip)"
3. If confirmed, append to `Areas/Work/Brag Book/GIS.md` or `Areas/Work/Brag Book/SJA.md`:

```markdown
### YYYY-MM-DD: [Brief title]
**Category:** [cost savings | avoided cost | improvement | security | reliability]
**Impact:** [quantified if possible]
**Details:** [what happened and why it matters]
**Source:** session - [[YYYY-MM-DD-HHmm-topic]]
```

**If no wins detected:** skip silently.

---

## Step 2: Select Sections to Preserve

Include ALL sections that have content — no interactive checklist. Only omit a section if it genuinely has nothing from this session.

Available sections: Decisions Made, Key Learnings, Solutions & Fixes, Files Modified, Setup & Config, Pending Tasks, Errors & Workarounds.

---

## Step 3: Extract and Create Tasks

For each pending task identified, use the **`things3` tool skill** for all task creation operations.

Key points:
- Include session backlink in notes: `Created from session: [[YYYY-MM-DD-HHmm-topic]]`
- Set `when` if timing is clear from context; leave unset for anytime tasks
- Check for duplicates before creating if context suggests one might exist

---

## Step 4: Generate Session Log

**Filename:** `YYYY-MM-DD-HHmm-topic.md`
- Time = session end time, 24-hour format
- Topic = 2-4 words, lowercase, hyphenated, no articles

**Structure:**

```markdown
---
type: session
date: YYYY-MM-DD
time: HH:MM
projects: [Project-Name]
topics: [topic1, topic2, topic3]
tasks-created: X
---

# Session: YYYY-MM-DD HH:MM - topic-description

## Quick Reference
**Topics:** keyword1, keyword2, keyword3
**Projects:** Project-Name
**Outcome:** One-sentence summary

## [Selected sections with content]

---

## Raw Session Log

[Full conversation for searchability]
```

See [session-format.md](references/session-format.md) for complete format spec.

---

## Step 5: Save to Vault

Write the file to `state/sessions/YYYY-MM-DD-HHmm-topic.md`. Confirm it was created and report the filename to the user.

---

## Step 6: Update Daily Note

Check for today's daily note (`Daily Notes/YYYY-MM-DD.md`). If it exists, append to the Session Summaries section:

```markdown
### HH:MM - Session Topic

Brief summary (1-2 sentences).

**Related:** [[YYYY-MM-DD-HHmm-topic]]
**Projects:** [[project-name]]
**Tasks created:** X
**Key outcome:** One sentence
```

If the daily note doesn't exist, skip this step — don't create it automatically.

---

## Step 7: Hygiene Pass

Run all sub-steps. Non-optional.

### 7a: Log Corrections

Review the session for any moment Austin corrected Claude's behavior (wrong tool, wrong format, wrong approach). For each correction:
1. Add a row to `state/operational/corrections.md`
2. Format: `YYYY-MM-DD | what was wrong | correct behavior | → Standing Order?`
3. If the same correction appears 2+ times → promote to standing order in `state/behavioral/` domain files, mark `✅` in corrections table

### 7b: Update Last Updated

For every project or system file modified this session, verify the `Last Updated` line reflects today's date. Update if stale.

### 7c: Future Dates → Things3

Scan for any named future dates or deadlines mentioned this session. For each, confirm a Things3 task exists. If not, create one (via the things3 tool skill). Skip if a task was already created during the session.

### 7d: Flag New Patterns

If a new behavioral pattern was established this session (new workflow, repeated rule, stated preference):
1. If not in `state/behavioral/` domain files, add it
2. If it's a preference/style pattern, add to `state/behavioral/austin-preferences.md`
3. If skill-specific, update that skill's SKILL.md

### 7f: Detect Automation Candidates

Scan the session for any recurring manual tasks, integration gaps, or workflow inefficiencies that could be automated. Look for:
- Steps Austin did manually that a script, cron, or n8n workflow could handle
- Repeated actions across multiple sessions (same lookup, same file edit, same copy-paste)
- Times Austin said "I always do X" or "every time I have to Y"
- Gaps between tools that require manual bridging (e.g. email → Things3, calendar → project file)

For each candidate found, silently append a row to the appropriate table in `~/.claude/projects/-Users-Austin-Library-Mobile-Documents-iCloud-md-obsidian-Documents-VaultyBoi/memory/automation-ideas.md`:

```
| [idea name] | [one-line context from this session] | idea |
```

Add to whichever category table fits best (Email & Communication, Daily Operations, GIS / School Systems, Reporting & Brag Book). If none fit, add a new category section.

**Do not announce this to Austin.** Log silently and continue. If nothing qualifies, skip entirely.

---

### 7e: Update Current State in CLAUDE.md

Update the "Current State" section in the vault root `CLAUDE.md` so the next session loads with accurate context.

**Steps:**
1. Read `Projects/*.md` (frontmatter only, `limit: 5`) to get current status for each project
2. Build the updated block:
   ```markdown
   # Current State
   _Last updated: YYYY-MM-DD by /compress_

   **Active focus:** [what this session worked on]

   **Active projects:**
   - **Project Name** — [status: one-line summary]

   **Pinned/deferred:**
   - [anything deferred or carried forward]

   **Last session:** YYYY-MM-DD — [session topic slug]
   ```
3. Use Edit tool to replace the existing Current State section
4. Rules: omit complete/archived projects; one line per project; reflect actual parking lot

---

## Error Handling

**Things3 unavailable:** Queue tasks to `heart-queue.md` via the things3 tool skill fallback. Tell the user how many were queued.

**File write fails:** Report error, suggest checking permissions, offer to retry.

**Daily note update fails:** Warn but continue — daily note is not critical path.
