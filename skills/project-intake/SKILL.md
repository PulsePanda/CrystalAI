---
name: project-intake
description: "Take a handed-off project package and merge it into the user's environment. This is the receiving end of /project-handoff. Accepts a local zip, an HTTP(S) URL, or an already-unzipped folder, lands the project in the user's configured projects directory, preserves any incoming CLAUDE.md as HANDOFF.md so the recipient's own CLAUDE.md conventions aren't clobbered, creates a tracker file matching the user's project convention, initializes a fresh git history, and briefs the user on what's inside. Works for ANY kind of project — code repos, consulting engagement folders, doc-heavy deliverables, design systems, research binders, monorepos — not just web apps. Trigger on: 'intake this project', 'pull this project in', 'unpack this handoff', 'I got a handoff from X', 'bring this project in', 'set this project up', 'receive this project', 'extract this handoff', 'merge this project into my setup', '/project-intake'. Also trigger when the user mentions a zip file in Downloads that looks like a handoff package, a URL pointing to a project archive, or references a project they just received from another developer. Use this EVEN IF the user doesn't say the word 'intake' — if they're receiving a project from someone else and need it on disk and integrated into how they work, this is the skill. Do NOT trigger for: creating a brand new empty project (use project), opening or loading an existing project (use project-load), plain unzip-this-file tasks that have nothing to do with projects, or archiving a finished project (use project-archive)."
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Project Intake

The partner to `/project-handoff`. When someone hands you a packaged project — code, consulting engagement, design system, research folder, anything — this skill gets it on disk in the right place, renames the incoming AI brief to `HANDOFF.md` so it doesn't clobber your own CLAUDE.md conventions, creates a tracker file matching how you organize projects, starts a fresh git history, and reports what's inside so you don't have to cold-read the package.

The skill is project-type agnostic. A React app, a folder of contracts and meeting notes, a design system, a monorepo — same flow. Only the briefing and setup commands change, and they're derived from what's actually in the package.

## Why this exists

Receiving a handed-off project is a context problem, not a files problem. Unzipping is easy. The hard part is: where does this go, does it collide with something I already have, what does the sender say about it, what do I need to do to run it (if anything), and how does this plug into my existing project workflow? This skill answers all of those in one pass and leaves you with a project that's ready to open and work in.

The skill never modifies the original input — zip, URL download, or source folder. Everything happens in `/tmp/` staging until the final move.

## Portability

This skill ships through CrystalAI and must work for any user. No hardcoded paths to a specific vault, a specific projects directory, or a specific project-tracking convention.

**Config source of truth:** `~/.claude/crystal.local.yaml`. Two keys:

- `projects_path` — absolute path (tilde OK) to the user's project directory
- `project_tracker_convention` — one of: `_project_md_inside`, `sibling_md`, `yaml_front`, `none`

**First-run behavior** if either key is missing:

- `projects_path` → ask the user where projects live, default to `~/Documents/Projects/` only if they decline. Persist.
- `project_tracker_convention` → auto-detect by running `scripts/detect-convention.sh`, report the finding, confirm with the user, persist the agreed value.

**Subsequent runs** read both keys from config without rescanning. Zero overhead after first run. See `references/config-schema.md` for the keys, legal values, and examples.

## Inputs

The user gives you one of three things. Auto-detect which:

| Input shape | Example | How to handle |
|---|---|---|
| Local zip file | `~/Downloads/alibi-website.zip` | `unzip` to staging |
| HTTP(S) URL | `https://example.com/foo.zip` | `curl -L` to `/tmp/`, then `unzip` |
| Already-unzipped folder | `~/Downloads/alibi-website/` | `rsync -a` copy to staging |

Detection logic:

```bash
if [[ "$INPUT" == http://* || "$INPUT" == https://* ]]; then
    SOURCE_KIND="url"
elif [[ -f "$INPUT" && "$INPUT" == *.zip ]]; then
    SOURCE_KIND="zip"
elif [[ -d "$INPUT" ]]; then
    SOURCE_KIND="folder"
else
    # The input isn't a recognizable shape — ask the user which of the three it is.
    :
fi
```

