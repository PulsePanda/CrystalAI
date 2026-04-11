---
name: onboard
description: First-run setup wizard for CrystalAI. Detects the user's environment, conducts a conversational interview to learn preferences, generates configuration files, validates integrations, and guides the user through creating their first skill. Run this once after installing CrystalAI. Safe to re-run — updates existing config without overwriting manual edits.
version: 1.1.0
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

Run all detection steps in parallel. Do not ask the user for any of this — detect it. **Do NOT print anything to the user during Phase 1.** Run all detection silently and proceed directly to Phase 2.

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

Also detect shell: zsh, bash, fish, PowerShell, cmd. Store OS type in `detected_os` (macos / linux / windows) for use in later phases.

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

Record what's present. Don't warn about missing tools unless they're needed later. **Do NOT attempt to install missing tools.** Detection only.

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

### 1f: Silent Completion

All detection is now complete. Store all findings internally. Do NOT output any summary, report, or status message. Proceed immediately and silently to Phase 2, beginning with the first question.

---

## Phase 2: Interview (~5-10 min, conversational)

Ask these topics **one at a time**. After each answer, acknowledge briefly (no filler — just confirm what you understood) and move to the next. Adapt follow-up questions based on what they say.

**Do NOT present this as a numbered list of questions.** It should feel like a conversation, not a form.

### Store answers internally as you go. You'll use them in Phase 3.

### Topic 1: Identity

"What's your name, and what do you do? (Developer, designer, business owner, student, content creator — whatever describes your day-to-day.)"

After they answer, respond: "Nice to meet you, [name]. My name is Crystal, and I am your personal AI assistant."

