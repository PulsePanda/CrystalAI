# Inbox Processing Examples

Real-world examples of processing various types of inbox captures.

## Example 1: Simple Meeting Capture

### Before: Inbox File
**File:** `+Inbox/team-standup.md`
```markdown
Standup today with team

John - API work progressing
Sarah - Bug fix complete
Me - Working on documentation

Action: Review Sarah's PR
Action: Update roadmap doc
```

### Processing
1. **Detected**: Meeting note (keyword "standup", action items)
2. **Meeting type**: Standup
3. **Participants**: Team
4. **Topic**: Daily Update
5. **Date**: Today (2026-01-30)

### After: Formatted Note
**File:** `Areas/Work/Meeting notes/2026-01-30 [Standup] [Team] Daily Update.md`
```markdown
TITLE: Standup Team Daily Update

_Pre-notes:_

-- Daily team standup

_Meeting Notes:_

-- **John**: API integration work is progressing well
-- **Sarah**: Authentication bug fix completed
-- **Me**: Working on documentation updates

_Action Items:_

◯ Review Sarah's PR for auth bug fix
◯ Update roadmap documentation

_Tasks Created:_

- Review Sarah's PR (auth fix)
- Update project roadmap document

#standup #team   @John @Sarah
```

### Result
- Formatted meeting note moved to proper location
- 2 tasks created with backlinks
- Inbox file deleted

---

## Example 2: Personal Idea

### Before: Inbox File
**File:** `+Inbox/gift-idea.md`
```markdown
Gift for wife's birthday coming up

She mentioned wanting to get back into pottery
Maybe a pottery wheel?
Budget around $300
Check reviews online
```

### Processing
1. **Detected**: Personal note (keywords: "wife", "birthday", "gift")
2. **Ask user**: "Create as task or keep as note?"
3. **User chooses**: Task

### Result
- Task created with full context in notes
- Inbox file deleted

---

## Example 3: Work Research Note

### Before: Inbox File
**File:** `+Inbox/automation-research.md`
```markdown
Research on vault automation tools

Looked into several options:
1. Templater - powerful template engine
2. Dataview - query language for vault
3. QuickAdd - rapid note creation

Templater seems most promising for our use case
```

### After: Moved Note
**File:** `Areas/Work/Research/vault-automation-tools.md`

### Result
- Note moved to work research area
- Content lightly formatted for readability
- No tasks created (informational only)
- Inbox file deleted

---

## Example 4: Simple Task

### Before: Inbox File
**File:** `+Inbox/dentist-reminder.md`
```markdown
Call dentist to schedule checkup
```

### Result
- Task created in task manager
- Inbox file deleted
- No note file created (too simple for reference)

---

## Example 5: Mixed Content File

### Before: Inbox File
**File:** `+Inbox/various-notes.md`
```markdown
Random thoughts from today

1. Meeting tomorrow with John about Q1
   Need to prepare slides

2. Gift idea: pottery wheel for wife

3. Research automation tools for vault
```

### Processing
1. **Detected**: Multiple unrelated items
2. **Ask user**: "Split into separate items?"
3. **User approves**: Yes, split

### Result
- Item 1: Meeting prep task created
- Item 2: Personal task created
- Item 3: Research note filed to Areas/Work/Research/
- Original inbox file deleted

---

## Example 6: Project Idea

### Before: Inbox File
**File:** `+Inbox/dashboard-project.md`
```markdown
Project idea: Analytics Dashboard

Build internal dashboard for team metrics
- Track PR velocity
- Show bug trends
- Display project status
- Weekly reports

Tech stack: React + D3.js
Timeline: 6-8 weeks
```

### Result
- Full project file created in Projects/ via /project skill
- Initial tasks created
- Inbox file deleted

---

## Example 7: Empty File

**File:** `+Inbox/untitled.md` (empty or whitespace only)

### Result
- Auto-deleted (empty files have no value)
- Listed in plan as "empty, will delete"

---

## Common Patterns Summary

| Pattern | Detection | Action |
|---------|-----------|--------|
| Meeting capture | Participants + discussion + action items | Format with template, extract tasks |
| Simple task | 1-2 lines, single action | Create task, delete file |
| Personal note | Personal keywords, non-work context | Ask: task or note? |
| Work note | Technical content, research, reference | Move to Areas/Work/ |
| Project idea | Multi-phase initiative, goals | Create project file |
| Multi-item | Multiple distinct topics | Ask to split, process each |
| Empty file | < 10 chars non-whitespace | Auto-delete |