If the user hasn't told you what the input is and there's an obvious recent candidate (a `.zip` in `~/Downloads/` whose name matches something the user just mentioned), it's fair to suggest it rather than asking cold.

## Step-by-step workflow

### Step 1 — Resolve the input

Detect the source kind. For URLs, download first:

```bash
TMP_ZIP="/tmp/project-intake-dl-$(openssl rand -hex 4).zip"
curl -L --fail --silent --show-error -o "$TMP_ZIP" "$INPUT" || {
    echo "Download failed — aborting."
    exit 1
}
ZIP_PATH="$TMP_ZIP"
```

For zips and folders, use the path directly. Verify:

- Zip files should pass `unzip -t "$ZIP_PATH" > /dev/null` (valid archive).
- Folders should be readable and non-empty (`[[ -d "$INPUT" && -n "$(ls -A "$INPUT")" ]]`).

If verification fails, stop and report — don't guess at recovery.

### Step 2 — Load config (prompt and persist on first run)

```bash
IFS=$'\t' read -r PROJECTS_PATH TRACKER_CONVENTION < <(
    "$HOME/.claude/skills/project-intake/scripts/read-config.sh"
)
# Expand tilde for shell use — YAML keeps the literal ~, we don't.
PROJECTS_PATH="${PROJECTS_PATH/#\~/$HOME}"
```

Empty value means the key is missing from `crystal.local.yaml`. Handle the first-run prompt:

- **If `PROJECTS_PATH` is empty:**
  - Ask: "Where do you keep your projects? (press enter for `~/Documents/Projects/`)"
  - Create the directory with `mkdir -p` if it doesn't exist.
  - Persist: `scripts/read-config.sh --write projects_path "$value"`
- **If `TRACKER_CONVENTION` is empty:**
  - Run `scripts/detect-convention.sh "$PROJECTS_PATH"`. It scans existing project folders and prints `_project_md_inside`, `sibling_md`, `yaml_front`, `none`, or `unknown`.
  - If the script returns a concrete convention, confirm with the user: "Looks like you use `_project.md` files inside each project folder. Want me to use that for future intakes?" — wait for yes/no.
  - If it returns `unknown` (no projects scanned), ask the user directly which of the four shapes they want.
  - Persist the agreed value.

If `PROJECTS_PATH` resolves to a directory that doesn't exist, `mkdir -p` it before proceeding — first-time users will hit this.

### Step 3 — Stage into /tmp

```bash
STAGING="/tmp/project-intake-$(openssl rand -hex 4)"
mkdir -p "$STAGING"

case "$SOURCE_KIND" in
    zip|url)
        unzip -q "$ZIP_PATH" -d "$STAGING"
        ;;
    folder)
        # Copy the folder itself (with its basename) into staging,
        # so $STAGING/<name>/ is the project root.
        rsync -a "${INPUT%/}" "$STAGING/"
        ;;
esac
```

Never work against the original input after this point. The staging dir is disposable — it gets moved or removed in later steps.

### Step 4 — Derive the project name

The top-level directory inside staging is the project name. Three cases:

1. **One top-level directory** — the common case. Project name is its basename.
2. **Multiple top-level directories** — list them, ask the user which one is the project, or offer to intake each separately in sequence.
3. **Files at the root of staging** (zip had no wrapper directory, which is a sender mistake but happens) — create a wrapper named after the zip filename sans `.zip` and move everything inside.

```bash
cd "$STAGING"
mapfile -t TOP_DIRS < <(find . -mindepth 1 -maxdepth 1 -type d -printf '%f\n')
mapfile -t TOP_FILES < <(find . -mindepth 1 -maxdepth 1 -type f -printf '%f\n')

if (( ${#TOP_DIRS[@]} == 1 && ${#TOP_FILES[@]} == 0 )); then
    PROJECT_NAME="${TOP_DIRS[0]}"
elif (( ${#TOP_DIRS[@]} == 0 && ${#TOP_FILES[@]} > 0 )); then
    # Files at root — wrap them.
    PROJECT_NAME=$(basename "$ZIP_PATH" .zip)
    mkdir "$PROJECT_NAME"
    mv -- ./!($PROJECT_NAME) "$PROJECT_NAME/" 2>/dev/null || true
else
    # Multiple dirs, or mixed — ask user.
    :
fi
```

