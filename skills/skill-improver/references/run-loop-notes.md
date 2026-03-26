# run_loop.py — Working Command & Gotchas

## Working command pattern

```bash
cd "/Users/Austin/.claude/plugins/cache/claude-plugins-official/skill-creator/d5c15b861cd2/skills/skill-creator"

nohup python3 -m scripts.run_loop \
  --eval-set "/path/to/trigger_eval.json" \
  --skill-path "/path/to/skill-dir" \
  --model "claude-sonnet-4-6" \
  --max-iterations 5 \
  --verbose \
  --results-dir "/path/to/output-dir" \
  > /tmp/claude-501/grill-me-desc-opt.log 2>&1 &
```

## Requirements

| Requirement | Notes |
|-------------|-------|
| Python binary | `python3`, not `python` |
| Working directory | MUST be skill-creator base dir — `cd` there before running |
| `--skill-path` | Skill DIRECTORY (e.g. `.../grill-me/`), NOT the SKILL.md path |
| `ANTHROPIC_API_KEY` | Must be set in shell env before launch — Claude Code's key is NOT inherited by subprocess Python. Needed for the "improve description" step. |
| `--results-dir` | Optional but useful — saves results.json and report.html to a timestamped subdir |

## How to set ANTHROPIC_API_KEY

```bash
export ANTHROPIC_API_KEY="sk-ant-..."  # then run the command
```

Or prefix inline:
```bash
ANTHROPIC_API_KEY="sk-ant-..." nohup python3 -m scripts.run_loop ...
```

## What happens without ANTHROPIC_API_KEY

Loop completes the eval phase (run_eval.py → `claude -p` subprocess, no direct API needed) but crashes when calling `improve_description()`. Workaround: use the eval data visible in the log to manually improve the description.

## Eval set format

```json
[
  {"query": "...", "should_trigger": true},
  {"query": "...", "should_trigger": false}
]
```

20 queries recommended: 10 should-trigger, 10 should-not-trigger.

## Results location

After a successful run: `--results-dir/<timestamp>/results.json` contains `best_description`.
