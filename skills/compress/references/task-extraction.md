# Task Extraction for Compress

Guidance for identifying tasks in a session conversation. For Things3 creation patterns, title formatting, notes format, tags, and fallback behavior — see the `things3` tool skill.

## Identifying Tasks in Conversation

### Explicit indicators
- "I need to..." / "We need to..."
- "TODO:" / "Action item:"
- "Follow up on..." / "Remember to..."
- "Next step is..."

### Implicit indicators
- Deferred decisions: "I'll figure that out later" → Task: Figure out [topic]
- Incomplete work: "Almost done with [X]" → Task: Finish [X]
- Questions that imply action: "How should I [do X]?" → Task: Do X

### What NOT to extract
- Things already done in this session
- Vague references with no clear next action
- Duplicates of tasks already created
- **Project next steps** — if it's something the user would naturally do the next time they work on that project, it belongs in the project file, not Things3. The project file IS the tracking system.
- **Any work that happens inside a project work session** — if opening the project doc and reading "Next:" would prompt the action, no task needed.

### What TO extract (the real filter)
Before creating a task, ask: **"Does this need to happen outside of a project work session?"**

- If the user needs to remember to do something on a specific date → task
- If it's a real-world action that won't surface naturally (send an email, make a call, follow up with someone, pay something) → task
- If it's a "waiting on" item that needs a follow-up reminder → task
- If it'll come up automatically next time the user opens the project → skip it

## Session Backlink Format

Always include in task notes:
```
Created from session: [[YYYY-MM-DD-HHmm-topic]]

Context: [1-3 sentences explaining why this task exists]
```

## Volume

Extract 1-3 tasks per session. Err on the side of fewer — if uncertain, skip it. Focus exclusively on things that would fall through the cracks because they happen *outside* of project work.