### Step 5 — Collision check

```bash
DEST="$PROJECTS_PATH/$PROJECT_NAME"
if [[ -e "$DEST" ]]; then
    # STOP. Do not overwrite, ever. Offer the user:
    #   (a) rename incoming — ask for a new name, loop back to this check
    #   (b) abort — clean up staging, exit
    #   (c) (optional) show a summary diff against existing
    :
fi
```

Never overwrite silently, no matter how confident you are that the existing folder is stale. If the user wants to replace, they rename or delete the existing one first. This is a hard rule — see the Hard Rules section below.

An existing empty directory at the destination still counts as a collision. Ask anyway — the user may have `mkdir`ed in advance and intended to intake somewhere else.

### Step 6 — Analyze the contents

Priority order for building the briefing:

1. **`HANDOFF.md` or `CLAUDE.md` at the project root** → read it in full, this IS the briefing. Summarize: what the project is, stack (if mentioned), current state, pending work, hard rules from the sender.
2. **`README.md`** → fallback if no handoff brief exists.
3. **Directory tree + stack file scan** → construct a briefing from structure.

For setup commands, only look if a stack file is present at the root. Recognized files:

| File | Setup command |
|---|---|
| `package.json` | `npm install && npm run dev` (read `scripts.dev`/`scripts.start` for the exact name) |
| `pnpm-lock.yaml` | swap `npm` for `pnpm` |
| `yarn.lock` | swap `npm` for `yarn` |
| `pyproject.toml` (poetry) | `poetry install` |
| `pyproject.toml` (uv) | `uv sync` |
| `requirements.txt` | `python -m venv .venv && .venv/bin/pip install -r requirements.txt` |
| `Cargo.toml` | `cargo build` |
| `Gemfile` | `bundle install` |
| `go.mod` | `go build ./...` |

**If no stack file exists, do NOT fabricate setup commands.** A folder of contracts, design files, or meeting notes has no setup. The briefing just describes what's there and stops.

### Step 7 — Rename incoming `CLAUDE.md` to `HANDOFF.md`

If the staged project root has a `CLAUDE.md`, rename it. This preserves the sender's AI brief without clobbering the recipient's own CLAUDE.md conventions.

```bash
cd "$STAGING/$PROJECT_NAME"
if [[ -f CLAUDE.md ]]; then
    if [[ -f HANDOFF.md ]]; then
        # Both exist — don't clobber either.
        mv CLAUDE.md "HANDOFF-$(date +%Y%m%d-%H%M%S).md"
    else
        mv CLAUDE.md HANDOFF.md
    fi
fi
```

### Step 8 — Create the tracker file

Only if `TRACKER_CONVENTION` is not `none`. Read `references/tracker-templates.md` for the scaffolding for each convention. Fill in:

- `{{NAME}}` — project name
- `{{CREATED}}` — today's date (`YYYY-MM-DD`)
- `{{DESCRIPTION}}` — one sentence pulled from the briefing (first sentence of `HANDOFF.md` or `README.md`, or `"Intaken from handoff on {{CREATED}}"` if nothing obvious)
- `{{SOURCE}}` — `"handoff zip"` / `"URL"` / `"folder copy"`

For `_project_md_inside` and `yaml_front`, write the tracker file to `$STAGING/$PROJECT_NAME/` now. For `sibling_md`, defer until after the move in Step 10 — it lives next to the project folder, not inside it.

If the convention value in config is unrecognized (typo, old schema, whatever), warn and skip rather than failing. The project still lands; the user can add a tracker manually.

If the staged project already contains a `_project.md`, `.project.yaml`, or sibling tracker that came with the handoff, do NOT overwrite. Leave the sender's file in place and skip tracker creation. Warn the user.

