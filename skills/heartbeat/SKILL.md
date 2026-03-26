---
name: crystal:heartbeat
description: "Autonomous task dispatcher — runs every 15 minutes via cron, checks registered jobs against heart-state.md, executes due jobs, updates state."
user_invocable: false
---

# Heartbeat — Autonomous Task Dispatcher

You are running on Heart (CrystalOS, 10.1.11.214). This skill is invoked every 15 minutes by cron via `heart-run.sh /heartbeat`.

## Job Registry

| Job | Condition | Action |
|-----|-----------|--------|
| `staleness-check` | `last-morning-briefing` > 25 hours ago | POST to morning briefing n8n workflow to re-trigger |
| `log-compression` | `last-log-compression` > 30 days ago | Compress old log files in `/home/crystalos/logs/` |
| `content-capture` | `last-content-capture` > 24 hours ago | Run `/content-capture` skill to scan for new content ideas |
| `content-publish` | `last-content-publish` > 1 hour ago | Run `python3 /home/crystalos/CrystalAI/skills/content-publish/scripts/publish.py --vault-path /home/crystalos/VaultyBoi` |

## Execution Steps

1. Read `/home/crystalos/VaultyBoi/state/environments/heart-state.md` to get last-run timestamps
2. Get current time
3. For each job in the registry, check if the condition is met
4. For due jobs, execute the action:
   - **staleness-check:** `curl -s -X POST http://localhost:5678/webhook/TjvFCtYDRWgglGgJ/trigger/morning-briefing`
   - **log-compression:** Find logs older than 30 days in `/home/crystalos/logs/`, gzip them
   - **content-capture:** Invoke the `/content-capture` skill inline (needs Claude — runs within this heartbeat session)
   - **content-publish:** Run via Bash: `python3 /home/crystalos/CrystalAI/skills/content-publish/scripts/publish.py --vault-path /home/crystalos/VaultyBoi` (standalone Python, no Claude needed). API keys loaded from `~/.crystalos/buffer-keys.json`.
5. Update `state/environments/heart-state.md` with `last-heartbeat: <now>` and any other job-specific timestamps
6. Log actions taken (or "no jobs due") to stdout

## State File Format

```yaml
last-heartbeat: ISO-8601
last-morning-briefing: ISO-8601
last-log-compression: ISO-8601
last-content-capture: ISO-8601
last-content-publish: ISO-8601
heart-status: idle | running
last-error: null | description
```

## Rules

- Always update `last-heartbeat` even if no other jobs fire
- Be fast — this runs every 15 minutes, keep execution under 2 minutes
- If a job fails, log the error but don't retry — next heartbeat will catch it
