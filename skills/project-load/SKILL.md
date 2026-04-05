---
name: project-load
description: Load, list, and file into existing Obsidian projects. ALWAYS use this skill when the user references an existing project by name — whether to load its context, check its status, file something into it, or list all projects. This includes direct commands ("/project-load X", "load project X", "show me project X") AND natural working phrases ("let's work on the X project", "pull up X", "switch to X project", "back to the X project", "where are we on X", "X project — [any task]"). Also trigger when FILING content into a project ("put this in project X", "file this under X", "save this to the X project", "add this to X reference/deliverables/notes"). Also trigger for listing projects ("what projects do we have", "show me all active projects", "project status overview"). If the user mentions a project name at the start of a work block, this skill loads its context. Do NOT trigger for CREATING new projects (that's the project skill) — only for working with existing ones.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Project Load & File

Load all context for a project into the current session, or file documents into a project's folder structure.

Projects in the vault come in two formats:
- **Single-file:** `project-name.md` — a standalone tracking doc
- **Folder:** `project-name/` — a directory with `_project.md` tracker plus `reference/`, `deliverables/`, and `notes/` subdirectories for accumulated material

This skill handles both formats and is the bridge between ad-hoc work and persistent project context.

---

## Configuration

This skill reads from `~/.claude/skill-configs/project-load.yaml` if present. Available options:
- `task_manager`: Integration to use for task pull (e.g., "todoist"). Default: none.
- `todoist_task_pull`: Whether to search Todoist for matching project tasks (default: false)
- `post_steps`: Additional skills to run after project load completes

---

## Arguments

- `/project-load` — list all projects with their format (file vs folder)
- `/project-load [name]` — load all context for a specific project
- `/project-load [name] file [subdir]` — file content into a project folder
  - `subdir` is one of: `reference`, `deliverables`, `notes`
  - If subdir is omitted, ask which one

---

## Step 1: Resolve the Project

Given a project name (or partial match):

1. Glob `${VAULT_PATH}/Projects/` for both `*name*.md` files and `*name*/` directories
2. If **exact match** on folder name → use folder format
3. If **exact match** on file name → use single-file format
4. If **multiple matches** → present options and ask which one
5. If **no match** → tell the user, suggest creating one with `/project`

---

## Step 2: List Mode (no argument)

If invoked with no project name, scan `${VAULT_PATH}/Projects/` and present a table:

| Project | Format | Status |
|---------|--------|--------|

- Skip template files and the `Archive/` directory
- **Format:** "file" or "folder"
- **Status:** read from frontmatter `status:` field (from the `.md` file or `_project.md`)
- Sort by status: active → planned → on-hold → other

---

## Step 3: Load Mode

### Single-file project

Read the project `.md` file and present a summary:
- Project name, status, last updated
- Current state (done / in progress / next)
- Waiting on items
- "This is a single-file project. If you need to accumulate reference material, convert it to a folder project with `/project [name] --folder`."

### Folder project

1. Read `_project.md` (the tracker)
2. Glob all files in the project directory recursively
3. Read every file in the project folder into context
4. Present a summary:

```
Project: [Name]
Status: [status]
Last Updated: [date]

Loaded files:
  _project.md (tracker)
  reference/
    - research-doc.md
    - competitive-intel.md
  deliverables/
    - proposal-draft.md
  notes/
    - 2026-03-28-intro-call.md

[Current State section from _project.md]
```

If there are more than 15 files, read only `_project.md` and list the others — then ask which ones to load. Large projects shouldn't blow up context.

---

## Step 3b: Todoist Task Pull (conditional)

If `task_manager: todoist` is set in config, search Todoist for a matching project after presenting the Obsidian summary. Use `mcp__todoist__find-projects` with the project name, pull tasks grouped by section, and append to the summary.

---

## Step 4: File Mode

When the user wants to file content into a project folder:

1. **Resolve the project** (must be folder format — if single-file, offer to convert it)
2. **Determine the subdirectory:**
   - `reference` — research, specs, background, external docs
   - `deliverables` — outputs, proposals, reports, bids, quotes
   - `notes` — meeting notes, call notes, working notes, observations
   - If unclear, ask: "Where should this go — reference, deliverables, or notes?"
3. **Determine the content:**
   - If a file path was provided, copy/move it
   - If the user says "put that in the project" (referring to recent output), identify the most recent substantive output in the conversation and write it
   - If unclear, ask what to file
4. **Determine the filename:**
   - If the content is a meeting note: `YYYY-MM-DD-topic.md`
   - If it's research/reference: `descriptive-name.md` (lowercase, hyphenated)
   - If it's a deliverable: `descriptive-name.md`
   - Ask the user to confirm the filename before writing
5. **Write the file** to `${VAULT_PATH}/Projects/[project-name]/[subdir]/[filename]`
6. **Create subdirectory** if it doesn't exist yet
7. **Confirm:** "Filed `filename` into `project-name/subdir/`."

---

## Step 5: Convert Single-File to Folder

When a user wants to file something into a single-file project, or explicitly asks to convert:

1. Read the existing `project-name.md`
2. Create `${VAULT_PATH}/Projects/project-name/` directory
3. Create subdirectories: `reference/`, `deliverables/`, `notes/`
4. Move the original `.md` content into `project-name/_project.md`
5. Delete the original `project-name.md`
6. Confirm: "Converted `project-name` to folder format. You can now file reference material, deliverables, and notes into it."

---

## Error Handling

- **Project not found:** "No project matching '[name]' found. Create one with `/project [name]`?"
- **Ambiguous match:** Present all matches and ask which one
- **File already exists:** Ask whether to overwrite or use a different name
- **Empty project folder:** Normal — just note "No files yet in reference/, deliverables/, or notes/."
