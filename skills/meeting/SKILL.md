---
name: meeting
description: "Trigger when the user wants to CREATE A MEETING NOTE for note-taking — not schedule a meeting (that's calendar-booking). Includes: '/meeting', 'start a meeting note', 'meeting with [person]', 'meeting note for...', 'I have a meeting with...', 'about to hop on a call with...', 'taking notes for a meeting', 'log a meeting with [person]', 'meeting about [topic]'. Creates a pre-filled note in +Inbox/ with people and topic extracted, then opens in Obsidian. Do NOT trigger for: scheduling or booking meetings ('set up a call', 'find a time' — use calendar-booking), or creating a generic note without meeting context (use note)."
version: 1.0.0
disable-model-invocation: true
allowed-tools: Write, Bash, Read, Grep, Glob
---

# Create Meeting Note

Like `/note` but pre-filled with meeting context. Extracts people and topic from the command, searches for related previous notes, creates a pre-filled capture, and opens in Obsidian.

## Prerequisites

This skill works best with Obsidian but adapts to any notes setup. Check the user's config for `notes_app`. If not Obsidian, create files as plain markdown and skip Obsidian-specific steps (URI opening, wikilinks). If no notes app is configured, create files in `${STATE_PATH}/notes/` as plain markdown.

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
Glob: ${VAULT_PATH}/Areas/Work/Meeting notes/*.md
```

Scan filenames for matches. Read the 1-2 most relevant files and extract pending action items or key decisions. **Don't read more than 2-3 files** — quick context only, not research.

Skip this step entirely if no matches found.

---

## Step 4: Create Pre-filled Note

Write to `${VAULT_PATH}/+Inbox/FILENAME.md`:

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
people: [Alex]
topic: Q2 roadmap review
---

meeting with Alex about Q2 roadmap review

previous meeting notes: [[2026-01-21 Sync Alex Q2 Planning]]

focus reminder: agreed to finalize feature priorities before next sync; waiting on budget numbers

notes:
-
```

---

## Step 5: Update People Files

After creating the meeting note, check attendees against `Areas/People/`:

For each attendee mentioned in the meeting note (from the `people:` frontmatter field):

1. **Search for existing person file:** Glob `${VAULT_PATH}/Areas/People/*.md` for a matching file (by name, case-insensitive). Also check `aliases` in frontmatter of existing person files.
2. **If file exists:**
   - Update `last-contact` in frontmatter to today's date
   - Add an entry to the **Meeting History** section: `- YYYY-MM-DD — {meeting topic} — [[meeting note filename]]`
3. **If no file exists:**
   - Create a stub person file at `${VAULT_PATH}/Areas/People/{Name}.md` using the person template (`${VAULT_PATH}/_Templates/person.md`)
   - Fill in what's known from the meeting context: name (required), role if mentioned, organization if known
   - Add the meeting to Meeting History: `- YYYY-MM-DD — {meeting topic} — [[meeting note filename]]`
   - Set `last-contact` to today's date

After updating/creating person files, add wikilinks to each person in the meeting note body. Insert a `people:` line after the topic line if not already present, formatted as: `people: [[Person1]], [[Person2]]`

---

## Step 6: Open in Obsidian

Requires `dangerouslyDisableSandbox: true` for this one call only.

```bash
open "obsidian://open?vault={vault_name}&file=%2BInbox%2FFILENAME.md"
```

The `vault_name` should be read from `${CONFIG_PATH}` or inferred from the vault directory name.

**Note:** This step is macOS/Obsidian-specific. On other platforms or with other editors, adapt the open command accordingly.

---

## Step 7: Confirm

```
Created: +Inbox/2026-02-04-0915.md
Meeting: [People] about [Topic]
Related: [[Previous Note]] (if found)
People: Updated [[Person1]], created [[Person2]] (stub)
Opened in Obsidian.
```

---

## Notes

- `meeting: true` frontmatter tells `/process-inbox` to apply the Meeting Notes Template and move to the meeting notes directory
- Same-minute conflict: append `-2` to filename
- `/meeting` with no arguments: create a blank note with `meeting: true` frontmatter, user fills in details
