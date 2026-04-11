---
name: crystalai-upgrade
description: Upgrade CrystalAI installation from the repo. Diffs repo against installed ~/.claude/, backs up, applies safe updates, and guides AI-assisted merges for customized files.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Agent, AskUserQuestion
---

# /crystalai-upgrade — CrystalAI Upgrade Command

Upgrade an installed CrystalAI (`~/.claude/`) by automatically fetching the latest source from GitHub. Runs the deterministic shell script for safe operations, then uses AI judgment for merges and customization decisions.

## Usage

```
/crystalai-upgrade                        # Auto-fetch latest from GitHub, dry-run, then execute with approval
/crystalai-upgrade --dry-run              # Auto-fetch and only show what would change
/crystalai-upgrade --source /path/to/repo # Use a local working copy instead of fetching (dev testing)
```

---

## Step 1: Fetch the Source Repo

The repo is downloaded from GitHub automatically — the user does not need a local clone. Cache it under `~/.claude/.upgrade-cache/CrystalAI` so subsequent upgrades are fast.

Constants:

```bash
REPO_URL="https://github.com/PulsePanda/CrystalAI.git"
CACHE_DIR="$HOME/.claude/.upgrade-cache/CrystalAI"
```

Resolve `SOURCE`:

1. If the user passed `--source /path/to/repo`, set `SOURCE` to that path and skip the clone/fetch entirely. This override is for local dev testing against an uncommitted working copy.
2. Otherwise, if `$CACHE_DIR` does not exist, clone it fresh:
   ```bash
   mkdir -p "$HOME/.claude/.upgrade-cache"
   git clone "$REPO_URL" "$CACHE_DIR"
   ```
3. If `$CACHE_DIR` already exists, fetch the latest `main` and hard-reset the cache to it (the cache is owned by this command — any local drift is discarded):
   ```bash
   git -C "$CACHE_DIR" fetch origin main
   git -C "$CACHE_DIR" reset --hard origin/main
   ```
4. Set `SOURCE="$CACHE_DIR"`.

If git is not installed, the clone/fetch fails (network, auth, permissions), or the reset fails, report the full error output and stop. Do not proceed to any upgrade steps.

Verify the resolved `SOURCE` contains `vault-manifest.json` and `scripts/upgrade.sh`. If either is missing, stop:

```
The source repo at {SOURCE} is missing required files (vault-manifest.json or scripts/upgrade.sh).
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
- List of scaffold files classified as `customized` (settings.json, CLAUDE.md)
- List of protected paths

---

## Step 2b: Show What's New

Read `{SOURCE}/CHANGELOG.md`. Find the entry for the NEW version (the one being upgraded to). Extract the highlights and present them in a user-friendly format.

**Rules for the "What's New" summary:**
- Lead with new capabilities the user can actually use (new skills, new commands, new features)
- Skip internal refactors, manifest changes, and infrastructure details — users don't care about those
- Group into: "New things you can do", "Things that got better", and optionally "Breaking changes" (if any)
- Keep each item to one line
- Max 10 items total — pick the most impactful ones if the changelog is long
- Use plain language, not technical jargon

**Format:**

```
## What's New in v{new}

New things you can do:
  - /brainstorm — structured brainstorming sessions with idea capture
  - /dispatch — hand off complex multi-step tasks to run autonomously
  - /core-skill-creator — design-first workflow for building core skills
  - /project-archive — archive completed projects to Archive/YYYY/
  - People files — your vault now tracks people you interact with (Areas/People/)
  - Skill configs — customize core skills via ~/.claude/skill-configs/ without editing them

Things that got better:
  - /compress now saves session transcripts and updates people files
  - /meeting and /process-inbox automatically maintain people files
  - Updates are safer — core skills update cleanly, your customizations stay in skill-configs/
```

If upgrading across multiple versions (e.g., 1.0.0 → 1.2.0), show highlights from each version in order.

If the current and new versions are the same (forced re-install), skip this step.

---

## Step 3: Present the Plan

Show the user a clear summary:

```
CrystalAI Upgrade: v{current} -> v{new}

Auto-updates (safe):
  - {N} infrastructure files (agents, skills, schemas, docs, scripts)
  - {N} unmodified scaffold files
  - {N} new vault templates

AI-assisted merges needed:
  - {list each customized scaffold file, e.g. settings.json, CLAUDE.md}

Protected (untouched):
  - skill-configs/, state/, crystal.local.yaml, crystal.secrets.yaml, plugins/
```

If the user passed `--dry-run`, stop here. Report the "What's New" summary and the plan, then exit.

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
- Infrastructure file copies (agents, skills, schemas, docs, scripts — always safe to overwrite)
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

For each scaffold file the dry-run classified as `customized`, handle it with AI judgment. The only files that require AI-assisted merges are settings.json and CLAUDE.md — all other files (skills, scripts, agents, schemas, docs) are core infrastructure and are overwritten deterministically by the script.

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

### 6c: Skill Config Migration (one-time, pre-1.1.0 upgrades only)

This step only runs when the user's installed version (from `.crystal-version.json`) is < 1.1.0. Starting in 1.1.0, skills are core files that get overwritten on every upgrade. Users customize core skills via `~/.claude/skill-configs/<name>.yaml` instead of editing skill files directly.

1. Check the installed version from `~/.claude/.crystal-version.json`
2. If the version is >= 1.1.0, skip this step entirely — skill configs are already the expected mechanism
3. If the version is < 1.1.0 (or no version file exists), this is a first-time migration:

   a. Spawn the crystalai-upgrader agent:

   ```
   Scan the user's installed skills at ~/.claude/skills/ against the repo skills at {SOURCE}/skills/.
   For each skill, compare the installed version to the repo version.
   Identify any skills where the user has made meaningful customizations
   (changed references, examples, prompts, or behavioral rules).
   Ignore whitespace-only or formatting-only differences.
   Report a list of skills with customizations and what was customized.
   ```

   b. If the agent finds customizations, present them to the user:

   ```
   Skill Config Migration (one-time)

   Starting in v1.1.0, skills are core files updated automatically.
   Your customizations now go in skill-configs/ instead.

   I found customizations in these skills:
     - {skill-name}: {brief description of what was customized}
     - ...

   I can create skill-config files to preserve your customizations.
   Proceed? (yes/no)
   ```

   c. If approved, create `~/.claude/skill-configs/<name>.yaml` for each customized skill, extracting the user's customizations into the config format
   d. If no customizations are found, report: "No skill customizations detected. Skills will update cleanly going forward."

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
  - {N} infrastructure files (agents, skills, schemas, docs, scripts)
  - {N} scaffold files (auto)
  - {list of AI-merged files, if any}

New:
  - {N} new files added
  - {list of new templates}

Skipped:
  - {list of files user chose to keep}

Protected:
  - skill-configs/, state/, crystal.local.yaml, crystal.secrets.yaml, plugins/

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
- Skill configs migrated: {yes/no/N/A}
- Vault: {N} dirs created, {N} templates added
- Backup: {backup_path}
```

---

## Error Handling

- **Git clone/fetch fails**: Report the full git error output and stop. Do not proceed without a valid `SOURCE`.
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
- The `skill-configs/` directory is personal -- never overwritten by updates
- Plugins are never touched -- they have their own update mechanisms
- All changes are previewed before execution
- A timestamped backup is always created before any modifications