### Step 9 — Git init

Only if `.git/` does not already exist in the staged project:

```bash
cd "$STAGING/$PROJECT_NAME"
if [[ ! -d .git ]]; then
    git init -q
    git add -A
    git -c user.name="project-intake" -c user.email="intake@local" \
        commit -q -m "intake: $PROJECT_NAME from $SOURCE_KIND"
fi
```

The `-c user.name` / `user.email` overrides are defensive — if the user hasn't set global git identity, the commit would fail. They apply to this single invocation only. The user can amend with their real identity if they care.

Git failures are non-fatal. If git isn't installed or the commit errors, warn and keep going. Git init is a convenience, not load-bearing.

### Step 10 — Move into place

```bash
mv "$STAGING/$PROJECT_NAME" "$DEST"
rm -rf "$STAGING"
# And clean up the URL-case download if we made one:
[[ "$SOURCE_KIND" == "url" && -f "$ZIP_PATH" && "$ZIP_PATH" == /tmp/* ]] && rm -f "$ZIP_PATH"
```

If `TRACKER_CONVENTION` is `sibling_md`, create the tracker file now at `$PROJECTS_PATH/$PROJECT_NAME.md`.

### Step 11 — Report

Tell the user:

- **Where it landed** — absolute path to the project directory.
- **Source** — `extracted from ~/Downloads/foo.zip`, `downloaded from URL`, or `copied from folder`.
- **Briefing** — a paragraph summarizing the project based on Step 6. If there was a HANDOFF.md, distill it; don't dump it. Call out the 2-3 most important things the sender flagged (pending work, env vars, gotchas).
- **Setup commands** — only if a stack file was detected. Format as a copy-paste block including the `cd` line.
- **Tracker** — `Created _project.md inside the project folder`, `Created sibling foo.md`, or `No tracker — your config is set to none`.
- **Git** — `Initialized a fresh git repo with one commit` or `Existing .git/ preserved`.
- **Anything unusual** — collision that got resolved, multiple top-level dirs, missing README, files that looked suspicious, sender's tracker left in place, etc.

Keep the report tight. The user will open the project and see the rest for themselves.

## Reference files and scripts

- `references/config-schema.md` — documents the `crystal.local.yaml` keys this skill reads and writes, with legal values and examples.
- `references/tracker-templates.md` — scaffolding for each tracker convention. Read before writing the tracker file in Step 8.
- `scripts/read-config.sh` — reads `projects_path` and `project_tracker_convention` from `~/.claude/crystal.local.yaml`. Prints tab-separated values on stdout; empty string means missing. Supports `--write KEY VALUE` for first-run persistence.
- `scripts/detect-convention.sh` — scans a projects directory and infers which tracker convention is in use. Prints the detected value or `unknown`.

## Examples

### Example 1 — Doc-only consulting handoff (the case that breaks code-first assumptions)

The user runs `/project-intake ~/Downloads/smith-advisory.zip`. Inside the zip:

```
smith-advisory/
├── HANDOFF.md
├── contracts/
│   ├── engagement-letter-signed.pdf
│   └── nda.pdf
├── meetings/
│   ├── 2026-03-01-kickoff.md
│   └── 2026-03-15-check-in.md
└── deliverables/
    └── q1-report-draft.docx
```

No `package.json`. No `src/`. This is a consulting engagement folder, not code.

Flow:

1. Staged to `/tmp/project-intake-ab12/`.
2. Config loaded: `projects_path=~/Documents/Projects`, `project_tracker_convention=_project_md_inside`.
3. Project name: `smith-advisory`.
4. No collision.
5. Analysis: reads `HANDOFF.md` for briefing. Notes: "Q1 report draft pending client feedback by 2026-04-20. Engagement ends 2026-06-30." No stack files, so no setup section.
6. `HANDOFF.md` stays as-is (no incoming `CLAUDE.md` to rename).
7. Creates `_project.md` inside the folder, status `active`, description pulled from HANDOFF first line, pointer to HANDOFF.md.
8. Git init + initial commit `intake: smith-advisory from zip`.
9. Moves to `~/Documents/Projects/smith-advisory/`.

