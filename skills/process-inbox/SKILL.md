---
name: crystal:process-inbox
description: This skill should be used when the user asks to "process my inbox", "organize inbox notes", "clean up inbox", "format inbox captures", or mentions wanting to organize their quick captures. Helps transform rough inbox captures into structured notes and Things3 tasks.
version: 2.0.0
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Process Inbox Captures

Transform rough notes from +Inbox/ into structured, properly categorized content with action items in Things3.

## Steps

1. List inbox files + check Siri captures
2. Analyze and categorize each item
3. Present processing plan — wait for approval
4. Transform content (meeting notes, project files, etc.)
5. Create Things3 tasks
6. Move files, clean up Siri captures
7. Report results

---

## Step 1: List Inbox Files + Siri Captures

**Inbox files:** Use the Glob tool — `+Inbox/*.md`

**Siri captures:** Check today's daily note (`Daily Notes/YYYY-MM-DD.md`) for content below the `## Siri Capture` heading. Each block of text is a separate capture.

If both are empty: report "Inbox is empty, nothing to process" and exit.

---

## Step 2: Categorize Each Item

Five types — see [categorization-rules.md](references/categorization-rules.md) for full decision tree and pattern matching:

| Type | Destination |
|------|-------------|
| Meeting capture | `Areas/Work/Meeting notes/` (formatted) |
| Simple task | Things3 only, delete file |
| Personal note | `Areas/Personal/` or Things3 |
| Project idea | `Projects/` from template |
| Work note | `Areas/Work/` |

Also watch for **win/brag book entries** — cost savings, problems fixed, improvements, anything delivering value to GIS or SJA. Append to `Areas/Work/Brag Book/GIS.md` or `SJA.md`.

### Content Idea Detection

While categorizing, also check if any capture contains a content-worthy idea — something that could become a blog post or social media content for the Umbrella Content Engine. Signals:

- A problem Austin solved that other school IT pros would find useful
- A cost savings, efficiency improvement, or process Austin built
- A story or lesson learned from troubleshooting
- An opinion or insight about school IT, managed services, or automation
- Anything Austin explicitly marked as "content idea", "could be a post", etc.

If detected, append a row to the appropriate backlog file(s) during Step 6:
- `_System/Content/umbrella/ideas.md` — company capabilities, service delivery, general school IT
- `_System/Content/austin/ideas.md` — personal stories, building in public, AI/automation

**Row format:** `| YYYY-MM-DD | Idea title | [inbox-scan] | new | 2-3 sentence description |`

Include the content idea detection in the Step 3 plan presentation so Austin can confirm or skip it. This is additive — it doesn't change the primary categorization of the capture.

---

## Step 3: Present Plan + Get Approval

Show the full plan before doing anything:

```
Found 2 items:

1. "Meeting with Kim.md"
   → Format as meeting note
   → Extract 2 action items to Things3
   → Move to: Areas/Work/Meeting notes/2026-03-15 [Meeting] [Kim] Topic.md

2. "camera-savings" (Siri capture)
   → Win: GIS cost savings
   → Append to: Areas/Work/Brag Book/GIS.md
   → Clear from daily note

Proceed?
```

Wait for approval before executing.

---

## Step 4: Transform Meeting Captures

Read `_Templates/Meeting Notes Template v2.md`. Extract from the rough capture:
- Participants, meeting type, topic, date
- Discussion points, decisions, action items

See [meeting-note-format.md](references/meeting-note-format.md) for template structure, filename format, and content extraction patterns.

**Filename:** `YYYY-MM-DD [Type] [People] Topic.md`

### Step 4b: Owners Meeting Detection

After processing any meeting note, check if it's an owners meeting with Jesse:
- Filename contains "Owners Meeting", OR
- Frontmatter `people` includes "Jesse", OR
- Content references "owners meeting" + "jesse" + "gis"/"sja"

**If detected:**
1. Read `state/operational/owners-meeting.md`
2. Update `Last Meeting` section with date + meeting note link
3. Add row to History table
4. Scan for Jesse's wins → auto-add to brag book with `Source: owners meeting [DATE] (Jesse)`

---

## Step 5: Create Things3 Tasks

Use the **`things3` tool skill** for all task creation. Always include an Obsidian backlink in task notes:

```
[Source note](obsidian://open?vault=VaultyBoi&file=PATH_URL_ENCODED)

Context: [1-3 sentences]
```

URL encoding: spaces → `%20`, `/` → `%2F`, `[` → `%5B`, `]` → `%5D`

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
✓ "Meeting with Kim.md" → Meeting note created, 2 tasks in Things3
✓ "camera-savings" (Siri) → Added to GIS brag book, cleared from daily note

Inbox is empty.
```

---

## Error Handling

- **Can't read file:** Skip it, report, continue with others
- **Can't write destination:** Keep in inbox, report error
- **Things3 unavailable:** Queue to heart-queue.md via `things3` skill
- **Template not found:** Ask user for key info, create simple note
- **User cancels mid-run:** Stop, report what was completed, leave remainder in inbox
