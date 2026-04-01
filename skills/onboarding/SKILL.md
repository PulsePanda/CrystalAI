---
name: onboard
description: First-run setup wizard for CrystalAI. Detects the user's environment, conducts a conversational interview to learn preferences, generates configuration files, validates integrations, and guides the user through creating their first skill. Run this once after installing CrystalAI. Safe to re-run — updates existing config without overwriting manual edits.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# CrystalAI Onboarding

Bootstrap a new user's CrystalAI setup through environment detection, a conversational interview, config generation, validation, and a guided first-skill moment.

## Arguments

- `/onboard` — Full onboarding (all phases)
- `/onboard reset` — Re-run the interview and regenerate config (preserves session logs and memory)

---

## Execution Model

This skill is **interactive**. It alternates between automated detection steps and conversational questions. Do NOT rush through the interview as a checklist. Ask one topic at a time, adapt follow-ups based on answers, and keep the tone of a knowledgeable friend helping someone set up their workspace.

If this is a re-run (existing config detected in Phase 1), acknowledge what's already configured, ask what they want to change, and skip phases that don't need updating.

---

## Phase 1: Environment Detection (~2 min, automated)

Run all detection steps in parallel. Do not ask the user for any of this — detect it.

### 1a: Operating System and Shell

```bash
uname -s   # Darwin, Linux, MINGW64_NT-*, CYGWIN_NT-*, etc.
uname -m   # arm64, x86_64, etc.
echo $SHELL  # or on Windows: echo %COMSPEC%
```

Map results:
- `Darwin` → macOS
- `Linux` → Linux (check for WSL: `grep -qi microsoft /proc/version 2>/dev/null`)
- `MINGW*` / `CYGWIN*` → Windows (Git Bash / Cygwin)

Also detect shell: zsh, bash, fish, PowerShell, cmd.

### 1b: Installed Development Tools

Check for each tool's presence and version. Use `which` (or `where` on Windows cmd).

| Tool | Check command |
|------|--------------|
| git | `git --version` |
| node | `node --version` |
| python | `python3 --version` or `python --version` |
| uv | `uv --version` |
| code (VS Code) | `code --version` |
| cursor | `cursor --version` |

Record what's present. Don't warn about missing tools unless they're needed later. **Do NOT attempt to install missing tools.** Detection only — report what's there and what isn't.

### 1c: Existing CrystalAI Configuration

Check for existing setup:

```bash
ls ~/.claude/crystal.local.yaml 2>/dev/null
ls ~/.claude/state/behavioral/communication.md 2>/dev/null
ls ~/.claude/state/sessions/ 2>/dev/null
```

If `crystal.local.yaml` exists, read it. This is a re-run — note existing values as defaults for the interview.

### 1d: Common Applications

Detect installed apps. Method varies by OS:

**macOS:**
```bash
# Check for apps in /Applications or ~/Applications
ls /Applications/Obsidian.app 2>/dev/null
ls /Applications/Visual\ Studio\ Code.app 2>/dev/null
ls "/Applications/Things3.app" 2>/dev/null
ls /Applications/Todoist.app 2>/dev/null
ls /Applications/Notion.app 2>/dev/null
mdfind "kMDItemCFBundleIdentifier == 'com.apple.Notes'" 2>/dev/null  # Apple Notes (always present)
mdfind "kMDItemCFBundleIdentifier == 'com.apple.iCal'" 2>/dev/null   # Apple Calendar
mdfind "kMDItemCFBundleIdentifier == 'com.apple.mail'" 2>/dev/null   # Apple Mail
```

**Linux:**
```bash
which obsidian 2>/dev/null
which code 2>/dev/null
# Check flatpak/snap if not found via which
flatpak list 2>/dev/null | grep -i obsidian
```

**Windows (Git Bash):**
```bash
ls "/c/Program Files/Obsidian" 2>/dev/null
ls "$LOCALAPPDATA/Programs/obsidian" 2>/dev/null
```

### 1e: Permissions Setup

