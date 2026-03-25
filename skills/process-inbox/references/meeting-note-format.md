# Meeting Note Format

Guide for transforming rough meeting captures into properly formatted meeting notes.

## Template Structure

The existing template at `_Templates/Meeting Notes Template.md` provides:

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
- `2026-01-30 [Meeting] [Engineering] Sprint Planning.md`

**Poor filenames:**
- `meeting.md` (no date, no context)
- `2026-01-30 john.md` (no meeting type, no topic)
- `notes from earlier.md` (vague, no structure)

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

### Title Construction

**From template variable:**
```
TITLE: {{meeting-type}} {{primary-contact}} {{meeting-title}}
```

**Becomes:**
```
TITLE: Meeting John, Sarah Q1 Planning
```

**Or simplified:**
```
TITLE: Q1 Planning with John and Sarah
```

**Best practice:**
- Keep concise
- Identify meeting clearly
- Include key participants
- Use title case

### Pre-Notes Section

**Purpose:** Context or preparation notes before the meeting

**Extract from capture:**
- Lines before main discussion
- Agenda items
- Background context
- Preparation notes

**Example from rough capture:**
```
Rough: "Agenda: Discuss budget and timeline"
Formatted:
_Pre-notes:_
– Agenda: Budget review and timeline discussion
```

**If none found:**
- Leave section empty or remove
- Or add: `– (No pre-notes)`

### Meeting Notes Section

**Purpose:** Main discussion points and decisions

**Extract from capture:**
- Discussion topics
- Key points covered
- Decisions made
- Important information shared

**Formatting:**
```
_Meeting Notes:_

– Topic 1: Discussion summary
– Topic 2: Key decision made
– Topic 3: Information shared
```

**From rough capture:**
```
Rough:
Discussed Q1 planning
- Budget concerns
- Timeline tight
- Need more resources

Formatted:
_Meeting Notes:_

– Q1 Planning Discussion:
  – Budget concerns raised by finance team
  – Timeline is tight for current scope
  – Additional resources may be needed
```

### Action Items Section

**Purpose:** Tasks to be completed after the meeting

**Extract patterns:**
- "Action:", "TODO:", "Follow up"
- "Need to", "Should", "Will"
- Imperative statements

**Formatting:**
```
_Action Items:_

◯ Action item 1
◯ Action item 2
◯ Action item 3
```

**From rough capture:**
```
Rough:
Action: Schedule follow-up
Action: Send data to John

Formatted:
_Action Items:_

◯ Schedule Q1 planning follow-up meeting
◯ Send GIS data to John by EOD
```

**Note:** The ◯ symbol is used (not checkbox) as per template.

### Tags and Contacts

**From template:**
```
#{{tag}}   @{{primary-contact}}
```

**Tags to add:**
- Meeting type: `#meeting`, `#standup`, `#planning`
- Project/area: `#q1-planning`, `#project-alpha`
- Topic: `#budget`, `#roadmap`

**Contacts (@mentions):**
- Key participants
- Use @ symbol
- Matches Obsidian contact format

**Example:**
```
#meeting #q1-planning #roadmap   @John @Sarah
```

## Things3 Integration

### Action Items → Tasks

Use the **`things3` tool skill** for all task creation. Include an Obsidian backlink in notes:

```
Created from: [[YYYY-MM-DD [Type] [People] Topic]]

Context: [1-3 sentences from meeting]
```

**Timing:**
- "today", "ASAP", "urgent" → `when: "today"`
- "tomorrow", "next day" → `when: "tomorrow"`
- Specific date mentioned → `when: "YYYY-MM-DD"`
- Otherwise → leave unscheduled (Anytime)

### Add Things3 Tasks Section to Note

**After action items, add:**
```markdown
_Things3 Tasks Created:_

- Schedule Q1 planning follow-up meeting
- Send GIS data to John by EOD

(Tasks created in Things3 with backlinks to this note)
```

This documents what was created without duplicating the task system.

### Enhanced Template Sections (v2)

The enhanced template (`_Templates/Meeting Notes Template v2.md`) adds integration with the memory system:

**Things3 Tasks Section:**
```markdown
## Things3 Tasks

_Tasks created from this meeting (auto-populated by Claude when processing inbox):_

- Task 1 title
- Task 2 title
```

**Related Projects Section:**
```markdown
## Related Projects

- [[project-name]]
```

Links meeting to relevant projects in `Projects/`.

**Related Sessions Section:**
```markdown
## Related Sessions

_Session logs that reference this meeting:_

- [[YYYY-MM-DD-HHmm-session-topic]]
```

Auto-populated when `/compress` links session to this meeting.

**When to use enhanced template:**
- Meeting relates to active project
- Want to track meeting as part of larger work stream
- Need session-to-meeting traceability
- Complex meetings with multiple follow-ups

**When to use simple template:**
- Quick standups
- Simple check-ins
- One-off meetings
- No project context needed

## Complete Example

### Before: Rough Capture

**File:** `+Inbox/standup-jan-30.md`
```
Standup with team this morning

Discussed:
- John working on API integration
- Sarah fixing auth bug
- Blocker: Need database access

Action: Get John database credentials
Action: Review Sarah's PR #123 today
Action: Schedule retro for Friday

Next standup tomorrow
```

