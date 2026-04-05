---
name: vault-upgrade
description: Upgrade CrystalAI installation from the repo. Diffs repo against installed ~/.claude/, backs up, applies safe updates, and guides AI-assisted merges for customized files.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent, AskUserQuestion
---

# /vault-upgrade — CrystalAI Upgrade Command

Upgrade an installed CrystalAI (`~/.claude/`) from the source repo. Runs the deterministic shell script for safe operations, then uses AI judgment for merges and customization decisions.

## Usage

```
/vault-upgrade                        # Full upgrade (dry-run first, then execute with approval)
/vault-upgrade --dry-run              # Only show what would change
/vault-upgrade --source /path/to/repo # Specify repo location
```

---

## Step 1: Locate the Source Repo

Determine the CrystalAI source repo path. Check in order:

1. If the user passed `--source /path/to/repo`, use that path
2. If `~/.claude/.crystal-version.json` exists, read it and use the `source_path` field (if present)
3. Check `~/Documents/GitHub/CrystalAI/` — verify it exists and contains `vault-manifest.json`
4. If none found, ask the user:

```
I can't find the CrystalAI source repo. Where is it located?
```

Once located, verify the repo contains `vault-manifest.json` and `scripts/upgrade.sh`. If either is missing, stop:

```
The source repo at {path} is missing required files (vault-manifest.json or scripts/upgrade.sh).
Make sure you're pointing to a valid CrystalAI repo.
```

Store the resolved path as `SOURCE` for all subsequent steps.

---

## Step 2: Run Dry-Run

Always run the dry-run first, even for a full upgrade:

```bash
bash "{SOURCE}/scripts/upgrade.sh" --source "{SOURCE}" --target "$HOME/.claude" --dry-run
```

Then read the generated plan:

```bash
cat "$HOME/.claude/upgrade-plan.md"
```

Parse the plan to extract:
- Current version and new version
- Counts per classification: infrastructure, scaffold (unmodified), scaffold (customized), new templates
- List of files classified as `merge_required` or `customized`
- List of protected paths

---

## Step 3: Present the Plan

Show the user a clear summary:

```
CrystalAI Upgrade: v{current} -> v{new}

Auto-updates (safe):
  - {N} infrastructure files (agents, schemas, docs)
  - {N} unmodified scaffold files
  - {N} new vault templates

AI-assisted merges needed:
  - {list each file that needs merge}

Customized files (your review):
  - CLAUDE.md -- you've customized this; I'll show the diff
  - {other customized scaffold files}

Protected (untouched):
  - state/, crystal.local.yaml, crystal.secrets.yaml, plugins/
```

If the user passed `--dry-run`, stop here. Report the plan and exit.

---

## Step 4: Get Approval

Ask the user:

```
Ready to proceed? I'll create a backup first. (yes/no)
```

If the user says no, stop. Do not proceed.

---

## Step 5: Run the Script (Deterministic Parts)

Execute the upgrade script in full mode:

```bash
bash "{SOURCE}/scripts/upgrade.sh" --source "{SOURCE}" --target "$HOME/.claude"
```