Check if `~/.claude/settings.json` exists. If it does NOT, copy the starter template:

```bash
if [ ! -f ~/.claude/settings.json ]; then
  cp ~/.claude/settings.json.template ~/.claude/settings.json 2>/dev/null
fi
```

This ships a conservative permissions config that auto-allows safe read operations and CrystalAI file edits while blocking dangerous commands. It replaces the need for bypass mode and significantly reduces permission prompt noise for new users.

If `settings.json` already exists, leave it alone — the user may have customized it.

### 1f: Report Findings

Present a concise summary:

```
Environment detected:
  OS:       macOS 14.2 (arm64)
  Shell:    zsh
  Tools:    git 2.43, node 20.11, python 3.12, uv 0.1.24
  Editor:   VS Code
  Apps:     Obsidian, Things3, Apple Mail, Apple Calendar
  Existing: No prior CrystalAI config found
```

Then transition: "Now I need to learn a few things about how you work. This takes about 5-10 minutes."

---

## Phase 2: Interview (~5-10 min, conversational)

Ask these topics **one at a time**. After each answer, acknowledge briefly (no filler — just confirm what you understood) and move to the next. Adapt follow-up questions based on what they say.

**Do NOT present this as a numbered list of questions.** It should feel like a conversation, not a form.

### Store answers internally as you go. You'll use them in Phase 3.

### Topic 1: Identity

"What's your name, and what do you do? (Developer, designer, business owner, student, content creator — whatever describes your day-to-day.)"

