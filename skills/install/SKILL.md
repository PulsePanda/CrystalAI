---
name: install
description: "Install new skills and agents into the CrystalAI framework from local files, archives, or GitHub URLs. Use this skill whenever the user says 'install skill', 'install agent', 'add this skill', 'add this agent', 'install from GitHub', 'install this package', '/install', or wants to add a new skill or agent to their ~/.claude/ setup. Also trigger for batch installs ('install all skills from X', 'install these agents'). Do NOT trigger for: creating new skills from scratch (use skill-creator), editing existing skills, or the initial CrystalAI installation (use install.sh)."
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, WebFetch, Agent
---

# /install — Skill & Agent Installer

Install skills and agents into CrystalAI from local paths, archives, or GitHub URLs.

## Usage

```
/install skill <source>          # Single skill
/install agent <source>          # Single agent
/install skills <directory>      # All skills in a directory
/install agents <directory>      # All agents in a directory
```

Sources can be:
- **Local directory** — `/path/to/my-skill/` (must contain SKILL.md)
- **Local file** — `/path/to/agent.md` (for agents)
- **Archive** — `/path/to/skill.zip` or `.tar.gz`
- **GitHub URL** — repo subdirectory or raw file URL

If the user just says `/install` with no arguments, ask what they want to install.

---

## Step 1: Parse the Command

Extract from the user's input:
- **Type**: `skill`, `agent`, `skills` (batch), or `agents` (batch)
- **Source**: the path, URL, or archive

If ambiguous (e.g., user pastes a path without specifying type), inspect the source:
- Directory containing `SKILL.md` → skill
- Single `.md` file that is NOT named `SKILL.md` and has agent frontmatter (name, description) → agent
- Directory containing multiple subdirectories with SKILL.md files → batch skills
- Directory containing multiple `.md` files with agent frontmatter → batch agents

---

## Step 2: Fetch the Source

### Local directory
Verify the path exists. Use it directly.

### Local archive (.zip, .tar.gz, .tgz)
Extract to a temp directory:
```bash
TEMP_DIR=$(mktemp -d)
# For .zip:
unzip -q "<archive>" -d "$TEMP_DIR"
# For .tar.gz/.tgz:
tar xzf "<archive>" -C "$TEMP_DIR"
```
After extraction, check if the archive created a single top-level directory (common with GitHub "Download ZIP"). If so, descend into it:
```bash
# If archive extracted to a single top-level dir, use that as the source
ENTRIES=("$TEMP_DIR"/*)
if [ ${#ENTRIES[@]} -eq 1 ] && [ -d "${ENTRIES[0]}" ]; then
    TEMP_DIR="${ENTRIES[0]}"
fi
```
Then treat the extracted contents as a local directory.

### GitHub URL
Handle these URL patterns:

**Raw file URL** (for agents):
`https://raw.githubusercontent.com/user/repo/branch/path/to/agent.md`
→ Fetch with WebFetch directly.

**Repo subdirectory URL** (for skills):
`https://github.com/user/repo/tree/branch/path/to/skill-name`
→ Convert to API URL and fetch file listing:
```
https://api.github.com/repos/{owner}/{repo}/contents/{path}?ref={branch}
```
→ Download each file. For entries with `type: "dir"`, recursively fetch their contents too. Reconstruct the full directory structure locally in a temp directory.

**Repo subdirectory URL** (for batch):
`https://github.com/user/repo/tree/branch/path/to/skills/`
→ Same API approach, but list subdirectories and process each.

If the GitHub API returns a 404 or rate limit error, tell the user and suggest they download manually or provide a token.

---

## Step 3: Validate

### Skill Validation

1. Check `SKILL.md` exists in the source directory
2. Read the frontmatter and verify:
   - `name` field exists and is a non-empty string
   - `description` field exists and is a non-empty string
   - Name follows convention: lowercase, hyphenated, no spaces
3. Scan for other files (references/, scripts/, templates/, assets/) — these are fine
4. Check for suspicious content: no files outside expected patterns, no binaries except in assets/

If validation fails, report exactly what's wrong and stop. Don't install a broken skill.

### Agent Validation

1. Check the file is `.md`
2. Read the frontmatter and verify:
   - `name` field exists and is non-empty
   - `description` field exists and is non-empty
