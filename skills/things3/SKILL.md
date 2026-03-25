---
name: crystal:things3
description: Internal tool skill — reference for all Things3 operations: creating, updating, completing, searching, and moving tasks and projects. Called by other skills (compress, process-email, process-inbox, resume) when they need to interact with Things3. Also invoke directly whenever any operation touches Things3 — task creation, status updates, due dates, list assignment, notes, or searches.
version: 1.0.0
allowed-tools: Bash
---

# Things3 Tool Skill

Internal reference for all Things3 MCP operations and AppleScript patterns. Other skills call this instead of duplicating Things3 instructions.

## Mandatory Usage Rule

**Never call Things3 MCP tools directly.** Always invoke this skill first. It owns:
- Rules about what should and should not become a Things3 task
- Title formatting, notes structure, backlink format
- Fallback behavior when MCP is unavailable

If you are about to call `mcp__things3__*` without having gone through this skill — stop and invoke this skill instead.

## MCP Tools Available

| Tool | Purpose |
|------|---------|
| `mcp__things3__create-things3-todo` | Create a new task |
| `mcp__things3__update-things3-todo` | Update an existing task |
| `mcp__things3__complete-things3-todo` | Mark task complete |
| `mcp__things3__search-things3-todos` | Search tasks by keyword |
| `mcp__things3__view-todos` | View tasks (by list, area, or tag) |
| `mcp__things3__view-projects` | List all projects |
| `mcp__things3__create-things3-project` | Create a new project |
| `mcp__things3__check_auth_status` | Verify Things3 MCP is working |

---

## Creating a Task

```
mcp__things3__create-things3-todo
  title: "Task title" (required)
  notes: "Context and links..."
  when: "today" | "tomorrow" | "YYYY-MM-DD" | omit → lands in Inbox
  deadline: "YYYY-MM-DD" | null
  list: "Project Name" | null
  tags: ["tag1", "tag2"]
  checklist: ["item 1", "item 2"]
```

**Default destination rule:**
- **No specific date?** → omit `when` entirely. Task lands in the Inbox.
- **Specific date required?** → set `when` to that date (e.g. `"2026-03-20"`). Task goes to that date's scheduled view.
- Never default to `"anytime"` or `"today"` unless Austin explicitly requests it or the context makes it unambiguous.

**Session backlink format:**
```
Created from session: [[YYYY-MM-DD-HHmm-topic]]

Context: [1-3 sentences]
```

**Email backlink format:**
```
[Original email](message://%3CMESSAGE_ID%3E)

Context: [1-3 sentences]
```

---

## Reschedule Existing Task

**CRITICAL pattern — always do in this order:**
1. Move task to `"Anytime"` list first
2. Then set due date as separate statement

Never use `set schedule date` on existing tasks → throws `-10006`.

```applescript
tell application "Things3"
  set t to first to do of list "Today" whose name is "Task Name"
  move t to list "Anytime"
  set due date of t to date "March 20, 2026"
end tell
```

---

## Known Quirks

- **`count` is a reserved word** in AppleScript — use `archivedCount`, `taskCount`, etc. instead
- **Never pass date properties in the initial `make new to do with properties` block** — set them as separate statements after creation
- **Moving to Today:** `move to do newTodo to list "Today"` — works. `set schedule date` post-creation → fails.
- **Due date:** `set due date of newTodo to date "..."` as separate statement — works.

---

## Searching Tasks

```
mcp__things3__search-things3-todos
  query: "keyword"
```

Check for duplicates before creating a task if the context suggests one might already exist.

---

## Creating a Project

```
mcp__things3__create-things3-project
  title: "Project Name"
  notes: "Description"
  tags: ["tag1"]
  when: "today" | omit
  deadline: "YYYY-MM-DD" | null
```

---

## What NOT to Task

Do not create Things3 tasks for work that is tracked in Obsidian project files. Things3 is for actionable personal and client tasks — not dev/infra project backlogs.

**Specifically: never create Things3 tasks for CrystalOS development work.** Next steps for CrystalOS live in `Projects/crystalos.md`. Same rule applies to any project where the Obsidian file is the source of truth for next steps.

**Things3 IS the right place for:**
- Client action items (GIS, SJA, KESA, Umbrella)
- Personal tasks (calendar prep, errands, follow-ups)
- Time-sensitive reminders with real deadlines
- Waiting-on follow-ups

---

## Good Task Titles

- Start with an action verb: Review, Send, Schedule, Fix, Update, Create, Follow up, Research
- Specific and clear — include who/what/why when it matters
- 3-10 words
- ✅ "Review GIS documentation before Thursday meeting"
- ✅ "Send John the Q1 planning data"
- ❌ "Meeting" ❌ "Follow up" ❌ "Research"

---

## Fallback: Things3 MCP Unavailable

If the Things3 MCP is unavailable (connection error, auth failure), do NOT drop tasks on the floor. Write them to the heart queue instead:

**Append to `state/operational/heart-queue.md`:**
```yaml
---
queued-at: YYYY-MM-DDTHH:MM:SS
type: things3-task
source: [session-slug or calling-skill]
status: pending
last-error: null
payload:
  title: "Task title"
  notes: "Context..."
  tags: [tag1, tag2]
  when: today  # or tomorrow, YYYY-MM-DD, or omit
  deadline: null
  list: null
---
```

MacBook will pick these up on next `/resume` or scheduled queue check and push them to Things3.

After queuing, tell the user: "Things3 unavailable — [N] tasks queued in heart-queue.md for retry."
