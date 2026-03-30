# Meeting Note Format

Guide for transforming rough meeting captures into properly formatted meeting notes.

## Template Structure

A typical meeting note template provides:

```markdown
TITLE: {{meeting-type}} {{primary-contact}} {{meeting-title}}

_Pre-notes:_

– {{pre-note-1}}

_Meeting Notes:_

– {{note-1}}

_Action Items:_

◯ {{action-1}}

 #{{tag}}   @{{primary-contact}}
```

## Filename Generation

### Format
```
YYYY-MM-DD [Meeting-Type] [Participants] Topic.md
```

### Components

**Date (YYYY-MM-DD):**
- Use meeting date if known
- Use today's date if unclear
- Extract from inbox filename if present

**Meeting Type (in brackets):**
- `[Standup]` - Daily team standup
- `[Meeting]` - General meeting (default)
- `[1-on-1]` - One-on-one meeting
- `[Client]` - Client/external meeting
- `[Planning]` - Planning or strategy session
- `[Retro]` - Retrospective
- `[Sync]` - Sync or status meeting
- `[Review]` - Review meeting

**Participants (in brackets):**
- List key participants
- First names or last names
- Comma-separated for multiple
- Or use "Team" for large groups

**Topic:**
- Brief description (2-4 words)
- No special characters
- Title case recommended

### Filename Examples

**Good filenames:**
- `2026-01-30 [Standup] [Team] Daily Update.md`
- `2026-01-30 [1-on-1] [Manager] Performance Review.md`
- `2026-01-30 [Client] [Acme Corp] Project Kickoff.md`
- `2026-01-30 [Planning] [John, Sarah] Q1 Roadmap.md`

**Poor filenames:**
- `meeting.md` (no date, no context)
- `2026-01-30 john.md` (no meeting type, no topic)

## Content Extraction

### From Rough Capture

**Typical rough capture structure:**
```
Meeting with John and Sarah
Discussed Q1 planning
- Need to update roadmap
- Budget concerns
- Timeline tight
Action: Schedule follow-up
Action: Send data to John
```

**Extract components:**
1. **Meeting type**: Implied from "discussed" → [Meeting]
2. **Participants**: "John and Sarah"
3. **Topic**: "Q1 planning"
4. **Pre-notes**: (None in this case)
5. **Meeting notes**: The discussion points
6. **Action items**: Both "Action:" lines
7. **Tags/contacts**: Generate from participants

### Action Items Section

**Extract patterns:**
- "Action:", "TODO:", "Follow up"
- "Need to", "Should", "Will"
- Imperative statements

**Formatting:**
```
_Action Items:_

◯ Action item 1
◯ Action item 2
```

### Tags and Contacts

**Tags to add:**
- Meeting type: `#meeting`, `#standup`, `#planning`
- Project/area: `#q1-planning`, `#project-alpha`
- Topic: `#budget`, `#roadmap`

**Contacts (@mentions):**
- Key participants
- Use @ symbol

## Task Manager Integration

### Action Items → Tasks

If a task manager is configured, create tasks for each action item. Include an Obsidian backlink in notes:

```
Created from: [[YYYY-MM-DD [Type] [People] Topic]]

Context: [1-3 sentences from meeting]
```

**Timing:**
- "today", "ASAP", "urgent" → today
- "tomorrow", "next day" → tomorrow
- Specific date mentioned → that date
- Otherwise → leave unscheduled

### Add Tasks Section to Note

**After action items, add:**
```markdown
_Tasks Created:_

- Task title 1
- Task title 2

(Tasks created in task manager with backlinks to this note)
```

## Edge Cases

### Unclear Meeting Type
- Check content for clues (standup, 1-on-1, planning keywords)
- Default to `[Meeting]` if unclear

### Multiple Participants
- 1-3 people: List names
- 4+ people: Use team/group name

### No Action Items
```
_Action Items:_

◯ (No action items from this meeting)
```

Or omit the section entirely (user preference).

### Recurring Meetings
- Include date in filename (distinguishes occurrences)
- Can reference previous meeting in notes

## Best Practices

**Do:**
- Extract all action items to task manager
- Use consistent filename format
- Include date for chronological sorting
- Add relevant tags for searchability
- Link back to meeting note from tasks

**Don't:**
- Skip action item extraction
- Use vague filenames
- Duplicate action items (note + separate file)
- Forget to move from inbox
- Lose original context from rough capture
