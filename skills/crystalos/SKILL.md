---
name: crystal:crystalos
description: Use when Austin wants to add, edit, or remove any feature, automation, script, cron job, n8n workflow, web UI element, MCP server, or systemd service on the Heart CrystalOS server. Invoke with /crystalos followed by a description of what to build or change. Also handles iterating on, debugging, or removing existing Heart features. Trigger for any Heart server work — even vague requests like "set up Gmail on Heart", "add a cron for X", "fix the web UI", or "build the morning briefing".
version: 1.2.0
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# /crystalos — Heart Feature Manager

Build, edit, or remove features on the Heart CrystalOS server. Maintains a manifest of everything deployed.

**Manifest:** `state/operational/heart-manifest.md`
**Heart log:** `state/operational/heart-log.md`

**Config resolution:** Before executing, read `crystal.local.yaml` to resolve:
- `${HEART_SSH}` → `environments.heart.user`@`environments.heart.host`
- `${HEART_USER}` → `environments.heart.user`
- All server paths use `${HEART_USER}` instead of hardcoded usernames

---

## Heart Environment

Know this before touching anything.

| Property | Value |
|----------|-------|
| Host | See `crystal.local.yaml` → `environments.heart` |
| Auth | SSH key (system identity key, no password) |
| Vault path | See `crystal.local.yaml` → `environments.heart.vault_path` |
| Run all ops as | Heart user (not root) |
| Claude CLI | See `crystal.local.yaml` → `environments.heart.claude_cli` |
| Python | 3.12 available — **pip installed** (`pip3` via apt; `google-api-python-client`, `google-auth-oauthlib` available) |
| n8n | Accessible via n8n MCP tools |

**Standard paths:**

| Purpose | Path |
|---------|------|
| General scripts | `/home/${HEART_USER}/scripts/` |
| Morning briefing scripts | `/home/${HEART_USER}/briefing/` |
| Web UI files | `/home/${HEART_USER}/crystalos-ui/` |
| MCP server configs | `/home/${HEART_USER}/.claude.json` (user-level) |
| Log output | `/home/${HEART_USER}/logs/` |

---

## Agent Roster

Before doing any work, check the request against this table and spawn the appropriate subagent(s) via the Agent tool. Do not do the work inline when a matching agent exists.

| Task | Agent | File |
|------|-------|------|
| Architecture / high-level design decisions | Software Architect | `engineering/engineering-software-architect.md` |
| Web UI — HTML/CSS/JS implementation | Frontend Developer | `engineering/engineering-frontend-developer.md` |
| Web UI — layout, CSS systems, mobile UX | UX Architect | `design/design-ux-architect.md` |
| Web UI — visual design, component look/feel | UI Designer | `design/design-ui-designer.md` |
| Backend API servers, Python/Node services | Backend Architect | `engineering/engineering-backend-architect.md` |
| Systemd services, cron jobs, infrastructure | DevOps Automator | `engineering/engineering-devops-automator.md` |
| MCP server install, config, registration | DevOps Automator | `engineering/engineering-devops-automator.md` |
| n8n workflow design and implementation | Automation Governance Architect | `specialized/automation-governance-architect.md` |
| Testing API endpoints | API Tester | `testing/testing-api-tester.md` |
| Code review before deploying | Code Reviewer | `engineering/engineering-code-reviewer.md` |
| Server reliability, monitoring, observability | SRE | `engineering/engineering-sre.md` |
| Server infrastructure health and maintenance | Infrastructure Maintainer | `support/support-infrastructure-maintainer.md` |
| Auth, access control, security hardening | Security Engineer | `engineering/engineering-security-engineer.md` |

**Multiple agents for one task:** Spawn in parallel when work is independent (Frontend Developer + UX Architect can work simultaneously). Spawn sequentially when order matters (Software Architect → Backend Architect → API Tester).

---

**Known gotchas — read before building:**

| Issue | Cause | Fix |
|-------|-------|-----|
| Claude hangs in n8n | n8n leaves stdin open | Always use `heart-run.sh`, never call `claude` directly — it already has `< /dev/null` |
| `executeCommand` node blocked | Disabled by default in n8n 2.8.4 | `Environment="NODES_EXCLUDE=[]"` in n8n systemd service — already set |
| `claude: not found` from n8n | Minimal PATH in `/bin/sh` | Use full path in heart-run.sh — already handled |
| Python server needs a dep | No pip on Heart | Rewrite using stdlib alternatives, or install the package via `pip install --user` after verifying pip is available |
| Port conflict | 8080 is taken by crystalos-ui | Pick a different port; check `ss -tlnp` on Heart first |

