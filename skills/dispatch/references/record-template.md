# Dispatch Record Template

File at: `~/.claude/state/operational/dispatch-records/YYYY-MM-DD-{task-name}.md`

---

```yaml
---
type: dispatch-record
created: {YYYY-MM-DD}
task: {task-name-kebab}
status: {completed | escalated | partial}
entry-mode: {directed | autonomous}
agents-used: [{agent-type-1}, {agent-type-2}]
judge-two-iterations: {N}
---
```

```markdown
# Dispatch: {Task Name}

## Task
> {Original task description, verbatim}

## Outcome
**Status:** {completed | escalated | partial}
**Summary:** {1-2 sentence description of what was accomplished}

## What Was Done
- {Action 1}: {result}
- {Action 2}: {result}

## What Was Produced
| Output | Location | Description |
|--------|----------|-------------|
| {file/draft/task/etc.} | {path or reference} | {what it is} |

## Agents Used
| Agent | Role | Steps | Status |
|-------|------|-------|--------|
| {type} | {what it did} | {step numbers} | {completed/failed} |

## Issues
{Any problems encountered, or "None."}
```