3. Verify the body contains substantive content (not just frontmatter)

---

## Step 4: Preview and Confirm

Show the user what will be installed:

**For a skill:**
```
Skill: {name}
Description: {description}
Version: {version or "not specified"}
Files: {list of files/dirs}
Install to: ~/.claude/skills/{name}/
```

**For an agent:**
```
Agent: {name}
Description: {description}
Category: {detected or "needs selection"}
Install to: ~/.claude/agents/{category}/{filename}
```

**For batch installs**, show a summary table:
```
Found {N} skills/agents to install:
  1. {name} — {description}
  2. {name} — {description}
  ...
```

### Conflict Detection

Check if a skill or agent with the same name already exists:
- Skill: `~/.claude/skills/{name}/SKILL.md`
- Agent: search all category dirs in `~/.claude/agents/` for a file with matching `name` in YAML frontmatter (parse only the block between the first `---` pair, not the body)

If a conflict exists, show the user:
```
Conflict: {name} already exists at {path}
  Existing: {existing description}
  New:      {new description}
Options: [overwrite] [skip] [rename]
```

Wait for the user's choice. If overwriting, back up first (Step 5).

### Agent Category Detection

For agents, determine the category. Check the agent's content and description against existing categories:
- design, engineering, game-development, integrations, marketing, paid-media, product, project-management, sales, spatial-computing, specialized, strategy, support, testing

If the category is obvious from the agent's role description, suggest it. If ambiguous, ask the user to pick from the list. Default to `specialized` if truly unclear.

If the source provides a category (e.g., the file came from `agents/engineering/`), use that.

---

## Step 5: Install

### Back Up (if overwriting)

```bash
BACKUP_DIR="$HOME/.claude/.backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp -r "{existing_path}" "$BACKUP_DIR/"
```

### Copy Skill

```bash
# Create target directory
mkdir -p "$HOME/.claude/skills/{name}"
# Copy all files
cp -a "{source}/." "$HOME/.claude/skills/{name}/"
```

### Copy Agent

```bash
# Ensure category directory exists
mkdir -p "$HOME/.claude/agents/{category}"
# Copy the agent file
cp "{source_file}" "$HOME/.claude/agents/{category}/{filename}"
```

### Batch Install

Process each item sequentially. For each:
1. Validate
2. Check conflicts (collect all conflicts, present together)
3. Install approved items
4. Report results

---

## Step 6: Verify

After installation, verify the files landed correctly:

**Skill verification:**
```bash
# Check SKILL.md exists and is readable
test -f "$HOME/.claude/skills/{name}/SKILL.md" && echo "OK" || echo "FAIL"
```
Read the installed SKILL.md and confirm the frontmatter matches what was expected.

**Agent verification:**
```bash
test -f "$HOME/.claude/agents/{category}/{filename}" && echo "OK" || echo "FAIL"
```
Read the installed agent and confirm frontmatter is intact.

---

## Step 7: Report

Summarize what happened:

```
Installed:
  - skill: {name} → ~/.claude/skills/{name}/

Backed up:
  - {name} (previous version) → ~/.claude/.backups/{timestamp}/

Skipped:
  - {name} (user chose to skip)
```

For batch installs, give counts: "Installed 5 skills, skipped 1 (conflict), 0 failed."

Clean up any temp directories created during the process:
```bash
[ -n "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
```

---

## Error Handling

- **Network errors** (GitHub fetch): Report the error, suggest the user download manually and provide a local path
- **Permission errors**: Report and suggest `chmod` or running with appropriate permissions
- **Malformed frontmatter**: Show the raw frontmatter and explain what's missing
- **Archive extraction fails**: Report the error, suggest the user extract manually
- **Temp directory cleanup**: Always clean up temp directories when done, even on failure:
  ```bash
  rm -rf "$TEMP_DIR"
  ```

---

## Security Notes

Before installing, the skill shows the user exactly what files will be placed and where. This transparency is the primary safety mechanism — the user reviews and confirms before anything is written.

Do not install skills that contain shell commands in their SKILL.md body that would execute automatically (skills are instructions, not executables). Scripts in `scripts/` are fine — they only run when explicitly invoked.

If a skill or agent contains references to API keys, tokens, or credentials in its content (not just referencing where they're stored), flag this to the user before installing.