---

## Step 1: Read the Manifest

Read `state/operational/heart-manifest.md` before doing anything. It prevents duplicates and shows what already exists to build on.

---

## Step 2: Plan

Identify all components the request requires and which agents handle each:

| Component type | How it's built | Agent |
|---------------|----------------|-------|
| Script | SSH → create file → `chmod +x` | DevOps Automator |
| Cron job | SSH → append to crontab | DevOps Automator |
| Systemd service | SSH → write unit file → `systemctl enable/start` | DevOps Automator |
| n8n workflow | n8n MCP tools | Automation Governance Architect |
| MCP server | SSH → install package or clone → register in `~/.claude.json` | DevOps Automator |
| Web UI (layout/CSS) | SSH → create/edit UI files | UX Architect + Frontend Developer |
| Backend API server | SSH → create/edit server files (stdlib Python or Node) | Backend Architect |
| Config file | SSH → create/edit config | DevOps Automator |

For non-trivial builds, spawn the **Software Architect** agent first.

Present the plan to Austin:
- What will be created, changed, or removed
- Which agents handle each component
- File paths on Heart for each component
- Any dependencies or prerequisites
- Cron schedule or port if applicable

**Wait for approval before building.**

---

## Step 3: Build

Execute in dependency order (scripts before cron jobs that call them, etc.). Spawn agents per the Agent Roster.

### Scripts

```bash
ssh ${HEART_SSH} "mkdir -p /home/${HEART_USER}/scripts && cat > /home/${HEART_USER}/scripts/script-name.sh << 'SCRIPT'
#!/bin/bash
# script content
SCRIPT
chmod +x /home/${HEART_USER}/scripts/script-name.sh"
```

Note: Heart has Python 3.12 but **no pip**. If a script needs a Python package not in stdlib, either use a stdlib equivalent or explicitly verify pip availability first.

### Cron Jobs

```bash
ssh ${HEART_SSH} "(crontab -l 2>/dev/null; echo '0 6 * * * /home/${HEART_USER}/scripts/script.sh >> /home/${HEART_USER}/logs/script.log 2>&1') | crontab -"
```

Rules:
- Always use absolute paths
- Always redirect stdout and stderr to a log file in `/home/${HEART_USER}/logs/`

### Systemd Services

```bash
# Write unit file
ssh ${HEART_SSH} "sudo tee /etc/systemd/system/service-name.service > /dev/null << 'UNIT'
[Unit]
Description=Service description
After=network.target

[Service]
User=${HEART_USER}
WorkingDirectory=/home/${HEART_USER}
ExecStart=/home/${HEART_USER}/scripts/service-name.sh
Restart=on-failure
StandardOutput=append:/home/${HEART_USER}/logs/service-name.log
StandardError=append:/home/${HEART_USER}/logs/service-name.log

[Install]
WantedBy=multi-user.target
UNIT
sudo systemctl daemon-reload && sudo systemctl enable --now service-name.service"
```

### MCP Servers

MCP servers on Heart extend Claude's capabilities for autonomous jobs. Install via SSH, then register in Heart's `~/.claude.json`.

```bash
# Install (example: npm-based MCP)
ssh ${HEART_SSH} "npm install -g @scope/mcp-server-name"

# Register in ~/.claude.json (add to mcpServers block)
ssh ${HEART_SSH} "cat ~/.claude.json"
# Then edit to add the new server entry
```

Always test with `claude mcp list` on Heart after registering to confirm it loads.

### n8n Workflows

Use n8n MCP tools. Key tools:
- `n8n_create_workflow` — create a new workflow
- `n8n_update_full_workflow` — replace an existing workflow
- `n8n_update_partial_workflow` — patch specific nodes
- `n8n_test_workflow` — test before activating
- `n8n_validate_workflow` — validate structure
- `search_nodes` — find available node types
- `n8n_health_check` — verify n8n is reachable

**Critical:** Any workflow node that invokes Claude **must use `heart-run.sh`**, not call `claude` directly. The wrapper handles PATH, stdin closure, logging, and working directory.

```
Execute Command node:
  Command: /home/${HEART_USER}/heart-run.sh "your task description here"
```

