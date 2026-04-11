---
name: note
description: "Create a quick capture note in the inbox. Trigger on: '/note', 'create a note', 'new note', 'start a note', 'jot this down', 'quick note', 'capture this'. Creates a timestamped file in +Inbox/ and opens it in your configured editor. Do NOT trigger for: meeting notes (use meeting), writing content to send to someone (use write), or processing existing inbox notes (use process-inbox)."
version: 1.1.0
disable-model-invocation: true
allowed-tools: Write, Bash
---

# Create Quick Note

Creates a timestamped file in `${VAULT_PATH}/+Inbox/` and opens it in the user's configured editor. User types directly in the editor; `/process-inbox` handles formatting later.

## Prerequisites

Read `notes_editor` from `crystal.local.yaml` to determine how to open the file. Valid values: `obsidian`, `vscode`, `system`. If the key is absent, treat it as `system`.

Detect the operating system by running `uname -s` (returns `Darwin` for macOS, `Linux` for Linux, `MINGW*` or `CYGWIN*` for Windows/Git Bash). Use the result to pick the correct open command in Step 3.

If `notes_editor` is `obsidian`, also read `vault_name` from `crystal.local.yaml` or infer it from the vault directory name. If no vault is configured, fall back to `system` behavior.

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

## Step 3: Open in Editor

Run `uname -s` to detect the OS, then open the file using the method that matches `notes_editor` and the detected OS.

### notes_editor = "obsidian"

URL-encode the path: `+` → `%2B`, `/` → `%2F` (or leave `/` as-is after the vault name).

- **macOS** — requires `dangerouslyDisableSandbox: true` for this call only (`open obsidian://` needs macOS Launch Services, which the sandbox blocks):
  ```bash
  open "obsidian://open?vault={vault_name}&file=%2BInbox%2FFILENAME.md"
  ```
- **Windows (Git Bash)**:
  ```bash
  cmd //c start "" "obsidian://open?vault={vault_name}&file=%2BInbox%2FFILENAME.md"
  ```

If the URI fails (Obsidian not installed, URI handler not registered), fall through to `system` behavior and report the fallback to the user.

### notes_editor = "vscode"

All platforms — `code` CLI must be in PATH:

```bash
code "{full_file_path}"
```

### notes_editor = "system" (or not set / fallback)

- **macOS**:
  ```bash
  open "{full_file_path}"
  ```
- **Windows (Git Bash)** — convert the Unix path to a Windows path first if `cygpath` or `wslpath` is available, otherwise use the raw path:
  ```bash
  cmd //c start "" "$(cygpath -w '{full_file_path}' 2>/dev/null || echo '{full_file_path}')"
  ```
- **Linux**:
  ```bash
  xdg-open "{full_file_path}"
  ```

If the open command fails, the file is still created — report the full path so the user can open it manually.

---

## Step 4: Confirm

```
Created: +Inbox/2026-01-30-1430.md — note created and opened.
```

One line. Done.
