---
name: process-inbox
description: "Process and organize raw captures from the Obsidian +Inbox/ folder. Trigger on: '/process-inbox', 'process my inbox', 'organize inbox notes', 'clean up inbox', 'format inbox captures', 'what's in my inbox', 'triage inbox', 'sort the inbox', 'anything in the inbox to process'. Transforms rough captures into structured notes, routes meeting notes to the right folder, and creates tasks. Do NOT trigger for: email inbox processing, or creating new inbox captures (use note)."
version: 2.0.0
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Process Inbox Captures

Transform rough notes from the inbox into structured, properly categorized content with action items.

## Configuration

This skill reads from `~/.claude/skill-configs/process-inbox.yaml` if present. Available options:
- `post_steps`: Additional skills to run after inbox processing (e.g., brag book detection, content idea scanning)

If no config file exists, the skill processes inbox items without additional post-processing.

---

## Steps

1. List inbox files + check Siri captures (if configured)
2. Analyze and categorize each item
3. Present processing plan — wait for approval
4. Transform content (meeting notes, project files, etc.)
5. Create tasks
6. Move files, clean up Siri captures (if applicable)
7. Report results

---

## Step 1: List Inbox Files + Siri Captures

**Inbox files:** Use the Glob tool — `${VAULT_PATH}/+Inbox/*.md`

**Siri captures:** If the user has a Siri capture integration configured, check today's daily note (`${VAULT_PATH}/Daily Notes/YYYY-MM-DD.md`) for content below the `## Siri Capture` heading. Each block of text is a separate capture. Otherwise, skip this source.

If both are empty: report "Inbox is empty, nothing to process" and exit.

---

## Step 2: Categorize Each Item

**Empty notes** (< 10 chars of non-whitespace, whitespace-only, or frontmatter with no body) are auto-deleted without prompting. List them in the plan as "empty, will delete" for visibility.

Five types — see [categorization-rules.md](references/categorization-rules.md) for full decision tree and pattern matching:

| Type | Destination |
|------|-------------|
| Meeting capture | `${VAULT_PATH}/Areas/Work/Meeting notes/` (formatted) |
| Simple task | Task manager only, delete file |
| Personal note | `${VAULT_PATH}/Areas/Personal/` or task manager |
| Project idea | `${VAULT_PATH}/Projects/` from template |
| Work note | `${VAULT_PATH}/Areas/Work/` |

---

## Step 3: Present Plan + Get Approval

Show the full plan before doing anything:

```
Found 2 items:

1. "Meeting with Kim.md"
   → Format as meeting note
   → Extract 2 action items to task manager
   → Move to: Areas/Work/Meeting notes/2026-03-15 [Meeting] [Kim] Topic.md

2. "camera-savings" (Siri capture)
   → Work note
   → Move to: Areas/Work/topic.md
   → Clear from daily note

Proceed?
```

Wait for approval before executing.

---

## Step 4: Transform Meeting Captures

Check for a meeting notes template at `${VAULT_PATH}/_Templates/`. Extract from the rough capture:
- Participants, meeting type, topic, date
- Discussion points, decisions, action items

See [meeting-note-format.md](references/meeting-note-format.md) for template structure, filename format, and content extraction patterns.

**Filename:** `YYYY-MM-DD [Type] [People] Topic.md`

---

## Step 4b: Update People Files

When processing any inbox capture that names a person, check for people integration:

1. **Identify named people** in the capture — from `people:` frontmatter, explicit mentions in body text, or sender/recipient context.
2. **For each person identified:**
   - Glob `${VAULT_PATH}/Areas/People/*.md` for a matching file (by name, case-insensitive). Also check `aliases` in frontmatter.
   - **If file exists** and the capture contains person-relevant context (contact info, preferences, decisions, observations about them): update the person file with the new context in the appropriate section.
   - **If no file exists** AND there's enough context (at least name + one other field such as role, organization, email, or a meaningful observation): create a stub person file at `${VAULT_PATH}/Areas/People/{Name}.md` using the person template (`${VAULT_PATH}/_Templates/person.md`). Fill in known fields.
   - **If no file exists** and there's only a name with no additional context: skip — do not create a person file with only a name.
3. **For meeting captures** (items with `meeting: true`): also update `last-contact` and add a Meeting History entry, same as `/meeting` Step 5.
4. Add `[[Person Name]]` wikilinks in the processed note where people are mentioned.

---

## Step 5: Create Tasks

If the user has a task manager configured (check `${CONFIG_PATH}`):
- Use the configured task manager integration for all task creation
- Always include an Obsidian backlink in task notes:

```
[Source note](obsidian://open?vault={vault_name}&file=PATH_URL_ENCODED)

Context: [1-3 sentences]
```

URL encoding: spaces → `%20`, `/` → `%2F`, `[` → `%5B`, `]` → `%5D`

If no task manager is configured:
- List tasks in a "Tasks Identified" section of the processed note
- Note them in the daily note if it exists

---

## Step 6: Move Files + Clean Up

- Delete original inbox files after processing
- For Siri captures: use Edit tool to replace everything below `## Siri Capture` with just the placeholder line:

```
_Appended by Siri Shortcuts (processed by /process-inbox):_
```

---

## Step 7: Report Results

```
Processed 2 items:
- "Meeting with Kim.md" → Meeting note created, 2 tasks identified
- "camera-savings" (Siri) → Work note created, filed to Areas/Work/

Inbox is empty.
```

---

## Post Steps

After Step 7, check `skill-configs/process-inbox.yaml` for `post_steps` and execute each listed skill, passing the list of processed items as context.

---

## Error Handling

- **Can't read file:** Skip it, report, continue with others
- **Can't write destination:** Keep in inbox, report error
- **Task manager unavailable:** List tasks in the processed note instead
- **Template not found:** Ask user for key info, create simple note
- **User cancels mid-run:** Stop, report what was completed, leave remainder in inbox
