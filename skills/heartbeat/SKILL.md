---
name: heartbeat
description: "Autonomous task dispatcher — runs every 15 minutes via cron, checks registered jobs against heart-state.md, executes due jobs, updates state."
user-invocable: true
---

# Heartbeat — Autonomous Task Dispatcher

You are running on Heart (CrystalOS). This skill is invoked every 15 minutes by cron via `heart-run.sh /crystal-ai:heartbeat`.

## Paths (Heart server)

- **Plugin root:** `/home/crystalos/CrystalAI`
- **State file:** `/home/crystalos/CrystalAI/state/environments/heart-state.md`
- **Vault:** `/home/crystalos/VaultyBoi`
- **Logs:** `/home/crystalos/logs/`
- **Secrets:** `/home/crystalos/CrystalAI/crystal.secrets.yaml`

## Job Registry

| Job | Condition | Action |
|-----|-----------|--------|
| `staleness-check` | `last-morning-briefing` > 25 hours ago | Run `bash /home/crystalos/morning-briefing.sh` directly (backup for 5 AM cron) |
| `log-compression` | `last-log-compression` > 30 days ago | Compress old log files in `/home/crystalos/logs/` |
| `content-capture` | `last-content-capture` > 24 hours ago | Run `/crystal-ai:content-capture` skill inline |
| `content-publish` | `last-content-publish` > 1 hour ago | Run `python3 /home/crystalos/CrystalAI/skills/content-publish/scripts/publish.py --vault-path /home/crystalos/VaultyBoi` |
| `email-contacts-update` | `last-email-contacts-update` > 24 hours ago | Run `bash /home/crystalos/CrystalAI/skills/process-email/scripts/email-contacts-update.sh /home/crystalos/CrystalAI /home/crystalos/VaultyBoi` |

## Execution Steps

1. Read `/home/crystalos/CrystalAI/state/environments/heart-state.md` to get last-run timestamps
2. Get current time
3. For each job in the registry, check if the condition is met
4. For due jobs, execute the action:
   - **staleness-check:** Run `bash /home/crystalos/morning-briefing.sh` directly (no n8n dependency)
   - **log-compression:** Find logs older than 30 days in `/home/crystalos/logs/`, gzip them
   - **content-capture:** Invoke the `/crystal-ai:content-capture` skill inline (needs Claude — runs within this heartbeat session)
   - **content-publish:** Run via Bash (standalone Python, no Claude needed). API keys loaded from path in `crystal.secrets.yaml` → `buffer.keys_file`.
   - **email-contacts-update:** Run via Bash (standalone, no Claude needed). Refreshes recent correspondents from sent mail across all 5 Gmail accounts, rebuilds active project contacts from vault project files.
5. **CRITICAL:** Update `/home/crystalos/CrystalAI/state/environments/heart-state.md` — set `last-heartbeat` to current ISO-8601 timestamp, plus any other job-specific timestamps for jobs that ran
6. Log actions taken (or "no jobs due") to stdout

## State File Format

```yaml
last-heartbeat: ISO-8601
last-morning-briefing: ISO-8601
last-log-compression: ISO-8601
last-content-capture: ISO-8601
last-content-publish: ISO-8601
last-email-contacts-update: ISO-8601
heart-status: idle | running
last-error: null | description
```

## Rules

- **MANDATORY FIRST ACTION:** Before doing anything else, use the Edit tool to update `last-heartbeat` in `/home/crystalos/CrystalAI/state/environments/heart-state.md` to the current UTC ISO-8601 timestamp. This file write MUST happen every single run — it is the primary health signal. If this write does not happen, the heartbeat is considered broken.
- Be fast — this runs every 15 minutes, keep execution under 2 minutes
- If a job fails, log the error but don't retry — next heartbeat will catch it