Always test and validate before activating. Include error-handling nodes in complex workflows.

### Web UI

Files live at `/home/${HEART_USER}/crystalos-ui/static/`. Server at `/home/${HEART_USER}/crystalos-ui/server.py`, port 8080.

Spawn **Frontend Developer** for JS/functionality, **UX Architect** for layout/CSS, **UI Designer** for visual polish — in parallel if independent.

---

## Step 4: Smoke Test

Confirm each component is alive before handing off to review agents:

- **Scripts:** Run once manually via SSH and check output
- **Cron jobs:** Confirm entry with `ssh ${HEART_SSH} "crontab -l"`
- **Systemd services:** `systemctl status service-name` — confirm `active (running)`
- **MCP servers:** `ssh ${HEART_SSH} "claude mcp list"` — confirm it appears
- **n8n workflows:** Use `n8n_test_workflow`
- **Backend API / Web UI:** Confirm endpoint responds with a basic `curl`

---

## Step 5: Agent Review

After the smoke test passes, spawn review agents **in parallel** based on what was built. Don't skip — it catches production issues early.

| What was built | Spawn these agents in parallel |
|---------------|-------------------------------|
| Backend server / API | Code Reviewer + Security Engineer + API Tester |
| Web UI (HTML/CSS/JS) | Code Reviewer + Frontend Developer + UX Architect |
| Both backend + frontend | All five above in parallel |
| Script / cron job | Code Reviewer + DevOps Automator |
| Systemd service | Code Reviewer + DevOps Automator + SRE |
| n8n workflow | Code Reviewer + Automation Governance Architect |
| MCP server | Code Reviewer + Security Engineer |

**What each agent reviews:**
- **Code Reviewer** — correctness, reliability, edge cases, error handling
- **Security Engineer** — injection risks, path traversal, auth gaps, data exposure, credential handling
- **API Tester** — endpoint behavior, error responses, boundary conditions
- **Frontend Developer** — JS correctness, mobile browser compatibility, async error handling
- **UX Architect** — mobile layout, keyboard behavior, tap targets, iOS Safari quirks
- **DevOps Automator** — service lifecycle, restart behavior, log hygiene, idempotency
- **SRE** — failure modes, alerting, observability, restart policy
- **Automation Governance Architect** — workflow error paths, retry logic, credential handling

Collect all findings, deduplicate overlaps, present a consolidated prioritized list. Apply **MUST FIX** items before proceeding to Step 6.

---

## Step 6: Update Manifest

Update `state/operational/heart-manifest.md` with the new or changed feature.

**New feature entry format:**

```markdown
### [Feature Name]
- **Type:** script | cron | n8n-workflow | web-ui | config | systemd | mcp-server
- **Description:** One sentence — what it does and when.
- **Schedule:** `0 6 * * *` (daily at 6am) — only for cron
- **Components:**
  - Script: `/home/${HEART_USER}/scripts/filename.sh`
  - Cron: `0 6 * * * /home/${HEART_USER}/scripts/filename.sh >> /home/${HEART_USER}/logs/filename.log 2>&1`
  - n8n Workflow ID: [id]
  - Systemd: `service-name.service`
- **Logs:** `/home/${HEART_USER}/logs/filename.log`
- **Added:** YYYY-MM-DD
- **Status:** active
```

For edits: update relevant fields and note what changed.
For removals: change status to `removed`, add `Removed: YYYY-MM-DD`, and note why.

---

## Step 7: Update Heart Log

Append one line to `state/operational/heart-log.md`:

```
YYYY-MM-DD | /crystalos | [build|edit|remove] | [feature name] | [brief description of what was done]
```

---

## Error Handling

- **SSH fails:** Verify network access to Heart (see crystal.local.yaml). Check that the system identity key is loaded.
- **n8n unreachable:** Run `n8n_health_check`. If down, note in the log and report to Austin.
- **Cron not running:** Check the log file at the crontab path. Verify absolute paths are used.
- **Permission denied on Heart:** All file operations run as `crystalos`. Never use sudo except for systemd unit files and system-level config.
- **Python package missing:** No pip by default — use stdlib or verify pip availability with `pip --version` before proceeding.
- **Port conflict:** Check with `ss -tlnp` before binding a new port. 8080 is taken by crystalos-ui.
- **Any tool/MCP failure:** Invoke the `auto-fix` skill before surfacing the error to Austin.
