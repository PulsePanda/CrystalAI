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
- **Folder:** `project-name/` — a directory with `_project.md` tracker plus a `_meta/` directory containing `reference/`, `deliverables/`, and `notes/` subdirectories for accumulated material. Some older projects may have `reference/`, `deliverables/`, and `notes/` at the project root instead of under `_meta/` — handle both layouts.

This skill handles both formats and is the bridge between ad-hoc work and persistent project context.

---

## Configuration

This skill reads from `~/.claude/skill-configs/project-load.yaml` if present. Available options:
- `task_manager`: Integration to use for task pull (e.g., "todoist"). Default: none.
- `todoist_task_pull`: Whether to search Todoist for matching project tasks (default: false)
- `post_steps`: Additional skills to run after project load completes

---

## Arguments

- `/project-load` — auto-detect local project, or list all projects if not in one
- `/project-load [name]` — load all context for a specific project
- `/project-load [name] file [subdir]` — file content into a project folder
  - `subdir` is one of: `reference`, `deliverables`, `notes`
  - If subdir is omitted, ask which one

---

## Step 0: Check Current Working Directory

**Always run this step first, before anything else.**

1. Check if `_project.md` exists in the current working directory (CWD).
2. If it **does exist** → this is a local project. Skip Step 1/Step 2 entirely and go straight to **Step 3: Load Mode** using the CWD as the project folder. The project name is derived from the CWD folder name.
3. If it **does not exist** → fall through to Step 1 (named project) or Step 2 (list mode) as before.

This supports the workflow of `cd`-ing into a project directory, launching Claude, and running `/project-load` to immediately load local context without needing to specify a name.

---

## Step 1: Resolve the Project

Given a project name (or partial match):

1. Run **two Glob calls in parallel:**
   - `Projects/*name*.md` — finds single-file projects
   - `Projects/*name*/_project.md` — finds folder projects (by their tracker file)
2. **Important:** Never use `Projects/*/` to find directories — Glob doesn't reliably match directories. Always glob for `_project.md` inside project folders instead.
3. If **exact match** on folder name (from `_project.md` path) → use folder format
4. If **exact match** on file name → use single-file format
5. If **multiple matches** → present options and ask which one
6. If **no match** → tell the user, suggest creating one with `/project`

---

## Step 2: List Mode (no argument, no local project)

If invoked with no project name **and Step 0 did not find a local `_project.md`**, discover all projects with **two parallel Glob calls:**
- `Projects/*.md` — single-file projects (exclude `_template*.md`)
- `Projects/*/_project.md` — folder projects (derive folder name from path; exclude `Archive/`)

Then **read the first ~30 lines of each project file** (the `.md` or `_project.md`) to extract:
- **Status:** from frontmatter `status:` field
- **Where we're at:** a 1-sentence summary of current state, pulled from the project's content (look for "Current State", "Status", "Done/In Progress/Next", or the most recent updates section — summarize what's actually happening, not just the frontmatter status)

Present a table:

| Project | Status | Where We're At |
|---------|--------|----------------|

- Skip template files (`_template*.md`) and the `Archive/` directory
- Sort by status: active → planned → on-hold → other
- The "Where We're At" column is the key value — give a concise, plain-language snapshot of progress

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
5. **Write the file** — check if `_meta/` exists in the project. If yes, write to `~/Documents/Projects/[project-name]/_meta/[subdir]/[filename]`. If no `_meta/` (legacy layout), write to `~/Documents/Projects/[project-name]/[subdir]/[filename]`.
6. **Create subdirectory** if it doesn't exist yet
7. **Confirm:** "Filed `filename` into `project-name/_meta/subdir/`." (or `project-name/subdir/` for legacy)

---

## Step 5: Convert Single-File to Folder

When a user wants to file something into a single-file project, or explicitly asks to convert:

1. Read the existing `project-name.md`
2. Create `~/Documents/Projects/project-name/` directory
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
