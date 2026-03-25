---
name: crystal:note
description: This skill should be used when the user asks to "create a note", "new note", "start a note", or simply types "/note". Creates a timestamped note in +Inbox/ and opens it in Obsidian for immediate editing.
version: 1.0.0
disable-model-invocation: true
allowed-tools: Write, Bash
---

# Create Quick Note

Creates a timestamped file in `+Inbox/` and opens it in Obsidian. User types directly in Obsidian; `/process-inbox` handles formatting later.

---

## Step 1: Generate Filename

Format: `YYYY-MM-DD-HHmm.md`

**Do NOT use Bash to get the time** — Claude knows today's date from context. Construct the filename directly. Using Bash here causes sandbox errors.

If a file with that name already exists, append `-2` (e.g. `2026-01-30-1430-2.md`).

---

## Step 2: Create File

Write to: `/Users/Austin/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi/+Inbox/FILENAME.md`

```markdown
---
type: capture
date: YYYY-MM-DD
time: "HH:MM"
processed: false
---

```

Body stays empty — user starts typing immediately after the frontmatter.

---

## Step 3: Open in Obsidian

Requires `dangerouslyDisableSandbox: true` for this one call only — `open obsidian://` needs macOS Launch Services, which the sandbox blocks. All other Bash calls stay sandboxed.

```bash
open "obsidian://open?vault=VaultyBoi&file=%2BInbox%2FFILENAME.md"
```

URL encoding: `+` → `%2B`, `/` → `%2F` (or leave as `/`).

If Obsidian isn't running, this opens it. If the URI fails, the file is still created — report the path so user can open manually.

---

## Step 4: Confirm

```
Created: +Inbox/2026-01-30-1430.md — open in Obsidian.
```

One line. Done.
