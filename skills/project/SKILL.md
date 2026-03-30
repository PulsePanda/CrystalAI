---
name: project
description: Create new Obsidian project files and folders. ALWAYS use this skill — not just when the user explicitly says "create a project", but any time the intent is to START TRACKING something new. This includes direct requests ("create a project for X", "/project X", "make a project") AND indirect signals ("this should be a project", "let's track this", "set up tracking for X"). Also trigger when the user describes a new initiative with enough complexity to warrant tracking. Do NOT trigger for loading/opening existing projects (that's project-load), updating project content, or archiving — only for CREATING new ones.
version: 2.0.0
allowed-tools: Read, Write, Edit, Bash, Glob
---

# Create New Project

Creates a project file (or folder) in `${VAULT_PATH}/Projects/` and opens it in Obsidian.

## Prerequisites

This skill works best with Obsidian but adapts to any notes setup. Check the user's config for `notes_app`. If not Obsidian, create files as plain markdown and skip Obsidian-specific steps (URI opening, wikilinks). If no notes app is configured, create files in `${STATE_PATH}/notes/` as plain markdown.

## Arguments

- `/project [name]` — create a single-file project (default)
- `/project [name] --folder` — create a folder-style project with `reference/`, `deliverables/`, `notes/` subdirectories

## Choosing the Format

**Folder format** when the project will accumulate files over time — research docs, deliverables, meeting notes, reference material. Default to folder for:
- Client engagements (will have deliverables, reference docs)
- Multi-phase initiatives with accumulated reference material
- Any project the user describes as needing to "collect" or "accumulate" material

**Single-file format** when it's a simple initiative tracker — a skill build, a one-off task, a planning document.

When in doubt, ask: "Will this project accumulate reference material and deliverables, or is it mainly a tracker?"

---

## Step 1: Gather Project Info

If the user didn't provide a name, ask for one.

Also gather (or infer from context):
- **Status:** planning, active, on-hold, complete (default: planning). This goes in frontmatter only — never in the body.
- **Description:** one-sentence overview (can be a placeholder)
- **Tags:** infer from context (e.g., `[work, automation]` for a build project, `[personal, home]` for a home project)
- **Format:** file or folder (apply the heuristics above)

---

## Step 2: Generate Filename

`project name` → lowercase, spaces to hyphens, strip special characters.

Example: "Website Redesign" → `website-redesign`

---

## Step 3: Check for Conflicts

Glob `${VAULT_PATH}/Projects/` for both `{filename}.md` and `{filename}/`.

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

This project uses folder format:
- `reference/` — Research, specs, background docs
- `deliverables/` — Outputs, proposals, reports
- `notes/` — Meeting notes, call notes, working notes

Use `/project-load {filename}` to load project context.
```

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

**Single-file:**
- Write to `${VAULT_PATH}/Projects/{filename}.md`

**Folder:**
1. Create directory: `${VAULT_PATH}/Projects/{filename}/`
2. Create subdirectories: `reference/`, `deliverables/`, `notes/`
3. Write tracker to: `${VAULT_PATH}/Projects/{filename}/_project.md`

---

## Step 5: Open in Obsidian

Open the new project file in Obsidian. Requires `dangerouslyDisableSandbox: true` on macOS.

- **Single-file:** `open "obsidian://open?vault={vault_name}&file=Projects%2F{filename}.md"`
- **Folder:** `open "obsidian://open?vault={vault_name}&file=Projects%2F{filename}%2F_project.md"`

The `vault_name` should be read from `${CONFIG_PATH}` or inferred from the vault directory name.

**Note:** This step is macOS/Obsidian-specific. On other platforms, adapt accordingly.

---

## Step 6: Confirm

### Single-file
```
Created: Projects/{filename}.md
Status: {status}
Opened in Obsidian.
```

### Folder
```
Created: Projects/{filename}/
  _project.md (tracker)
  reference/
  deliverables/
  notes/
Status: {status}
Opened in Obsidian.

Use /project-load {filename} to load project context in future sessions.
```
