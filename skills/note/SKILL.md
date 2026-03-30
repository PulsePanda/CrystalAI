---
name: note
description: This skill should be used when the user asks to "create a note", "new note", "start a note", or simply types "/note". Creates a timestamped note in +Inbox/ and opens it in Obsidian for immediate editing.
version: 1.0.0
disable-model-invocation: true
allowed-tools: Write, Bash
---

# Create Quick Note

Creates a timestamped file in `${VAULT_PATH}/+Inbox/` and opens it in Obsidian. User types directly in Obsidian; `/process-inbox` handles formatting later.

## Prerequisites

This skill works best with Obsidian but adapts to any notes setup. Check the user's config for `notes_app`. If not Obsidian, create files as plain markdown and skip Obsidian-specific steps (URI opening, wikilinks). If no notes app is configured, create files in `${STATE_PATH}/notes/` as plain markdown.

---

## Step 1: Generate Filename

Format: `YYYY-MM-DD-HHmm.md`

**Do NOT use Bash to get the time** — the assistant knows today's date from context. Construct the filename directly. Using Bash here causes sandbox errors.

If a file with that name already exists, append `-2` (e.g. `2026-01-30-1430-2.md`).

---

## Step 2: Create File

Write to: `${VAULT_PATH}/+Inbox/FILENAME.md`

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
open "obsidian://open?vault={vault_name}&file=%2BInbox%2FFILENAME.md"
```

URL encoding: `+` → `%2B`, `/` → `%2F` (or leave as `/`).

The `vault_name` should be read from `${CONFIG_PATH}` or inferred from the vault directory name.

If Obsidian isn't running, this opens it. If the URI fails, the file is still created — report the path so user can open manually.

**Note:** This step is macOS/Obsidian-specific. On other platforms or with other editors, adapt the open command accordingly.

---

## Step 4: Confirm

```
Created: +Inbox/2026-01-30-1430.md — open in Obsidian.
```

One line. Done.
