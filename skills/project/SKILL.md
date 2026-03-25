---
name: crystal:project
description: This skill should be used when the user asks to "create a new project", "start a new project", "set up a project", or mentions wanting to track a new initiative. Helps create project files from the template and integrate them into the memory system.
version: 1.0.0
disable-model-invocation: true
allowed-tools: Read, Write, Edit, Bash, AskUserQuestion
---

# Create New Project

Creates a project file from the template in `Projects/` (vault root), updates the vault CLAUDE.md current state, and opens it in Obsidian.

---

## Step 1: Gather Project Info

If the user didn't provide a name, ask:

```
Question: "What would you like to name this project?"
```

Also gather (or infer from context):
- **Status:** Planning | Active | Paused | Complete (default: Planning)
- **Description:** one-sentence overview (can be a placeholder)

---

## Step 2: Generate Filename

`project name` → lowercase, spaces to hyphens, strip special characters.

Example: "Website Redesign" → `website-redesign.md`

---

## Step 3: Read Template

```
Read: /Users/Austin/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi/Projects/_template.md
```

---

## Step 4: Populate and Write

Replace placeholders with actual values. Fill in:
- Frontmatter: `date-created`, `status`, `tags`
- Heading: project name
- `**Status:**`, `**Started:**` (today's date)
- Overview section with the description
- `**Last Updated:**` (today's date)
- Replace `{{PROJECT-NAME}}` in Dataview queries with the actual project name

Write to:
```
/Users/Austin/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi/Projects/{filename}.md
```

If a file with that name already exists, ask: "A project file already exists. Open existing, choose a different name, or overwrite?"

---

## Step 5: Update Vault CLAUDE.md

Add the new project to the `**Active projects:**` list in the `# Current State` section of the vault CLAUDE.md:

```
- **Project Name** — [Status] — [one-line description]
```

Use Edit tool to insert after the `**Active projects:**` line.

---

## Step 6: Open in Obsidian

Requires `dangerouslyDisableSandbox: true` for this one call only.

```bash
open "obsidian://open?vault=VaultyBoi&file=Projects%2FFILENAME.md"
```

---

## Step 7: Confirm

```
Created: Projects/website-redesign.md
Status: Planning
Added to CLAUDE.md Active Projects.
Opened in Obsidian.
```
