---
name: project-archive
description: "Archive completed projects. Trigger when user says 'archive project', 'move to archive', 'project is done', 'complete the project', 'close out [project name]'. Moves project file or folder from Projects/ to Projects/Archive/YYYY/, updates status to archived, and confirms."
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Project Archive

Move completed projects from `Projects/` to `Projects/Archive/YYYY/`, update their status to archived, and confirm.

---

## Arguments

- `/project-archive` — list projects with status: completed, ask which to archive
- `/project-archive [name]` — archive a specific project by name

---

## Step 1: Resolve the Project

If a project name is provided:

1. Glob `${VAULT_PATH}/Projects/` for both `*name*.md` files and `*name*/` directories
2. Exclude `Archive/` from results
3. If **exact match** on folder name → use folder format
4. If **exact match** on file name → use single-file format
5. If **multiple matches** → present options and ask which one
6. If **no match** → tell the user: "No project matching '[name]' found in Projects/."

If no argument is provided:

1. Glob all `.md` files in `${VAULT_PATH}/Projects/` (not recursive into subdirs except `_project.md` in folder projects)
2. Read frontmatter from each
3. Filter to those with `status: completed`
4. Present a list and ask which to archive
5. If none have `status: completed`, report: "No completed projects found. To archive an active project, run `/project-archive [name]`."

---

## Step 2: Confirm

Before archiving, confirm with the user:

> Archive **[project name]**? This moves it to `Projects/Archive/YYYY/`.

Wait for confirmation. Do not proceed without it.

---

## Step 3: Create Archive Directory

```bash
mkdir -p "${VAULT_PATH}/Projects/Archive/YYYY/"
```

Where YYYY is the current year.

---

## Step 4: Move the Project

### Single-file project

```bash
mv "${VAULT_PATH}/Projects/project-name.md" "${VAULT_PATH}/Projects/Archive/YYYY/project-name.md"
```

### Folder project

```bash
mv "${VAULT_PATH}/Projects/project-name/" "${VAULT_PATH}/Projects/Archive/YYYY/project-name/"
```

---

## Step 5: Update Frontmatter

### Single-file project

Edit the archived `.md` file:
- Set `status: archived`
- Add `date-archived: YYYY-MM-DD` (today's date)

### Folder project

Edit `_project.md` inside the moved folder:
- Set `status: archived`
- Add `date-archived: YYYY-MM-DD` (today's date)

---

## Step 6: Confirm

Report the result:

> Archived: `Projects/[name]` → `Projects/Archive/YYYY/[name]`
> Status updated to `archived`. Date archived: `YYYY-MM-DD`.

---

## Edge Cases

- **Project already in Archive/** — report: "This project is already archived."
- **Project has status: archived but is still in Projects/** — proceed with the move, note the status was already set.
- **Folder project missing _project.md** — move the folder but warn: "No _project.md found; could not update frontmatter."
- **Permission errors on move** — report the error and do not attempt to update frontmatter.
