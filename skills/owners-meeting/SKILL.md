---
name: crystal:owners-meeting
description: This skill should be used when the user asks to "prep owners meeting", "owners meeting prep", or types "/owners-meeting". Creates a Jesse brief PDF (via /jesse-brief) AND an internal meeting prep document with private talking points and notes area. Used before meetings with Jesse to sync on GIS + SJA status.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Owners Meeting Prep

Prepare for the owners meeting with Jesse. Generates a shareable Jesse Brief PDF and an internal prep document with talking points and a notes area for during the meeting.

## How It Works

1. **Run /jesse-brief logic** — Pull projects, brag book, sessions; generate PDF
2. **Create internal prep doc** — Same content + private notes section + blank meeting notes area
3. **Save to +Inbox/** — So /process-inbox can handle it after the meeting and stamp the benchmark

---

## Step-by-Step Workflow

### Step 1: Generate the Jesse Brief

Invoke the `jesse-brief` skill. It handles the full pipeline — lookback window, projects, brag book, sessions, PDF generation, and opening the file.

### Step 2: Create Internal Meeting Prep Doc

Create a meeting prep file in `+Inbox/` using today's date:

**Filename:** `+Inbox/YYYY-MM-DD [VRT] [Jesse] Owners Meeting GIS SJA.md`

**Structure:**

```markdown
---
type: capture
date: YYYY-MM-DD
time: ""
people: [Jesse]
tags: [meeting, owners-meeting, gis, sja]
processed: false
---

# Owners Meeting — YYYY-MM-DD

**Format:** Video call
**Attendees:** Austin VanAlstyne, Jesse Schonfeld

---

## Brief Summary
[Paste the plain-text version of the brief here — same four sections]

---

## Talking Points (Private)

Things to raise, questions to ask, or context Jesse might need:

-
-
-

---

## Jesse's Updates

_Capture wins and updates Jesse shares during the meeting — add to brag book after:_

**GIS:**
-

**SJA:**
-

---

## Notes

_Live notes during the meeting:_



---

## Action Items

_Extracted after meeting — created in Things3 by /process-inbox:_

-
```

### Step 3: Open Prep Doc in VS Code

```bash
open -a "Visual Studio Code" "/Users/Austin/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi/+Inbox/YYYY-MM-DD [VRT] [Jesse] Owners Meeting GIS SJA.md"
```

### Step 4: Report to User

```
Owners meeting prep ready.

PDF brief:  ~/Downloads/jesse-brief-YYYY-MM-DD.pdf  ← share with Jesse
Prep doc:   +Inbox/YYYY-MM-DD [VRT] [Jesse] Owners Meeting GIS SJA.md  ← your notes

After the meeting:
  1. Fill in Notes + Jesse's Updates sections
  2. Run /process-inbox to process the meeting note
  3. /process-inbox will stamp the benchmark date for next time
```

---

## After the Meeting

When Austin runs `/process-inbox` on the completed meeting note, the process-inbox skill will:
1. Format it as a proper meeting note
2. Extract action items to Things3
3. **Stamp the meeting date** to `state/operational/owners-meeting.md` as the new benchmark
4. Any wins Jesse shared in "Jesse's Updates" → add to brag book

This makes the meeting the lookback point for the next brief.

---

## Benchmark File Location

`state/operational/owners-meeting.md`

Managed automatically by `/process-inbox` when it processes an owners meeting note.