### After: Formatted Meeting Note

**File:** `Areas/Work/Meeting notes/2026-01-30 [Standup] [Team] Daily Update.md`
```markdown
TITLE: Standup Team Daily Update

_Pre-notes:_

– Daily team standup meeting

_Meeting Notes:_

– **John**: Working on API integration, progressing well
– **Sarah**: Fixing authentication bug, PR ready for review
– **Blocker**: Team needs database access for testing
– **Next**: Standup tomorrow same time

_Action Items:_

◯ Get John database credentials for testing
◯ Review Sarah's PR #123 today
◯ Schedule retrospective meeting for Friday

_Things3 Tasks Created:_

- Get database credentials for John
- Review PR #123 (Sarah's auth fix)
- Schedule Friday retrospective

(Tasks created in Things3 with backlinks to this note)

#standup #daily-update #team   @John @Sarah
```

**Or with enhanced template v2:**

**File:** `Areas/Work/Meeting notes/2026-01-30 [Standup] [Team] Daily Update.md`
```markdown
---
date: 2026-01-30
time: 9:00 AM - 9:15 AM
tags: [standup, daily-update, team]
people: [John, Sarah]
status: completed
---

# 2026-01-30 [Standup] [Team] Daily Update

**Topic:** Daily team standup meeting

## Discussion

- **John**: Working on API integration, progressing well
- **Sarah**: Fixing authentication bug, PR ready for review
- **Blocker**: Team needs database access for testing
- **Next**: Standup tomorrow same time

## Action Items

- [ ] Get John database credentials for testing
- [ ] Review Sarah's PR #123 today
- [ ] Schedule retrospective meeting for Friday

## Things3 Tasks

_Tasks created from this meeting (auto-populated by Claude when processing inbox):_

- Get database credentials for John (urgent, blocker)
- Review PR #123 (Sarah's auth fix) (today)
- Schedule Friday retrospective (tomorrow)

## Related Projects

- [[obsidian-smart-assistant]]

## Related Sessions

_Session logs that reference this meeting:_

(Auto-populated by /compress when sessions reference this meeting)

---

**Meeting Notes:** Standard daily standup, team is progressing well with some blockers to resolve.
```

### Things3 Tasks Created

**Task 1:**
```
Title: Get database credentials for John
Notes: Created from: [[2026-01-30 [Standup] [Team] Daily Update]]

Context: John needs database access for API integration testing.
When: today
Tags: work, urgent, blocker
```

**Task 2:**
```
Title: Review PR #123 (Sarah's auth fix)
Notes: Created from: [[2026-01-30 [Standup] [Team] Daily Update]]

Sarah's authentication bug fix is ready for code review.
When: today
Tags: work, code-review
```

**Task 3:**
```
Title: Schedule retrospective meeting for Friday
Notes: Created from: [[2026-01-30 [Standup] [Team] Daily Update]]

Team retrospective to discuss sprint and improvements.
When: tomorrow
Tags: work, meeting, planning
```

## Edge Cases

### Unclear Meeting Type

**If type is ambiguous:**
- Check content for clues (standup, 1-on-1, planning keywords)
- Default to `[Meeting]` if unclear
- Ask user if needed

### Multiple Participants

**If many participants:**
- Use "Team" or department name
- Example: `[Engineering Team]`
- Or list key participants: `[John, Sarah, Mike]`

**Best practice:**
- 1-3 people: List names
- 4+ people: Use team/group name

### No Action Items

**If meeting had no action items:**
```
_Action Items:_

◯ (No action items from this meeting)
```

Or omit the section entirely (user preference).

### Recurring Meetings

**For regular meetings:**
- Include date in filename (distinguishes occurrences)
- Can reference previous meeting in notes
- Example: `_Pre-notes:_ – Follow-up from [[2026-01-23 Standup]]`

### Virtual vs In-Person

**Optional notation:**
- Add to pre-notes: `– Format: Virtual (Zoom)`
- Or: `– Format: In-person`
- Not required, but can be useful context

## Template Variables Summary

| Variable | Extract From | Example |
|----------|-------------|---------|
| `{{meeting-type}}` | Content keywords | "Standup", "Meeting", "Planning" |
| `{{primary-contact}}` | Participants mentioned | "John", "Sarah", "Team" |
| `{{meeting-title}}` | Topic/subject | "Q1 Planning", "Daily Update" |
| `{{pre-note-1}}` | Pre-meeting content | Agenda, context, preparation |
| `{{note-1}}` | Main discussion | Discussion points, decisions |
| `{{action-1}}` | Action items | Tasks to be completed |
| `{{tag}}` | Context | "#meeting #project-name" |

## Best Practices

**Do:**
- Extract all action items to Things3
- Use consistent filename format
- Include date for chronological sorting
- Add relevant tags for searchability
- Link back to meeting note from Things3 tasks

**Don't:**
- Skip action item extraction
- Use vague filenames
- Duplicate action items (note + separate file)
- Forget to move from inbox
- Lose original context from rough capture