This handles:
- Backup creation (timestamped in `~/.claude/.backups/`)
- Infrastructure file copies (always safe to overwrite)
- Unmodified scaffold file copies (user hasn't changed them)
- Vault directory creation
- New template file additions
- Writing `.crystal-version.json`

Read the script output to capture:
- The backup path
- Counts of what was copied
- Any errors

If the script exits non-zero, report the error and stop. Do not proceed to merges.

---

## Step 6: AI-Assisted Merges

For each file the dry-run classified as `merge_required` or `customized`, handle it with AI judgment. The categories below cover the known file types.

### 6a: settings.json

If `settings.json` appears in the merge list:

1. Read the installed `~/.claude/settings.json`
2. Read the repo's `{SOURCE}/settings.json.template`
3. The goal: add any NEW hooks, permissions, or config from the template WITHOUT destroying:
   - User's existing permissions
   - User's MCP server configuration
   - User's existing hooks (even if modified)
   - Any other user customizations
4. Strategy: treat `settings.json.template` as "features to add" not "file to replace"
5. Build the merged result — union of user's existing config and new template entries
6. Show the user what will be added/changed:

```
settings.json merge:
  Adding: {new permission entries}
  Adding: {new hook entries}
  Keeping: {user's custom MCP servers}
  Keeping: {user's existing hooks}
```

7. Ask: "Apply these changes to settings.json? (yes/no)"
8. Only write the merged result if approved

### 6b: CLAUDE.md

NEVER auto-merge CLAUDE.md. This is the user's most personalized file.

1. Read both `~/.claude/CLAUDE.md` (installed) and `{SOURCE}/CLAUDE.md` (repo)
2. Identify sections in each version (use markdown headers as section boundaries)
3. Classify each section:
   - **New in repo**: section exists in repo but not in user's file
   - **User-only**: section exists in user's file but not in repo
   - **Both, identical**: same content in both
   - **Both, different**: section exists in both but content differs
4. Walk the user through each difference:

For new sections:
```
The repo added a new section: "{section name}"
{show the content}
Add this to your CLAUDE.md? (yes/no)
```

For user-only sections:
```
Your CLAUDE.md has "{section name}" which isn't in the repo. Keeping it.
```

For modified sections:
```
Both versions have "{section name}" but yours is customized.
--- Repo version ---
{repo content}
--- Your version ---
{user content}
Keep yours or take the update? (keep/update)
```

5. Apply only the approved changes using Edit tool operations
6. For sections the user wants to keep, leave them untouched

### 6c: Skills

For each skill appearing in the merge list:

**New skill (exists only in repo):**
- Copy the entire skill directory to `~/.claude/skills/{name}/`
- Tell the user: "Added new skill: {name} -- {description}"

**User-created skill (exists only in user's installation):**
- Leave it completely alone
- Note: "Keeping your custom skill: {name} (not in repo)"

**Both versions exist:**
1. Compare the installed skill files against the repo skill files
2. For each file in the skill:
   - If SHA-256 hashes match -> skip (identical)
   - If different -> this needs merge attention
3. For skills with differences, spawn the vault-upgrader agent:

```
Analyze both versions of the {name} skill and propose a merge.

Installed version: {path to installed skill}
Repo version: {path to repo skill}

The user may have customized references, examples, or the SKILL.md itself.
Propose a merged version that preserves user customizations while incorporating
new features or fixes from the repo.
```

4. Present the agent's proposed merge to the user for approval
5. Apply only if approved

### 6d: Scripts

For each script in the repo's `scripts/` directory:

**Not installed:** Copy it to `~/.claude/scripts/`. Tell the user.

**Installed and identical (SHA-256 match):** Skip silently.

**Installed and different:**
1. Show the diff:
```bash
diff "$HOME/.claude/scripts/{filename}" "{SOURCE}/scripts/{filename}"
```
2. Ask: "Your {filename} differs from the repo. Keep yours, take the update, or merge? (keep/update/merge)"
3. If merge, show both versions and propose a combined version for approval

---

## Step 7: Vault Structure

Handle the vault directory (`{SOURCE}/vault/`) which contains directory structure and templates for the user's Obsidian vault (or similar).

Determine the vault path:
- Read `~/.claude/crystal.local.yaml` for a configured vault path
- Fall back to the default: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi/`
- If neither exists, ask the user

For each directory and template file in `{SOURCE}/vault/`:

**Vault directory doesn't exist at all:**
- Create it with all template files from the repo
- Tell the user what was created

**Vault directory exists WITH content:**
- ONLY add new template files that don't already exist
- NEVER overwrite existing content
- CrystalAI plugs into existing vaults -- it does not own them
- Report: "Added {N} new templates to {dir}. Skipped {N} existing files."

**Vault directory exists but is empty:**
- Add all template files from the repo

---

## Step 8: Finalize

1. Verify `~/.claude/.crystal-version.json` was written by the script:
```bash
cat "$HOME/.claude/.crystal-version.json"
```
Confirm it contains the new version number and a timestamp.

2. Show the user a final summary:

```
Upgrade complete: v{old} -> v{new}

Updated:
  - {N} infrastructure files
  - {N} scaffold files (auto)
  - {list of AI-merged files}

New:
  - {N} new files added
  - {list of new skills/templates}

Skipped:
  - {list of files user chose to keep}

Protected:
  - state/, crystal.local.yaml, crystal.secrets.yaml, plugins/

Backup: {backup_path}
```

3. Suggest: "Run a quick sanity check -- try `/resume` to verify your skills and state are intact."

---

## Step 9: Upgrade Log

Append an entry to `~/.claude/state/operational/upgrade-log.md`:

```bash
mkdir -p "$HOME/.claude/state/operational"
```

If the file doesn't exist, create it with a header first:

```markdown
# CrystalAI Upgrade Log
```

Then append:

```markdown
## Upgrade: v{old} -> v{new} -- {YYYY-MM-DD}
- Infrastructure: {N} updated, {N} new
- Scaffold: {N} updated, {N} customized (AI merged)
- Skills: {N} merged, {N} new, {N} user-only
- Vault: {N} dirs created, {N} templates added
- Backup: {backup_path}
```

---

## Error Handling

- **Script not found**: Report the missing file path and stop
- **Script fails**: Show the full error output, report the backup location (if created), and stop before merges
- **Merge conflicts**: Never force a resolution. Always show both versions and ask the user
- **Permission errors**: Report and suggest fixing permissions
- **Disk space**: If backup creation fails, do not proceed with any file modifications
- **Interrupted upgrade**: The backup exists. Tell the user they can restore from {backup_path} if anything looks wrong

---

## Security Notes

- This command never modifies `crystal.secrets.yaml` or any file containing credential paths
- The `state/` directory is never overwritten -- it contains user data
- Plugins are never touched -- they have their own update mechanisms
- All changes are previewed before execution
- A timestamped backup is always created before any modifications
