---
name: project-handoff
description: "Package a project folder for handoff to another developer so their AI coding assistant (Claude Code, Cursor, Codex, etc.) can pick it up with full context. Stages a clean copy, excludes build artifacts and local-only files, rewrites CLAUDE.md as an AI operating manual for the receiving agent, ensures a README exists, zips the result to ~/Downloads/, and optionally drafts a handoff email via Apple Mail with the zip attached. Trigger on: 'handoff this project', 'hand off this project', 'package this for handoff', 'package this up', 'zip this up for X', 'send this to a developer', 'prepare this for another dev', 'get this ready for Tristen/Bobby/someone', 'bundle this up to hand over', 'make a handoff package', 'ship this to X to work on', '/project-handoff'. Use this EVEN IF the user doesn't say the literal word 'handoff' — if they're preparing a codebase for someone else to continue working on, this is the skill. Do NOT trigger for: archiving a finished project (use project-archive), compressing a session log (use compress), or simple zip-a-folder tasks where the receiver isn't another developer."
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Project Handoff

Package a project folder so the recipient can drop it into their AI coding assistant and be productive immediately. The critical piece is a purpose-built **CLAUDE.md** that briefs the next AI on project context, tech stack, design system, voice, current state, and hard rules — the things a cold reader (human or AI) would otherwise have to reconstruct by hunting through the codebase.

## Why this exists

When Austin sends a project to another developer, the bottleneck isn't the code — it's the *context*. Brand voice, design decisions, "why this is intentional," pending work, hard rules. This skill captures that context into a file that Claude Code auto-loads (`CLAUDE.md`), so the receiving AI orients itself without a human brief.

The skill never touches the originals. Everything happens in a staging copy.

---

## Inputs

Gather these before doing anything. If the user hasn't provided them, infer from context (current working directory, recent conversation, file paths mentioned) before asking. Only ask for what you genuinely cannot determine.

| Input | Required | How to resolve |
|---|---|---|
| **Project path** | yes | Absolute path to the repo root. Default to the current working directory if it looks like a project root. |
| **Project name** | yes | Basename of the project path, or a more human name pulled from `package.json` / `pyproject.toml` / README. |
| **Recipient** | no | Name or email. If only a first name, look up the person file in the Obsidian vault (see "Recipient lookup" below). Skip entirely if the user isn't sending it to anyone. |
| **Sender account** | no | Default: `ajv857@gmail.com` (Personal). Override if user specifies. |
| **Extra exclusions** | no | Additional paths/globs to exclude beyond the defaults. |
| **Project description, stack, state** | yes, for the CLAUDE.md | Infer from the repo first: read the existing `README.md`, `package.json` / `pyproject.toml` / `Cargo.toml`, any existing `CLAUDE.md`, directory structure. Ask the user only for gaps. |

---

## Step-by-step workflow

### Step 1 — Inspect the project

Read the project root to build the picture you'll need for the CLAUDE.md template:

- `README.md` → human-facing setup and overview
- `package.json` / `pyproject.toml` / `Cargo.toml` / `go.mod` → tech stack + dependencies + scripts
- Existing `CLAUDE.md` → may be a personal tracker (from CrystalAI's project skill), or may already be an AI brief. Read it either way; you'll overwrite it in the staged copy, not the original.
- `src/` tree → confirm the project structure line you'll write into the template
- Files that suggest a design system: `tailwind.config.*`, `tokens.*`, global CSS with `:root` CSS variables
- `.env.example` → surfaces required environment variables (note in template as pending/setup)

Build a mental model before touching anything. Write up the `CLAUDE.md` in your head first.

### Step 2 — Stage a clean copy

Create `/tmp/project-handoff-<short-random>/` and rsync the project into it, excluding everything in `references/default-exclusions.txt` plus any user-provided extras.

```bash
STAGING="/tmp/project-handoff-$(openssl rand -hex 4)"
mkdir -p "$STAGING"

# Build rsync exclusion args from the default file + any user extras
EXCLUDE_FILE="$HOME/.claude/skills/project-handoff/references/default-exclusions.txt"

rsync -a --exclude-from="$EXCLUDE_FILE" \
  {{PROJECT_PATH}}/ "$STAGING/{{PROJECT_NAME}}/"
```

The staging directory is disposable — we clean it up in step 6.

### Step 3 — Rewrite CLAUDE.md in the staged copy

This is the critical step. **Always overwrite** the staged CLAUDE.md, because:
- If the original was a CrystalAI personal project tracker (`_project.md`, `_meta/` references, "Status: planning", "TBD" sections), it's useless to the recipient.
- If the original was already a good AI brief, a freshly written one from the template with current info is still an improvement.
- The original on disk is never touched — only the staging copy.

Read the template at `references/CLAUDE-template.md` and fill it in using what you learned in Step 1. **Do not** treat the template as blanks to dump answers into — read every section, decide whether it applies (delete the section if not), and write in the voice of someone briefing a smart coworker.

**Sections that often need to be cut entirely**, not filled with "N/A":
- "Design system — do not invent new tokens" if the project has no distinctive visual identity (APIs, CLIs, backend services)
- "Voice / copy rules" if the project has no brand voice (utilities, dev tools)
- "Deployment" if the project is not deployed (library, tooling)

**Sections that should always be present**, even for utility projects:
- What this project is
- Tech stack
- Getting started
- Project structure
- Current state (done vs. pending)
- Hard rules
- Closing paragraph addressed to the receiving AI

For concrete examples of a well-filled template, see `examples/alibi-website-CLAUDE.md` — that's the reference implementation from the first time this skill was used. Match its level of specificity.

Write the final CLAUDE.md to `$STAGING/{{PROJECT_NAME}}/CLAUDE.md`.

### Step 4 — Ensure README.md exists

If the staged project has a `README.md`, leave it alone.

If it doesn't, generate a minimal one:

```markdown
# {{Project Name}}

{{one-sentence description}}

## Setup

```bash
{{install command}}
{{dev command}}
```

See `CLAUDE.md` for full project context, architecture, and pending work.
```

README.md is for humans who don't use AI assistants. CLAUDE.md is for AI assistants (and humans who appreciate structured context).

### Step 5 — Zip the staged copy

```bash
rm -f "$HOME/Downloads/{{PROJECT_NAME}}.zip"
cd "$STAGING" && zip -rq "$HOME/Downloads/{{PROJECT_NAME}}.zip" "{{PROJECT_NAME}}"
```

Then verify the contents:

```bash
unzip -l "$HOME/Downloads/{{PROJECT_NAME}}.zip" | tail -30
```

Check that `CLAUDE.md` and `README.md` are present at the expected paths, and that no `node_modules/` or `dist/` leaked through. If you see any exclusion misses, re-run step 2 with tighter filters.

### Step 6 — Clean up staging

```bash
rm -rf "$STAGING"
```

### Step 7 — (Optional) Draft handoff email

Only if the user asked to send it to someone. Never send automatically — always leave the draft visible in Apple Mail for the user to review and send.

#### Recipient lookup

If the user gave you a first name only (e.g. "send to Tristan"), look up the person file:

```bash
find "/Users/Austin/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi/Areas/People" \
  -type f -name "*.md" -iname "*{{NAME}}*"
```

Read the matching `.md` file and pull `email:` from the frontmatter. Check the `aliases:` field too — "Tristan" matches "Tristen Maetzold" via `aliases: [Tristan]`. If nothing matches, ask the user for the email directly.

#### Compose and send the draft

Read `references/email-draft-template.applescript` for the template. Fill in the placeholders (`{{SUBJECT}}`, `{{BODY}}`, `{{SENDER}}`, `{{RECIPIENT}}`, `{{ATTACHMENT_PATH}}`) and write the result to a temp `.applescript` file. The body should flag:

- The setup command (`npm install && npm run dev`, or equivalent)
- That there's a `CLAUDE.md` written as an AI brief — dropping the repo into Claude Code will orient it automatically
- Any known activation steps (webhooks that need confirmation, env vars that need setting, accounts that need creating)
- Any placeholders still in the code (missing logo, missing real API keys, etc.)
- A friendly "reach out with questions" close

Keep it short — 6-10 lines of body. Let the CLAUDE.md do the heavy lifting.

Run it:

```bash
osascript /tmp/handoff-draft-<uid>.applescript && rm /tmp/handoff-draft-<uid>.applescript
```

The draft opens in Apple Mail, visible to the user. **Do not send it** — the user reviews and clicks send.

### Step 8 — Report

Tell the user:

- Where the zip lives (`~/Downloads/<project-name>.zip`)
- Size and file count
- Key sections the CLAUDE.md covers (don't dump the whole template — one-line summary of what's in it)
- If an email draft was created: that it's open in Apple Mail, who it's to, and what the subject is
- Anything the user needs to do manually (e.g., "before this form works, the inbox X has to exist")

---

## Reference files

- `references/CLAUDE-template.md` — the fillable AI operating manual skeleton. Read this before writing the staged CLAUDE.md.
- `references/default-exclusions.txt` — rsync-compatible exclusion list. Pass to `rsync --exclude-from=`.
- `references/email-draft-template.applescript` — parameterized AppleScript for the Apple Mail draft.
- `examples/alibi-website-CLAUDE.md` — a real, filled-in CLAUDE.md from the first handoff. Use as a "what good looks like" reference.

---

## Edge cases

**The user's project has no `package.json` / stack metadata file.**
Read the source tree to guess the stack, then ask the user to confirm. Don't invent.

**The project has multiple apps in a monorepo.**
Ask whether to handoff the whole monorepo or a single app. If a single app, treat the app directory as the project root.

**The existing CLAUDE.md is already a proper AI operating manual.**
Still overwrite in staging. Use the existing version as source material when filling the template — it's faster than re-deriving the information.

**The project directory name has spaces.**
Quote everything consistently. Better: create the staged copy with a dash-separated name derived from the original. The zip filename should also be dash-separated, lowercase.

**The recipient lookup returns multiple matches.**
List them and ask the user which one.

**The recipient lookup returns nothing.**
Ask the user for the email directly. Don't block on this — the zip is still useful without the email.

**Apple Mail isn't running when the AppleScript runs.**
AppleScript will launch Mail automatically. If it still fails (e.g., the account isn't configured), report the error and leave the zip in place — the user can attach manually.

**The zip is going to be large (> 50MB).**
Check whether something slipped past the exclusion list first. Common leaks: committed `.venv/`, large `public/` assets, committed build artifacts. Re-stage with tighter filters. If the large files are legitimate (real assets the recipient needs), tell the user the size and suggest an upload service (Drive, Dropbox) instead of email attachment.

**The user already ran this skill on the same project and wants to re-send.**
Just run the whole flow again. The old zip gets overwritten. If they tweaked something small and want to avoid re-reading everything, they can point you at the previous CLAUDE.md.

---

## Hard rules

1. **Never modify the original project.** All edits happen in `/tmp/<staging>/`. If the rsync fails or the script crashes before cleanup, the original is still safe — but verify before reporting "done."
2. **Always overwrite `CLAUDE.md` in the staged copy.** Don't try to merge or append — generate fresh from the template.
3. **Never auto-send the email.** Draft only. The user reviews and sends.
4. **Never commit anything to the CrystalAI repo (or any other repo) as part of this skill.** The output is a zip and an email draft — that's it.
5. **Don't strip files that look like source code** just because they match an exclusion glob. When in doubt, check whether the file is a dependency artifact vs. a source file. The exclusion list is designed to be safe, but new frameworks emerge and the list may be stale.
