---
name: crystal:meeting
description: This skill should be used when the user asks to "start a meeting note", "meeting with...", or types "/meeting". Creates a pre-filled meeting note in +Inbox/ with people and topic extracted from the command arguments, and opens it in Obsidian.
version: 1.0.0
disable-model-invocation: true
allowed-tools: Write, Bash, Read, Grep, Glob
---

# Create Meeting Note

Like `/note` but pre-filled with meeting context. Extracts people and topic from the command, searches for related previous notes, creates a pre-filled capture, and opens in Obsidian.

---

## Step 1: Parse Arguments

Extract from free-form text after `/meeting`:
- **People:** names (after "with", comma-separated, or standalone)
- **Topic:** text after "about", "re:", or a dash/hyphen; infer if no marker
- **Format:** meeting type if mentioned (standup, 1-on-1, demo, etc.)

If arguments are empty or unclear, still create the note — leave blanks for the user to fill in.

---

## Step 2: Generate Filename

Format: `YYYY-MM-DD-HHmm.md` — same as `/note`, goes in `+Inbox/`.

**Do NOT use Bash** — construct the filename from conversation context directly.

---

## Step 3: Search for Related Context

Search for previous notes involving the same people or topic:

```
Glob: Areas/Work/Meeting notes/*.md
```

Scan filenames for matches. Read the 1-2 most relevant files and extract pending action items or key decisions. **Don't read more than 2-3 files** — quick context only, not research.

Skip this step entirely if no matches found.

---

## Step 4: Create Pre-filled Note

Write to `/Users/Austin/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi/+Inbox/FILENAME.md`:

```markdown
---
type: capture
date: YYYY-MM-DD
time: "HH:MM"
processed: false
meeting: true
people: [Person1, Person2]
topic: Topic description
---

meeting with [People] about [Topic]

previous meeting notes: [[Previous Note Title]]

focus reminder: [pending items or key decisions from previous meeting]

notes:
-
```

- Include `previous meeting notes:` only if related notes were found (wikilink format)
- Include `focus reminder:` only if there's useful context; omit entirely otherwise
- Always end with `notes:` — that's where the user starts typing
- Keep pre-fill minimal — a couple of context lines max

**Example output (with context found):**
```markdown
---
type: capture
date: 2026-02-04
time: "09:15"
processed: false
meeting: true
people: [Kyle]
topic: Raptor VisitorID
---

meeting with Kyle about Raptor VisitorID

previous meeting notes: [[2026-01-21 VRT Kyle Raptor Technologies Intro Call]]

focus reminder: evaluating VisitorID for in-person dismissal, also comparing against PikMyKid replacement options

notes:
-
```

---

## Step 5: Open in Obsidian

Requires `dangerouslyDisableSandbox: true` for this one call only.

```bash
open "obsidian://open?vault=VaultyBoi&file=%2BInbox%2FFILENAME.md"
```

---

## Step 6: Confirm

```
Created: +Inbox/2026-02-04-0915.md
Meeting: [People] about [Topic]
Related: [[Previous Note]] (if found)
Opened in Obsidian.
```

---

## Notes

- `meeting: true` frontmatter tells `/process-inbox` to apply the Meeting Notes Template and move to `Areas/Work/Meeting notes/`
- Same-minute conflict: append `-2` to filename
- `/meeting` with no arguments: create a blank note with `meeting: true` frontmatter, user fills in details