Report back: path, "engagement letter + NDA signed, Q1 report draft in progress, client review due April 20," tracker created, git initialized. **No setup commands** — this isn't code, and fabricating `npm install` for a folder of PDFs would be nonsense.

### Example 2 — Code project handoff

The user runs `/project-intake ~/Downloads/alibi-website.zip`. Inside:

```
alibi-website/
├── CLAUDE.md
├── README.md
├── package.json
├── src/
├── public/
└── astro.config.mjs
```

Flow:

1. Staged.
2. Config loaded.
3. No collision.
4. Analysis: reads `CLAUDE.md` (the sender's brief from `/project-handoff`). Notes: "Astro site on Cloudflare Pages. Form activation pending — backend inbox needs to exist before the contact form works."
5. Detects `package.json`, reads `scripts.dev`. Setup: `npm install && npm run dev`.
6. Renames `CLAUDE.md` → `HANDOFF.md`.
7. Creates `_project.md` with description pulled from HANDOFF.md opening line.
8. Git init.
9. Moves to `~/Documents/Projects/alibi-website/`.

Report back: path, "Astro site on Cloudflare, currently pre-launch, form activation is the blocker," setup block `cd ~/Documents/Projects/alibi-website && npm install && npm run dev`, tracker created, git initialized, **and flag the form activation as the immediate thing to know**.

## Edge cases

- **Zip has no top-level directory** (files at archive root): create a wrapper named after the zip filename sans `.zip` and move everything inside. Warn the user — well-formed handoffs always have a wrapper.
- **Zip has multiple top-level directories**: list them. Ask which is the project, or offer to intake each separately in sequence.
- **URL download fails** (404, timeout, non-zip content): report the HTTP status and the first few lines of output. Abort. Leave nothing behind.
- **Staged project is empty**: abort with a clear error. Hollow zips are almost always a sender mistake — don't try to rescue.
- **Tracker convention value is something unrecognized** (user typoed, old schema): warn and skip tracker creation. Don't crash.
- **First-run config write fails** (permission, upstream YAML syntax issue): warn, proceed with in-memory values for this invocation, tell the user to fix the file manually before next run.
- **Git init fails** (git not installed, weird permissions): warn and continue. The project still lands correctly.
- **Incoming project has BOTH `CLAUDE.md` AND `HANDOFF.md`**: rename `CLAUDE.md` to `HANDOFF-<timestamp>.md`. Preserve both.
- **Collision destination exists but is empty** (user `mkdir`ed in advance): still a collision. Ask.
- **`projects_path` directory doesn't exist on disk**: `mkdir -p` before the move.
- **Incoming project already ships with a tracker file** matching the user's convention (rare — handoff normally strips these): leave the sender's file in place, skip tracker creation, warn.

## Hard rules

1. **Never hardcode user-specific paths.** No `~/Documents/Projects/` literals in logic (only as a fallback default after explicit user decline). No vault paths, no Austin-specific conventions, no Obsidian references. Everything comes from config or user prompt.
2. **Never overwrite an existing project directory.** Collision = stop and ask. Rename, abort, or diff. Never silently replace, no matter how confident you are.
3. **Never fabricate setup commands** for projects without stack files. Doc-only and code-free projects get no setup section in the report.
4. **Never run dependency installs automatically.** Report the command, let the user run it. `npm install` and friends are slow, noisy, and occasionally destructive — the user decides when.
5. **Never modify the original input.** Zip, URL download, source folder — none of them get touched. Always stage.
6. **Always stage in `/tmp/` and clean up on success.** On failure, leave staging in place and tell the user the path so they can debug or retry.
7. **Always rename incoming `CLAUDE.md` to `HANDOFF.md`** before moving into place. The user's own CLAUDE.md conventions must not be clobbered by a sender's brief.
8. **Never send notifications, emails, or any side-effects beyond the filesystem and the terminal report.** The skill's job ends when the project is on disk and the user has been briefed.
