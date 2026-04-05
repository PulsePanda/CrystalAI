---
name: compress
description: "End-of-session wrap-up. Trigger when the user is DONE WORKING and wants to save the session: 'compress', 'compress this session', 'save session', 'end session', 'wrap up', 'I'm done', 'that's it for today', 'log this session', 'save and quit', 'goodnight', 'signing off', 'let's call it'. Saves a searchable session log, extracts pending tasks, updates the daily note, and runs a hygiene pass. Do NOT trigger for: mid-session documentation updates (use docs), or weekly review (use weekly). This is specifically for closing out a single working session."
version: 2.0.0
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Compress Session to Memory

Save the current session as a searchable log, extract tasks, update the daily note, and run hygiene.

## Steps

1. Analyze conversation
2. Extract and route tasks
3. Generate session log
4. Save to state
5. Update daily note
6. Hygiene pass
7. Update documentation

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

---

## Step 2: Select Sections to Preserve

Include ALL sections that have content — no interactive checklist. Only omit a section if it genuinely has nothing from this session.

Available sections: Decisions Made, Key Learnings, Solutions & Fixes, Files Modified, Setup & Config, Pending Tasks, Errors & Workarounds.

---

## Step 3: Extract and Route Tasks

For each pending task identified, determine whether it belongs in a task manager or in the project file.

### Task Manager vs. Project File

**Task manager** is for tasks that are:
- **Independent** — standalone actions not tied to a specific project's internal checklist
- **Time-sensitive** — has a deadline, a follow-up date, or needs to happen by a specific time
- **Cross-project** — spans multiple projects or doesn't belong to any project
- **External dependencies** — waiting on someone, needs a reminder to follow up

**Project file** is for tasks that are:
- **Project-bound** — sub-tasks or milestones within an active project
- **Not time-sensitive** — will happen when the project is worked on next
- **Not independent** — only make sense in the context of the project
- **Already tracked** — the project file's checklist or sections already capture them

**Rule of thumb:** If the task only matters when you're actively working on that project, it stays in the project file. If it needs to surface independently (e.g., in a daily review, on a specific date, or as a standalone reminder), it goes to the task manager.

### Creating Tasks

If the user has a task manager configured (check `${CONFIG_PATH}` for `task_manager` settings — e.g., Things3, Todoist, or a custom integration):
- Use the configured task manager skill/integration
- Include session backlink in notes: `Created from session: [[YYYY-MM-DD-HHmm-topic]]`
- Set timing if clear from context; leave unset for anytime tasks
- Check for duplicates before creating

If no task manager is configured:
- List pending tasks in the session log under "Pending Tasks"
- Note them in the daily note update
- The session log becomes the task tracking record

### Project-Bound Tasks

For tasks that belong in a project file, ensure they are captured in the project's existing checklist or pending sections. Note the count in the session log as "project-bound tasks" separately from task manager tasks.

See [task-extraction.md](references/task-extraction.md) for patterns on identifying tasks in conversation.

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

## Step 5: Save to State

Write the file to `${STATE_PATH}/sessions/YYYY-MM-DD-HHmm-topic.md`. Confirm it was created and report the filename to the user.

---

## Step 5b: Archive Session Transcript

Check if a pre-compact backup exists for the current session in `${STATE_PATH}/sessions/pre-compact-backups/`.

- **If a backup exists** (session hit context limit and triggered PreCompact): note the path in the session log under Quick Reference: `Full transcript archived at: [path]`
- **If no backup exists** (session did not trigger PreCompact): this is best-effort. The current session transcript path may not be available to skills. If the transcript cannot be located, note in the session log: "No transcript backup found — session did not trigger PreCompact" and move on. This is not a blocking step.

All transcript archives (from PreCompact and from /compress) should land in the same directory: `${STATE_PATH}/sessions/pre-compact-backups/`.

---

## Step 6: Update Daily Note

If VAULT_PATH is set (check `crystal.local.yaml` — it is always set), proceed with this step.

Check for today's daily note at `${VAULT_PATH}/Daily Notes/YYYY-MM-DD.md`.

If the daily note does NOT exist, create it first:
1. Check if `${VAULT_PATH}/_Templates/daily-note.md` exists.
2. If the template exists: copy it, substituting `{{date}}` → today's date (YYYY-MM-DD) and `{{day}}` → day name from `date '+%A'`.
3. If the template does not exist: create a minimal note:
   ```markdown
   # YYYY-MM-DD, Day

   ## Session Summaries
   ```

Then append to the Session Summaries section:

```markdown
### HH:MM - Session Topic

Brief summary (1-2 sentences).

**Related:** [[YYYY-MM-DD-HHmm-topic]]
**Projects:** [[project-name]]
**Tasks created:** X
**Key outcome:** One sentence
```

---

## Step 7: Hygiene Pass

Run all sub-steps. Non-optional.

### 7a: Log Corrections

Review the session for any moment the user corrected the assistant's behavior (wrong tool, wrong format, wrong approach). For each correction:
1. Add a row to `${STATE_PATH}/operational/corrections.md`
2. Format: `YYYY-MM-DD | what was wrong | correct behavior | → Standing Order?`
3. If the same correction appears 2+ times → promote to standing order in behavioral config files, mark as done in corrections table

### 7b: Update Last Updated

For every project or system file modified this session, verify the `Last Updated` line reflects today's date. Update if stale.

### 7c: Future Dates → Task Manager

Scan for any named future dates or deadlines mentioned this session. If a task manager is configured, confirm a task exists for each. If not configured, note them in the session log.

### 7d: Flag New Patterns

If a new behavioral pattern was established this session (new workflow, repeated rule, stated preference):
1. If not already in behavioral config files, add it
2. If it's a preference/style pattern, add to user preferences
3. If skill-specific, update that skill's SKILL.md

### 7e: Detect Automation Candidates

Scan the session for recurring manual tasks, integration gaps, or workflow inefficiencies that could be automated. Look for:
- Steps the user did manually that a script or workflow could handle
- Repeated actions across multiple sessions
- Times the user said "I always do X" or "every time I have to Y"
- Gaps between tools that require manual bridging

For each candidate found, silently log it to an automation ideas file (if one exists in the project memory). Do not announce this to the user.

---

## Error Handling

**Task manager unavailable:** List tasks in session log and daily note. Tell the user how many were identified but not created.

**File write fails:** Report error, suggest checking permissions, offer to retry.

**Daily note update fails:** Warn but continue — daily note is not critical path.

---

## Step 8: Update Documentation

After all other steps are complete, invoke the **`docs` skill** (`/docs`) to scan the session and update any relevant permanent documentation — project files, skill files, memory, and behavioral rules.

Runs by default. If the user has set a preference to confirm before running sub-skills, ask first.