Capture:
- `user_name` — their name
- `user_role` — what they do (free text, don't force categories)

### Topic 2: Communication Style

"How do you want me to talk to you? Some people want terse, technical answers. Others want more explanation. Some like casual, some like formal. Any strong preferences?"

Probe if needed:
- Verbose or terse?
- Formal or casual?
- Emojis or no emojis?
- Should I explain my reasoning or just give the answer?
- How much should I check in vs just do things?

Capture:
- `comm_verbosity` — terse / balanced / detailed
- `comm_tone` — casual / professional / formal
- `comm_emojis` — yes / no / occasionally
- `comm_autonomy` — act autonomously / check in at decision points / always ask first

### Topic 3: Notes

"Where do you keep notes and documents?"

Adapt based on Phase 1 detection:
- If Obsidian detected: "I see Obsidian is installed. Do you have a vault you'd like me to work with? What's the path?"
- If Notion detected: "I see Notion. Do you want me to reference Notion docs, or do you keep local notes too?"
- If nothing detected: "Do you use a note-taking app, or are you starting fresh?"

Capture:
- `notes_app` — obsidian / notion / apple-notes / plain-files / none
- `vault_path` — if Obsidian (validate the path exists)
- `notes_details` — any specifics about their setup

### Topic 4: Task Management

"How do you track tasks and to-dos?"

Adapt based on detection:
- If Things3 detected (macOS): "I see Things3. Want me to create and manage tasks there?"
- If Todoist detected: "I see Todoist. Should I use it for task management?"
- If nothing: "Do you use a task manager, or are you more of a pen-and-paper person?"

Capture:
- `task_app` — things3 / todoist / microsoft-todo / linear / pen-and-paper / none
- `task_details` — any specifics (projects structure, areas, etc.)

### Topic 5: Email

"Do you want me to help with email? If so, what email client or service do you use, and how many accounts?"

Adapt based on detection:
- If Apple Mail detected (macOS): "I see Apple Mail. Want me to help triage and draft emails there?"
- If Gmail MCP is available: "Gmail integration is available. Want to set that up?"

Capture:
- `email_enabled` — yes / no / maybe later
- `email_client` — apple-mail / gmail / outlook / none
- `email_accounts` — list of accounts (address + context like "work" or "personal")

If they say no or maybe later, move on. Don't push.

### Topic 6: Calendar

"Do you use a calendar app? Which one?"

Adapt based on detection:
- If Apple Calendar detected: "I see Apple Calendar. Want me to check your schedule when planning your day?"
- If Google Calendar MCP available: "Google Calendar integration is available."

If yes:
- "Which calendars should I pay attention to? Most people have more calendars than they care about — I only want to show you the ones that matter."

Capture:
- `calendar_enabled` — yes / no
- `calendar_app` — apple-calendar / google-calendar / outlook / none
- `calendar_include` — list of calendar names to include
- `calendar_exclude` — list to explicitly ignore (optional)

### Topic 7: Privacy Boundaries

"Is there anything I should never access or modify? Specific directories, apps, files — anything off-limits."

Also ask: "Any types of content I should avoid generating? Things you'd rather do yourself?"

Capture:
- `privacy_no_access` — list of paths/apps that are off-limits
- `privacy_no_generate` — types of content to avoid
- `privacy_notes` — any other boundary rules

### Topic 8: Automation Seed

"Last one: What's the most repetitive or annoying part of your day? The thing you wish just happened automatically."

This is both practical (it becomes their first skill in Phase 5) and diagnostic (it reveals their workflow pain points).

Capture:
- `automation_idea` — their answer, verbatim
- `automation_context` — any follow-up details

---

## Phase 3: Configuration Generation (~2 min, automated)

Generate all config files based on interview answers and environment detection. Run file writes in parallel where possible.

**Before writing any file, check if it already exists.** If it does, merge new values with existing content rather than overwriting.

### 3a: crystal.local.yaml

Write to `~/.claude/crystal.local.yaml` using the template structure. Fill in detected and interview values:

```yaml
# CrystalAI Environment Configuration
# Generated by /onboard on YYYY-MM-DD

# --- Paths ---
vault_path: "{vault_path or empty string}"
scripts_path: "${CLAUDE_PLUGIN_ROOT}/scripts"

# --- Identity ---
user:
  name: "{user_name}"
  primary_email: "{first email account address, or empty}"

# --- Email Accounts ---
email_accounts:
  # {for each email account from interview}
  {label}:
    address: "{address}"
    context: "{context}"

# --- Calendars ---
calendars:
  include:
    # {for each calendar from interview}
    - name: "{calendar_name}"
  exclude: []

# --- Integrations ---
integrations: {}
```

Only include sections that have actual values. Leave commented examples for sections the user skipped.

### 3b: Communication Behavioral Rules

Write to `~/.claude/state/behavioral/communication.md`:

Start from the template at `~/.claude/state/behavioral/communication.md.template`. Customize the rules based on the interview:

- If they want verbose answers, modify Rule 1 accordingly
- If they like emojis, remove or modify Rule 3
- If they want more autonomy, add a rule about acting without asking
- If they specified a tone preference, add a rule for it

Add any specific communication rules they mentioned.

### 3c: User Preferences

Write to `~/.claude/state/behavioral/user-preferences.md`:

Start from the template at `~/.claude/state/behavioral/user-preferences.md.template`. Fill in:

- **Communication Style** — from Topic 2
- **Work Style** — from their role and autonomy preferences
- **Tool Preferences** — notes app, task manager, email client, editor
- **Decision Patterns** — leave as placeholder unless they mentioned specifics

Set `date-created` to today. Set `Last Updated` to today.

### 3d: Writing Style (Starter)

Write to `~/.claude/state/behavioral/writing-style.md`:

```markdown
# Behavioral Rules: Writing Style

## Rules

### 1. Match the user's voice
**Rule:** When drafting content on behalf of the user, match their tone and style. Until enough samples exist, default to clear and direct.
**Why:** The user's writing should sound like them, not like an AI.
**Override:** When the user explicitly asks for a different style.

## Observations
<!-- The teach skill will populate this as it learns the user's writing patterns. -->

**Last Updated:** {today}
```

### 3e: Integration State Files

For each integration the user confirmed, create a state file following the schema at `state/_schemas/integration.schema.md`.

**Notes app (if Obsidian):**
Write `~/.claude/state/integrations/obsidian.md`:
- Type: Local app
- Binary/Endpoint: Obsidian (file-based access, no CLI needed)
- Key Operations: Read/write markdown files in vault
- Gotchas: Vault may be in iCloud or Dropbox — path can shift

**Task manager (if Things3):**
Write `~/.claude/state/integrations/things3.md`:
- Type: MCP
- Key Operations: Create task, search tasks, complete task, view projects
- Gotchas: Requires MCP server running; macOS only

**Task manager (if Todoist):**
Write `~/.claude/state/integrations/todoist.md`:
- Type: API
- Auth location: note where API key should be stored (do NOT store the key)
- Key Operations: Create task, list tasks, complete task

**Email (if Apple Mail):**
Write `~/.claude/state/integrations/apple-mail.md`:
- Type: MCP
- Key Operations: List mailboxes, search, get emails
- Accounts: list from interview

**Email (if Gmail):**
Write `~/.claude/state/integrations/gmail.md`:
- Type: MCP
- Key Operations: Search, read, draft, list labels

**Calendar (if Apple Calendar):**
Write `~/.claude/state/integrations/apple-calendar.md`:
- Type: MCP
- Key Operations: List events, create event
- Include list of approved calendar names

**Calendar (if Google Calendar):**
Write `~/.claude/state/integrations/google-calendar.md`:
- Type: MCP or API
- Key Operations: List events, create event
- Include list of approved calendar names

Only create files for integrations the user actually confirmed. Do not create speculative files.

### 3f: Environment State File

Write `~/.claude/state/environments/workstation.md` following `state/_schemas/environment.schema.md`:

```markdown
# Environment: Workstation

## Identity
| Field | Value |
|-------|-------|
| Host | {hostname from `hostname`} |
| SSH alias | localhost |
| User | {whoami} |
| OS | {detected OS + version} |

## Purpose
Primary development machine. This is where CrystalAI runs.

## Key Paths
| Location | Path |
|----------|------|
| CrystalAI root | ~/.claude/ |
| Vault | {vault_path or "not configured"} |
| Scripts | ~/.claude/scripts/ |

## Services
| Service | Version | Port | Notes |
|---------|---------|------|-------|
| {for each detected tool} | {version} | — | {notes} |

## Admin Pattern
Local CLI. This is the machine you're sitting at.

## Current State
| Field | Value |
|-------|-------|
| Status | Active |
| Last verified | {today} |
| Notes | Initial setup via /onboard |
```

### 3g: Update CLAUDE.md

Read `~/.claude/CLAUDE.md`. Fill in any `<!-- CUSTOMIZE -->` placeholder sections with relevant information from the interview. Specifically:

- If they mentioned universal rules or preferences not covered by the defaults, add them under "Universal Behavioral Rules"
- If they have a plugin/business layer, add it under "Plugins"

**Do NOT remove any existing rules or structure.** Only add to the customize sections.

---

## Phase 4: Validation (~1 min, automated)

Test each configured integration to verify it actually works. Run tests in parallel.

**IMPORTANT: Do NOT install, download, or configure any tools, packages, MCP servers, or dependencies during onboarding.** This skill detects and validates only. If something is missing or fails validation, report the issue with a specific fix instruction and move on. Tool installation happens separately — either via the install script, the instructor, or the user after the session. Never run `npm install`, `pip install`, `brew install`, or any package manager commands as part of onboarding.

### 4a: File System Access

```bash
# Can we read the vault?
ls "{vault_path}" 2>/dev/null && echo "OK" || echo "FAIL"

# Can we write to state?
touch ~/.claude/state/.onboard-test && rm ~/.claude/state/.onboard-test && echo "OK" || echo "FAIL"
```

### 4b: Integration Tests

For each configured integration, run a lightweight smoke test:

| Integration | Test |
|-------------|------|
| Obsidian vault | `ls "{vault_path}"` — can we read the directory? |
| Things3 | Attempt to use the Things3 MCP tool to list projects (read-only) |
| Apple Mail | Attempt to list mailboxes via MCP (read-only) |
| Apple Calendar | Attempt to list calendars via MCP (read-only) |
| Gmail | Attempt to get profile via MCP (read-only) |
| Google Calendar | Attempt to list calendars via MCP (read-only) |

### 4c: Report Results

```
Validation results:
  File system:     OK — vault readable, state writable
  Things3:         OK — 12 projects found
  Apple Calendar:  OK — 8 calendars found
  Apple Mail:      FAIL — MCP server not configured
    → To fix: Add the apple-mail MCP server to your Claude Code config.
      See: https://github.com/user/apple-mail-mcp (or relevant link)
```

For each failure, provide a **specific, actionable fix instruction**. Don't just say "check the docs."

---

## Phase 5: Tool Installation (~5-10 min, instructor-led)

Phase 4 identified which integrations are working and which need setup. This phase hands off to the instructor for tool installation — many tools (GWS, MCP servers, auth flows) require navigating external UIs, managing credentials, and troubleshooting in ways that the AI cannot reliably guide.

### 5a: Identify What's Needed

Review Phase 4 validation results and the user's Topic 8 answer (their biggest daily annoyance / first skill idea). Present a prioritized list:

```
Tools needed before we can build your first skill:
  1. [tool] — needed for [pain point feature]
  2. [tool] — needed for [core workflow feature]

Also recommended (can be set up later):
  3. [tool] — for [feature]
```

Prioritize:
1. **Tools needed for the first skill** — highest priority. If their pain point is morning calendar notifications, they need calendar access working before we build the skill.
2. **Tools needed for core daily workflow** — email, calendar, task manager (whichever they mentioned in the interview).
3. **Everything else** — can be set up after the session.

### 5b: Hand Off to Instructor

**Stop and wait.** Say:

"These tools need to be set up before we can build your first skill. [Instructor name] is going to walk you through this part — I'll be here when you're ready to continue."

**Do NOT attempt to guide the user through tool installation yourself.** Tool setup often involves:
- External web UIs (Google Cloud Console, OAuth consent screens, etc.)
- Credential file management that requires human judgment
- Platform-specific troubleshooting that changes frequently
- Auth flows that the AI cannot see or interact with

The instructor handles this. Your job is to clearly identify what needs to be installed and to validate it once it's done.

> **Future:** A dedicated guided setup skill (`/setup`) is planned that will use deep research to build verified, up-to-date step-by-step guides for each tool — and can either walk the user through interactively or execute the setup autonomously. Once that skill exists, Phase 5 can invoke it instead of handing off to the instructor. Until then, this is a human-led step.

### 5c: Validate After Installation

Once the instructor signals that tools are set up, re-run the relevant Phase 4 validation tests:

"Let me verify everything is working..."

Re-run the smoke tests for each newly installed tool. Report results.

If everything passes: "All good. Let's build your first skill."

If something still fails: Report the specific failure to the instructor. Let them fix it. Re-validate when they're ready.

---

## Phase 6: First Skill Moment (~3 min, guided)

This phase is both functional and pedagogical. The user creates a real skill while learning the skill creation pattern. All tools needed for their skill should be validated and working from Phase 5.

### 6a: Connect to Their Pain Point

Reference their answer from Topic 8:

"You mentioned that [their automation annoyance] is a pain point. Let's build a tiny skill for that right now — it'll take about 3 minutes and you'll learn how the skill system works."

### 6b: Design the Skill Together

Walk them through the thinking:

1. "What would the trigger be? When you say `/[something]`, what word feels natural?"
2. "What should it do, step by step? Walk me through what you do manually today."
3. "What tools does it need? (Reading files, writing files, running commands, calling an API?)"

### 6c: Generate the Skill

Based on their answers, write a SKILL.md for their first skill:

- Location: `~/.claude/skills/{skill-name}/SKILL.md`
- Follow the same frontmatter format as other skills (name, description, version, allowed-tools)
- Keep it simple — 1-3 steps maximum
- Include clear error handling

### 6d: Test It

"Try running `/{skill-name}` right now. Let's see if it works."

If it works: "That's the pattern. Every skill is just a SKILL.md file that tells me what to do when you say a trigger word. You can create more anytime."

If it fails: Debug together. Fix the issue. This is a teaching moment — show them how skills are just instructions that can be edited.

---

## Phase 7: Wrap-Up

### 7a: Configuration Summary

Present a clean summary of everything that was configured:

```
Setup complete. Here's what's configured:

Identity:       {name} ({role})
Notes:          {app} — {path or "configured"}
Tasks:          {app} — {status}
Email:          {app} — {N accounts}
Calendar:       {app} — {N calendars tracked}
First skill:    /{skill-name}

Config files created:
  ~/.claude/crystal.local.yaml
  ~/.claude/state/behavioral/communication.md
  ~/.claude/state/behavioral/user-preferences.md
  ~/.claude/state/behavioral/writing-style.md
  ~/.claude/state/environments/workstation.md
  ~/.claude/state/integrations/{each integration}.md
  ~/.claude/skills/{first-skill}/SKILL.md
```

### 7b: Quick Reference Card

```
What you can do now:

  /resume       — Start a session. Loads your context, tasks, and calendar.
  /compress     — End a session. Saves a searchable log and extracts tasks.
  /{first-skill} — Your custom skill.

Coming soon (as you use the system):
  /write        — Draft content in your voice (learns your style over time).
  /note         — Quick capture to your notes.
  /project      — Manage project tracking.
  /feedback     — Tell me when I get something wrong (I'll remember).
```

### 7c: Next Steps

"Run `/resume` at the start of your next session to see the system in action. The more you use it, the more it learns — your preferences, your writing style, your workflows. Everything adapts."

If anything failed in Phase 4:
"A few integrations need manual setup. Here's what to do: [repeat the fix instructions from Phase 4]."

---

## Error Handling

### Phase 1 Errors
- **Command not found:** Skip that tool, note it as "not installed."
- **Permission denied:** Note the issue, continue detection. Report in Phase 1e.
- **WSL detection fails:** Default to Linux behavior, note uncertainty.

### Phase 2 Errors
- **User wants to skip a topic:** Respect it. Record as "not configured" and move on.
- **User gives ambiguous answers:** Ask one clarifying follow-up, then move on with best interpretation.
- **User wants to stop mid-interview:** Save progress to a temporary file (`~/.claude/state/.onboard-progress.json`). On next `/onboard` run, detect it and offer to resume.

### Phase 3 Errors
- **File write fails:** Report the error with the specific path and permission issue. Suggest `chmod` or `mkdir -p` as appropriate.
- **Template not found:** Fall back to inline generation using the schema definitions.
- **Existing config conflict:** Show the diff between existing and proposed values. Ask which to keep.

### Phase 4 Errors
- **MCP server not running:** Provide the specific setup instructions for that MCP server.
- **Vault path doesn't exist:** Ask the user to verify the path. Common issue: iCloud paths with spaces or `~` expansion.
- **Tool not responding:** Note it as "needs manual setup" and provide the fix steps.

### Phase 5 Errors (Tool Installation)
- **Tool install fails:** Note it for post-session follow-up. Don't spend more than 5 minutes on any single tool — move on and come back later.
- **Missing credentials:** The instructor should have these ready. If not, skip that tool and adjust the first skill plan.
- **Auth flow fails:** Try once, note the error, move on. Auth issues are often transient or need the instructor's GCP project access.

### Phase 6 Errors (First Skill)
- **User doesn't want to create a skill:** Skip Phase 6 entirely. No pressure.
- **Skill creation fails:** Debug together. The teaching is more valuable than the skill.

### General
- **Re-run safety:** Every file write checks for existing content first. Merge, don't overwrite. If in doubt, ask.
- **Cross-platform:** All bash commands must work on macOS, Linux, and Git Bash on Windows. Use `2>/dev/null` liberally. Test for tool existence before using tool-specific flags.
