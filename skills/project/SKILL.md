---
name: project
description: Create new Obsidian project files and folders. ALWAYS use this skill — not just when the user explicitly says "create a project", but any time the intent is to START TRACKING something new. This includes direct requests ("create a project for X", "/project X", "make a project") AND indirect signals ("this should be a project", "let's track this", "set up tracking for X"). Also trigger when the user describes a new initiative with enough complexity to warrant tracking. Do NOT trigger for loading/opening existing projects (that's project-load), updating project content, or archiving — only for CREATING new ones.
version: 2.0.0
allowed-tools: Read, Write, Edit, Bash, Glob
---

# Create New Project

Creates a project file (or folder) in `~/Documents/Projects/` and opens it in Obsidian.

## Prerequisites

This skill works best with Obsidian but adapts to any notes setup. Check the user's config for `notes_app`. If not Obsidian, create files as plain markdown and skip Obsidian-specific steps (URI opening, wikilinks). If no notes app is configured, create files in `${STATE_PATH}/notes/` as plain markdown.

## Arguments

- `/project [name]` — create a folder project (always folder format)

## Format

**Every project gets folder format.** No single-file projects. This keeps everything consistent and means every project is ready to receive reference material, deliverables, and notes from day one.

---

## Step 1: Gather Project Info

If the user didn't provide a name, ask for one.

Also gather (or infer from context):
- **Status:** planning, active, on-hold, complete (default: planning). This goes in frontmatter only — never in the body.
- **Description:** one-sentence overview (can be a placeholder)
- **Tags:** infer from context (e.g., `[work, automation]` for a build project, `[personal, home]` for a home project)
- **Owner:** read from `~/.claude/soul.md` or `crystal.local.yaml` (`user.name` / `owner` field) if available. Otherwise use `$(git config user.name)`, `$USER`, or "TBD".
- **Key files:** ask "Any key files or directories to note?" (for CLAUDE.md). Can be left as placeholder.
- **Working conventions:** ask or leave as placeholder (for CLAUDE.md)

---

## Step 2: Generate Filename

`project name` → lowercase, spaces to hyphens, strip special characters.

Example: "Website Redesign" → `website-redesign`

---

## Step 3: Check for Conflicts

Glob `~/Documents/Projects/` for both `{filename}.md` and `{filename}/`.

If a file or directory with that name already exists, ask: "A project already exists. Open existing, choose a different name, or overwrite?"

---

## Step 4: Create the Project

Build the project file directly — don't read the template files. The templates exist for manual use in Obsidian; the skill produces lean, populated output.

### Core sections (always include)

```markdown
---
type: project
date-created: {today}
status: {status}
tags: [{tags}]
---

# {Project Name}

**Started:** {today}

## Overview

{description}

## Goals

- {goal 1 — infer from context or leave placeholder}

## Current State

### Done

### In Progress

### Next

## Key Decisions

## Notes

---

**Last Updated:** {today}
```

### Additional sections for folder format

Insert before the `---` / `**Last Updated:**` footer:

```markdown
## Project Files

- `_meta/reference/` — Research, specs, background docs
- `_meta/deliverables/` — Outputs, proposals, reports
- `_meta/notes/` — Meeting notes, call notes, working notes

Use `/project-load {filename}` to load project context.
```

### Step 4b: Generate CLAUDE.md

Create a `CLAUDE.md` in the project root. This file helps any Claude Code session opened in this folder understand the project. Fill in the placeholders using info gathered in Step 1:

```markdown
# {Project Name}

## About

{description from Step 1}

## Key Context

- **Status:** {status}
- **Owner:** {owner}
- **Project tracker:** `_project.md` (local only, gitignored)

## Project Structure

` ` `
_project.md          # Project tracker — status, decisions, goals
_meta/               # Project management files (gitignored)
  reference/         # Research, specs, external docs
  deliverables/      # Final outputs, reports, exports
  notes/             # Working notes, meeting notes, scratch
` ` `

The `_meta/` directory and `_project.md` are local project management files. They are gitignored and do not get committed. Use `/project-load` to pull project context into any Claude session.

## Key Files

- {key files from Step 1, or "TBD" placeholder}

## Working Conventions

- {conventions from Step 1, or "TBD" placeholder}
```

**Note:** Replace the ` ` ` with actual backtick fences in the output file.

### Step 4c: Create .gitignore

Check if the project folder has a `.git/` directory:
- **If yes (existing repo):** Read the existing `.gitignore` and append `_project.md` and `_meta/` if not already present.
- **If no:** Create a `.gitignore` from the template at `~/Documents/Projects/_template/.gitignore.template`.

Either way, the `.gitignore` must exclude `_project.md` and `_meta/` so project management files never get committed.

---

### Sections to add only when relevant

These are NOT included by default. Add them only if the user provides the information or the context clearly calls for it:

- **Waiting On** table — add when there are known blockers or dependencies on other people
- **Technical Approach** — add for technical/engineering projects
- **Timeline** — add when there are known deadlines or milestones
- **Team & Stakeholders** — add for collaborative projects with multiple people
- **Resources** — add when there are known external links

### Waiting On format (when included)

```markdown
## Waiting On

| Person | For What | Since | Follow-up By | Task Created |
|--------|----------|-------|--------------|--------------|
| {name} | {what} | {date} | {date} | {yes/no} |
```

### Writing the files

1. Create directory: `~/Documents/Projects/{filename}/`
2. Create `_meta/` with subdirectories: `_meta/reference/`, `_meta/deliverables/`, `_meta/notes/`
3. Write tracker to: `~/Documents/Projects/{filename}/_project.md`
4. Generate `CLAUDE.md` (see Step 4b below)
5. Create `.gitignore` (see Step 4c below)

---

## Step 5: Open in Obsidian

Open the new project file in Obsidian. Requires `dangerouslyDisableSandbox: true` on macOS.

Open the `_project.md` in the user's editor if applicable. Projects live in `~/Documents/Projects/`, not in the Obsidian vault, so do NOT use Obsidian URI schemes.

The `vault_name` should be read from `${CONFIG_PATH}` or inferred from the vault directory name.

**Note:** This step is macOS/Obsidian-specific. On other platforms, adapt accordingly.

---

## Step 6: Confirm

```
Created: ~/Documents/Projects/{filename}/
  _project.md (tracker)
  CLAUDE.md (project context for Claude sessions)
  .gitignore (excludes _project.md and _meta/)
  _meta/
    reference/
    deliverables/
    notes/
Status: {status}

Use /project-load {filename} to load project context in future sessions.
cd ~/Documents/Projects/{filename} && claude to work directly in the project.
```