Capture:
- `user_name` — their name
- `user_role` — what they do (free text, don't force categories)

### Topic 2: Communication Style

Ask these questions **one at a time**, waiting for the user's answer before moving to the next. Do NOT combine them into a single paragraph or run-on question. Do NOT dump the whole list at once. Each question is its own turn in the conversation.

Start with the opening, wait for the answer, acknowledge briefly, then ask the next one:

1. Opening: "How do you want me to talk to you? Some people want short, direct answers. Others want more explanation. What feels right to you?"

2. Then: "Formal or more casual?"

3. Then: "Do you want me to explain my reasoning, or just give you the answer?"

4. Then: "Emojis — yes, no, or doesn't matter?"

5. Then: "When I'm working on something, should I just do it and tell you when it's done, or check in with you along the way?"

Skip any follow-up the user has already answered in an earlier response. The goal is a conversation, not an interrogation — but each question gets its own moment.

Capture:
- `comm_verbosity` — terse / balanced / detailed
- `comm_tone` — casual / professional / formal
- `comm_emojis` — yes / no / occasionally
- `comm_autonomy` — act autonomously / check in at decision points / always ask first

### Skill Moment: /feedback

After capturing their communication preferences, say:

"If I ever get your style wrong, just tell me. The feedback skill routes any correction automatically — you'll never have to repeat yourself."

Then move on to the next topic.

### Topic 3: Notes

**Internal:** `vault_path` always defaults to `~/.claude/vault`. This is the built-in inbox — it is ALWAYS on, ALWAYS used, and is never replaced by the user's notes app. If the user has their own notes app, that app is pointed to IN ADDITION — never INSTEAD. Do NOT mention the vault, the vault folder, `~/.claude/vault`, or any internal path to the user at any point in this topic.

**Ask the question — platform-aware.** Check `detected_os`:

- **If `detected_os == macos` or `linux`:** "Do you use a notes app — something like Obsidian, Notion, or Apple Notes? If you do, I can point notes at it too so things land where you already look."
- **If `detected_os == windows`:** "Do you use a notes app — something like Obsidian, Notion, or just plain text files? If you do, I can point notes at it too so things land where you already look." (Do NOT mention Apple Notes on Windows.)

Adapt follow-up based on their answer:

- **If they use a notes app:** "What's the path to your notes folder?" Capture it as the `external_notes_path`. Frame it as an ADDITION — their notes app is now a second destination, not a replacement. Example acknowledgment: "Got it — I'll point notes at your [app] folder so new notes show up there alongside everything else."
- **If they don't use a notes app** (pen and paper, nothing digital, etc.): Do NOT mention the vault, folders, or paths. Explain the inbox using this exact wording:

  > "There's a built-in inbox you can throw anything into — meeting notes, ideas, things you want to remember. To add something, type `/note`. It opens in your text editor so you can write freely. Later, `/process-inbox` organizes everything into the right place."

After capturing their notes app answer, ask about their preferred editor for opening notes. Use the detection results from Phase 1 to tailor the question:

- **If both Obsidian and VS Code were detected:** "I see you have both Obsidian and VS Code installed. Would you like me to open notes in Obsidian, or would you prefer VS Code?"
- **If only Obsidian was detected:** "I see you have Obsidian installed. Would you like me to open notes in Obsidian, or would you prefer something else?"
- **If only VS Code was detected (but not Obsidian):** "I see you have VS Code installed. Would you like me to open notes there, or use your system default?"
- **If neither was detected:** "I'll open notes in your system's default text editor. That's usually Notepad on Windows or TextEdit on Mac — totally fine if you'd rather use something else."

Capture:
- `notes_app` — obsidian / notion / apple-notes / plain-files / none
- `notes_editor` — obsidian / vscode / system
- `vault_path` — always `~/.claude/vault` (the built-in vault; never changes)
- `external_notes_path` — their notes app folder path, if they have one (may be empty)
- `notes_details` — any specifics about their setup

### Skill Moment: /note (run for ALL users)

Run this demo for every user, regardless of whether they have a notes app. Use the built-in inbox (`~/.claude/vault/+Inbox/`).

Actually create a capture file in `~/.claude/vault/+Inbox/` with content like:

```markdown
---
type: capture
date: {today}
time: "{now}"
processed: false
---

CrystalAI onboarding — this note was created by /note to show how quick captures work. Delete me anytime.
```

Do this silently. Then say: "I just dropped a quick note in your inbox to show you how `/note` works. One command, it lands in your inbox, and you can organize it whenever you want."

Do NOT mention the vault, vault path, folder name, or any internal path to the user. The word "vault" must never appear in anything you say to the user.

<!-- TODO: /note must actually open the default text editor for the user visually (not just create the file silently). Verify the /note skill implementation does this. If it does not, fix the /note skill so it opens the system's default text editor after creating the file (e.g., `open` on macOS, `xdg-open` on Linux, `start` on Windows). Until that fix is in place, the demo here creates the file silently — which works but misses the "watch this" visual moment. -->

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
- If Gmail MCP is available: "I can connect to Gmail if you'd like. Want to set that up?"

Capture:
- `email_enabled` — yes / no / maybe later
- `email_client` — apple-mail / gmail / outlook / none
- `email_accounts` — list of accounts (address + context like "work" or "personal")

If they say no or maybe later, move on. Don't push.

### Topic 6: Calendar

"Do you use a calendar app? Which one?"

Adapt based on detection:
- If Apple Calendar detected: "I see Apple Calendar. Want me to check your schedule when planning your day?"
- If Google Calendar MCP available: "I can connect to Google Calendar if you'd like."

If yes:
- "Which calendars should I pay attention to? Most people have more calendars than they care about — I only want to show you the ones that matter."

Capture:
- `calendar_enabled` — yes / no
- `calendar_app` — apple-calendar / google-calendar / outlook / none
- `calendar_include` — list of calendar names to include
- `calendar_exclude` — list to explicitly ignore (optional)

### Topic 7: Red Lines

"Is there anything I should never access or modify? Specific apps, files, folders — anything off-limits."

Also ask: "Any types of content I should avoid generating? Things you'd rather handle yourself?"

Capture:
- `redlines_no_access` — list of paths/apps that are off-limits
- `redlines_no_generate` — types of content to avoid
- `redlines_notes` — any other boundary rules

### Topic 8: Your First Skill

"Last one: What's the most repetitive or annoying part of your day? The thing you wish just happened automatically."

This is both practical (it becomes their first skill in Phase 6) and diagnostic (it reveals their workflow pain points).

Capture:
- `automation_idea` — their answer, verbatim
- `automation_context` — any follow-up details

### Skill Moment: /grill-me (teaser)

After they describe their idea, briefly tease the grill-me skill as a natural follow-up:

"That's a solid idea. If you ever want me to stress-test a plan before you build it — poke holes, ask the hard questions — just say `/grill-me`. I'll interrogate you until the plan is bulletproof. We won't do it now, but keep it in your back pocket."

One sentence. Plant the seed and move on.

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
vault_path: "~/.claude/vault"  # Built-in vault — always present
external_notes_path: "{external_notes_path or empty}"  # Their notes app path, if configured
notes_editor: "{notes_editor}"  # obsidian / vscode / system
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
| Vault | ~/.claude/vault |
| External notes | {external_notes_path or "not configured"} |
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

### 3g: Personalize Personality and Communication Rules

Read `~/.claude/soul.md`. It ships with `<!-- CUSTOMIZE -->` placeholder sections. Fill them in using interview answers.

Say to the user (user-facing): "Now I'm building my personality around how you work — how direct you like me to be, what kind of help you want, and how we'll work together best."

Internal instructions (do NOT surface these file names or paths to the user):
- **Identity section:** Replace the placeholder with a description of the user and their work context (from Topic 1 — name, role).
- **Relationship section:** Choose the relationship model that best fits their autonomy preference (from Topic 2):
  - `comm_autonomy: act autonomously` → Peer/colleague model
  - `comm_autonomy: check in at decision points` → Balanced model (customize)
  - `comm_autonomy: always ask first` → Executor model (defer, confirm, execute)
- **Personality section:** Generate personality traits from their communication preferences (verbosity, tone, emoji stance).
- **Values section:** The core values (honesty, no cover-ups, verify before claiming) are pre-populated and universal — do not change them. Only add to the `<!-- CUSTOMIZE -->` block at the end if the user mentioned specific values during the interview.

**Do NOT remove any pre-populated values or sections.** Only fill in the customize placeholders.

### 3h: Update Main Configuration

Read `~/.claude/CLAUDE.md`. Fill in any `<!-- CUSTOMIZE -->` placeholder sections with relevant information from the interview. Specifically:

- If they mentioned universal rules or preferences not covered by the defaults, add them under "Universal Behavioral Rules"
- If they have a plugin/business layer, add it under "Plugins"

**Do NOT remove any existing rules or structure.** Only add to the customize sections.

Do NOT mention CLAUDE.md or any file name to the user during this step.

### Skill Moment: /compress (live demo)

After all config files are written, demonstrate `/compress` by running a lightweight version of it on this onboarding session itself.

Say: "I've saved what I learned about you and updated how I think and communicate. Going forward, I'll remember your preferences, your tools, and how you like to work — even after we close this conversation.

Two habits worth building now: at the start of each day, type `/resume` — I'll load everything and pick up where we left off. At the end of a session, type `/compress` — I'll save what happened so nothing gets lost."

Then internally: run the compress skill's core steps — generate a session log summarizing the onboarding (topics covered, integrations configured) and save it to `~/.claude/state/sessions/`. Use today's date and "onboarding" as the topic. Do NOT list the file paths or session log location to the user.

This is the single most important skill demo in onboarding. It shows the user that CrystalAI has persistent memory — the thing that makes it feel fundamentally different from vanilla Claude.

---

## Phase 4: Validation (~1 min, automated)

Test each configured integration to verify it actually works. Run tests in parallel. **Run all validation silently — do not narrate the tests as they run.** Only output the final results once all tests complete.

**IMPORTANT: Do NOT install, download, or configure any tools, packages, MCP servers, or dependencies during onboarding.** This skill detects and validates only. If something is missing or fails validation, report the issue with a specific fix instruction and move on. Tool installation happens separately — either via the install script, the instructor, or the user after the session. Never run `npm install`, `pip install`, `brew install`, or any package manager commands as part of onboarding.

### 4a: File System Access

```bash
# Can we read the vault? (vault_path always defaults to ~/.claude/vault)
ls "~/.claude/vault" 2>/dev/null && echo "OK" || echo "FAIL"

# Can we write to state?
touch ~/.claude/state/.onboard-test && rm ~/.claude/state/.onboard-test && echo "OK" || echo "FAIL"
```

### 4b: Integration Tests

For each configured integration, run a lightweight smoke test:

| Integration | Test |
|-------------|------|
| Vault | `ls ~/.claude/vault` — can we read the directory? (always validated — built-in vault ships with the repo) |
| Things3 | Attempt to use the Things3 MCP tool to list projects (read-only) |
| Apple Mail | Attempt to list mailboxes via MCP (read-only) |
| Apple Calendar | Attempt to list calendars via MCP (read-only) |
| Gmail | Attempt to get profile via MCP (read-only) |
| Google Calendar | Attempt to list calendars via MCP (read-only) |

### 4c: Report Results

Output only the final results block. Use plain English — no internal file names or paths in the results shown to the user:

```
Here's what's connected and working:

  Notes inbox:     Ready
  Things3:         Connected — 12 projects found
  Apple Calendar:  Connected — 8 calendars found
  Apple Mail:      Needs setup
    → To fix: Apple Mail needs to be connected before I can read or send from it.
      See: https://github.com/user/apple-mail-mcp (or relevant link)
```

For each failure, provide a **specific, actionable fix instruction**. Don't just say "check the docs."

---

## Phase 5: Tool Installation (~5-10 min, mixed AI + instructor)

Phase 4 identified which integrations are working and which need setup. Some of this phase the AI can guide directly — notably Google Workspace auth via `crystal-auth`. Some still needs the instructor — MCP servers, platform-specific auth flows, anything that requires navigating external UIs the AI cannot see.

### 5a: Identify What's Needed

Review Phase 4 validation results and the user's Topic 8 answer (their biggest daily annoyance / first skill idea). Present a prioritized list in plain language:

```
Before we can build your first skill, a couple of things need to be set up:
  1. [tool] — needed for [pain point feature]
  2. [tool] — needed for [core workflow feature]

These can be set up later if you prefer:
  3. [tool] — for [feature]
```

Prioritize:
1. **Tools needed for the first skill** — highest priority.
2. **Tools needed for core daily workflow** — email, calendar, task manager (whichever they mentioned in the interview).
3. **Everything else** — can be set up after the session.

### 5b: Google Workspace via crystal-auth (AI-led)

If the user needs Gmail, Google Calendar, Google Drive, or anything else the `gws` CLI wraps, you can walk them through this directly. The auth server at `auth.buildcrystal.ai` handles the OAuth client_secret on the server side — the student never touches a GCP console, never creates an OAuth client, never downloads credentials.json.

**Pick an account label.** Ask the user what Google account they want to connect. Good labels are short, lowercase, single-word: `personal`, `work`, `school`, etc. If they have multiple accounts they want to connect (common for people with a personal Gmail plus a Google Workspace work account), run this subsection once per account.

**Run `crystal-auth login <label>`.** Ask the user to run this command in their terminal:

```bash
python3 ~/.claude/scripts/crystal-auth.py login <label>
```

(On Windows, substitute `python` for `python3` and `%USERPROFILE%\.claude\scripts\crystal-auth.py` for the path.)

**What they should see:**
1. Terminal prints "opening your browser to authorize..."
2. Their default browser opens to `accounts.google.com` with a Google sign-in page
3. They pick the account they want to connect (or sign in if they're not already)
4. A consent screen lists the scopes CrystalAI needs: Gmail, Calendar, Drive, Contacts, profile info
5. They click "Allow"

**The unverified-app warning.** The CrystalOS GCP project hasn't been through Google verification (pilot scale doesn't justify the CASA audit yet), so they'll see a "This app isn't verified" screen. Tell them this is expected — click "Advanced," then "Go to crystalos (unsafe)." The "unsafe" wording is Google's default and does not mean anything is actually unsafe; it's the standard unverified-app screen that everyone running a new OAuth app sees.

**Completion.** After they click Allow, the browser shows a success page ("You can close this tab and return to your terminal"). They close the tab. The terminal prints "logged in as '<label>'." If they see anything else — an error on the success page, a terminal timeout, a stalled browser — stop and diagnose before proceeding.

**Smoke test.** Verify the flow worked by having them run:

```bash
python3 ~/.claude/scripts/crystal-auth.py get-token <label>
```

That should print a long string starting with `ya29.` — a real Google access token. If it prints an error instead, the login did not fully complete.

**Repeat for each account they want.** Each account gets its own label and its own `crystal-auth login` call. Refresh tokens stored at `~/.config/crystal-auth/accounts/<label>/credentials.json` (mode 0600).

### 5c: Hand Off Remaining Items to Instructor

For anything that isn't Google Workspace — MCP servers, platform-specific integrations, auth flows that require external UIs — stop and hand off to the instructor:

"The rest of these tools need to be set up before we can build your first skill. [Instructor name] is going to walk you through this part — I'll be here when you're ready to continue."

**Do NOT attempt to guide the user through non-Google tool installation yourself.** Tool setup often involves:
- Platform-specific MCP server installation
- Credential file management for non-OAuth systems
- Troubleshooting that changes frequently
- Auth flows the AI cannot see or interact with

Your job for these items is to identify what's needed clearly and to validate it once the instructor is done.

> **Future:** A dedicated guided setup skill (`/setup`) is planned that will use deep research to build verified, up-to-date step-by-step guides for each tool — and can either walk the user through interactively or execute the setup autonomously. Once that skill exists, 5c can invoke it instead of handing off to the instructor. Until then, non-Google tools are a human-led step.

### 5d: Validate After Installation

Once Google Workspace is connected (5b) and the instructor signals remaining tools are set up (5c), re-run the relevant Phase 4 validation tests:

"Let me verify everything is working..."

Re-run the smoke tests for each newly installed tool. Report results in the same plain-English format as 4c.

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

If it works: "That's the pattern. Every skill is just a set of instructions that tells me what to do when you say a trigger word. You can create more anytime."

If it fails: Debug together. Fix the issue. This is a teaching moment — show them how skills are just instructions that can be edited.

### 6e: Skills Tour

After the first skill works (or after debugging it), transition naturally:

"That's the skill system — trigger word, instructions, done. You've already seen a few skills in action during setup. Here are a few more you have access to right now:"

Walk through these quickly. One sentence each, framed as "when you'd use it" — not feature descriptions:

1. **`/write`** — "Need to draft an email, a message, a post? `/write` does it in your voice. It gets better over time as `/teach` learns your style from examples you show it."

2. **`/note`** — "Need to get something out of your head? `/note` creates a quick capture in your inbox. This is a brain dump — unstructured, no goal, just capture. `/process-inbox` organizes it later."

3. **`/deep-research`** — "Need to research something thoroughly — comparing vendors, understanding a technology, analyzing a market? `/deep-research` produces a cited report, not a guess. Great for feeding a brainstorm with real data."

4. **`/grill-me`** — "Want to brainstorm or stress-test a plan before you commit? `/grill-me` interrogates you until every gap is found. This is structured ideation — goal-directed, not just dumping thoughts. Think of it as a devil's advocate on demand."

5. **`/meeting`** — "About to hop on a call? `/meeting [person] [topic]` creates a pre-filled note and opens it in your notes app. You just start typing."

6. **`/weekly`** — "At the end of the week, `/weekly` synthesizes everything into permanent memory and surfaces what's coming next week."

End with: "There are more — you'll discover them as you go. The point is: if you find yourself doing something repetitive, there's probably a skill for it. And if there isn't, we build one."

Do NOT linger. This should take under 60 seconds of reading. Move to Phase 7.

---

## Phase 7: Wrap-Up

### 7a: Configuration Summary

Present a clean summary of everything that was configured — use plain English, no file paths:

```
Setup complete. Here's what's configured:

  Your name:      {name} ({role})
  Notes:          {app or "built-in inbox"} — ready
  Tasks:          {app} — {status}
  Email:          {app} — {N accounts}
  Calendar:       {app} — {N calendars tracked}
  First skill:    /{skill-name}
```

Do NOT list config file paths, directory names, or technical file names in this summary.

### 7b: Live /resume Demo

Instead of telling them about `/resume`, show them. Say:

"Let me show you what the start of your next session looks like."

Run the `/resume` skill now. It will load the session log from the `/compress` demo in Phase 3, show today's calendar (if configured), surface any tasks, and present active projects. The user sees exactly what their daily kickoff experience will be — with real data from this onboarding session.

After it runs: "That's what every session starts with. One command, full context. You never have to re-explain what you were working on."

### 7c: How It Keeps Learning

Mention the two skills that make the system get smarter over time:

"Two more things worth knowing. `/teach` learns your writing style — show it a few emails or messages you've written, and `/write` starts producing drafts that sound like you, not like an AI. And `/feedback` — you already saw this during setup — means any correction you make is permanent. Say 'stop doing X' once, and I stop doing X forever. The system adapts to you, not the other way around."

### 7d: Quick Reference Card

```
Your daily workflow:

  /resume       — Start here. Loads context, tasks, calendar, active projects.
  /compress     — End here. Saves a searchable session log.
  /{first-skill} — Your custom skill from today.

Create and communicate:
  /write        — Draft emails, messages, posts in your voice.
  /note         — Quick capture to your notes inbox.
  /meeting      — Pre-filled meeting note, opened and ready.

Think and plan:
  /grill-me     — Stress-test any plan or idea.
  /deep-research — Cited research reports.
  /project      — Create and track projects.

System learns from you:
  /teach        — Show it your writing style.
  /feedback     — Correct it once, it remembers forever.

Two thinking patterns to know:
  Brain dump  — "Get everything out of your head." Unstructured capture, no goal.
                Use /note to capture, /process-inbox to organize later.
  Brainstorm  — "Generate ideas toward a specific goal." Structured, goal-directed.
                Use /grill-me to pressure-test, /deep-research for data-driven ideation.
```

### 7e: Next Steps

"Start your next session with `/resume`. That's all you need to remember — everything else you'll discover naturally."

If anything failed in Phase 4:
"A few things still need to be hooked up before they'll work. Here's what to do: [repeat the fix instructions from Phase 4 in plain English]."

---

## Error Handling

### Phase 1 Errors
- **Command not found:** Skip that tool, note it as "not installed."
- **Permission denied:** Note the issue, continue detection. Handle silently.
- **WSL detection fails:** Default to Linux behavior, note uncertainty.

### Phase 2 Errors
- **User wants to skip a topic:** Respect it. Record as "not configured" and move on.
- **User gives ambiguous answers:** Ask one clarifying follow-up, then move on with best interpretation.
- **User wants to stop mid-interview:** Save progress to a temporary file (`~/.claude/state/.onboard-progress.json`). On next `/onboard` run, detect it and offer to resume.

### Phase 3 Errors
- **File write fails:** Report the error in plain English (e.g., "I wasn't able to save your settings — it looks like a permissions issue. Try running this command to fix it: ..."). Don't surface raw file paths to the user unless absolutely necessary for them to act.
- **Template not found:** Fall back to inline generation using the schema definitions.
- **Existing config conflict:** Show the diff between existing and proposed values without using internal file path names. Ask which to keep.

### Phase 4 Errors
- **MCP server not running:** Provide the specific setup instructions for that integration in plain language.
- **Vault path doesn't exist:** Silently create `~/.claude/vault/+Inbox/` if it doesn't exist. Report to user only if creation fails.
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
