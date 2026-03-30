# Inbox Categorization Rules

Complete decision tree and pattern matching for categorizing inbox captures.

## Primary Content Types

Five main categories for inbox content:

1. **Meeting Notes** - Captures from meetings or calls
2. **Personal Notes** - Personal thoughts, ideas, reminders
3. **Work Notes** - Work-related content (not meetings)
4. **Project Ideas** - New project concepts
5. **Simple Tasks** - Single action items better suited for task list

## Decision Tree

```
Is it a meeting capture?
├─ Yes → Meeting Note
│  └─ Format with template
│     └─ Extract action items → task manager
│        └─ Move to Areas/Work/Meeting notes/
│
└─ No → Continue...
   │
   Is it a single actionable task?
   ├─ Yes → Simple Task
   │  └─ Create in task manager
   │     └─ Delete inbox file
   │
   └─ No → Continue...
      │
      Is it personal content?
      ├─ Yes → Personal Note
      │  └─ Ask: Keep as note or create task?
      │     ├─ Note → Move to Areas/Personal/
      │     └─ Task → Create in task manager, delete file
      │
      └─ No → Continue...
         │
         Is it a project idea?
         ├─ Yes → Project Idea
         │  └─ Create project file from template
         │     └─ Move to Projects/
         │        └─ Delete inbox file
         │
         └─ Default → Work Note
            └─ Move to Areas/Work/
```

## Pattern Matching Rules

### Meeting Notes Detection

**Filename indicators (high confidence):**
- Contains: "meeting", "call", "standup", "sync", "1-on-1", "retro"
- Has person names and date

**Content indicators (high confidence):**
```
Strong signals:
- "Meeting with [names]"
- "Standup with [team]"
- "Call with [person/company]"
- "Discussed:", "Agenda:", "Action:"
- Multiple speakers quoted
- Lists of topics + decisions + action items
```

**Content indicators (medium confidence):**
```
Moderate signals:
- Multiple bullet points about discussion
- References to "we", "team", "discussed"
- Action items mixed with notes
- Date/time mentioned
```

### Simple Task Detection

**Content patterns:**
```
High confidence:
- 1-3 lines total
- Single imperative statement
- No context or explanation needed
- Clearly actionable

Examples:
- "Call dentist to schedule appointment"
- "Email John the report"
- "Buy milk"
```

**Counter-indicators (NOT a simple task):**
```
- Has explanation or context
- Multiple related items
- Needs to be referenced later
- Part of larger topic
```

### Personal Notes Detection

**Keyword indicators:**
```
Strong signals:
- "gift idea", "birthday", "anniversary"
- "vacation", "trip", "travel plans"
- "home", "house", "garden"
- "family", "spouse", "kids"
- "personal", "hobby", "interest"
```

### Project Idea Detection

**Content patterns:**
```
Strong signals:
- "Project idea:", "New project:"
- Describes a multi-step initiative
- Has goals or objectives
- Significant scope (not just a task)
```

### Work Notes Detection

**This is the default category** when:
- Not meeting notes
- Not personal
- Not a simple task
- Not a project idea

## Destination Mapping

### Meeting Notes
```
Source: +Inbox/meeting-capture.md
Destination: Areas/Work/Meeting notes/YYYY-MM-DD [Format] [People] Topic.md
```

### Personal Notes
```
Option 1 - Keep as note:
Destination: Areas/Personal/[subcategory]/filename.md

Option 2 - Convert to task:
Create in task manager, delete inbox file
```

### Work Notes
```
Destination: Areas/Work/[subcategory]/filename.md

Subcategories (create as needed):
- Research/
- Documentation/
- Technical/
- General (root)
```

### Project Ideas
```
Destination: Projects/project-name.md
Process: Create project file from template via /project skill
```

### Simple Tasks
```
Destination: Task manager (no file kept)
Process: Create task, delete inbox file
If no task manager: keep as note with task checkbox
```

## Multi-Item Files

**When one inbox file contains multiple unrelated items:**

1. **Split into separate items** — process each according to its type
2. **Keep together** — if items are loosely related, file under primary category
3. **Ask user** — if unclear, present options

## Edge Cases

### Empty or Nearly Empty Files
- File has < 10 characters of non-whitespace content
- Auto-delete without prompting
- Include in plan as "empty, will delete" for visibility

### Duplicate Content
- Alert user: "Similar note exists at [location]"
- Options: merge, keep separate, discard

### Very Long Captures
- Alert user for files > 500 lines
- Options: process normally, split, keep for manual review

## Confidence Levels

**High confidence (auto-process):** Clear indicators, matches known patterns exactly
**Medium confidence (suggest):** Some indicators, present plan for approval
**Low confidence (ask):** Ambiguous, multiple valid interpretations
