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

– Daily team standup

_Meeting Notes:_

– **John**: API integration work is progressing well
– **Sarah**: Authentication bug fix completed
– **Austin**: Working on documentation updates

_Action Items:_

◯ Review Sarah's PR for auth bug fix
◯ Update roadmap documentation

_Things3 Tasks Created:_

- Review Sarah's PR (auth fix)
- Update project roadmap document

#standup #team   @John @Sarah
```

### Things3 Tasks
- "Review Sarah's PR (auth fix)" - when: today, tags: [work, code-review]
- "Update project roadmap document" - tags: [work, documentation]

### Result
✓ Formatted meeting note moved to proper location
✓ 2 tasks created in Things3 with backlinks
✓ Inbox file deleted

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
2. **Type**: Personal task/reminder
3. **Ask user**: "Create as Things3 task or keep as note?"
4. **User chooses**: Things3 task

### Things3 Task Created
```
Title: Buy pottery wheel for wife's birthday
Notes: She mentioned wanting to get back into pottery.
Budget around $300. Check reviews online first.
Tags: personal, gifts, birthday
When: (unscheduled - user can set deadline)
```

### Result
✓ Things3 task created with full context
✓ Inbox file deleted
✓ No note file needed (content captured in task)

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
Can handle dynamic content and scripts
```

### Processing
1. **Detected**: Work note (technical content, research)
2. **Type**: Research/reference
3. **No action items** found
4. **Destination**: Areas/Work/Research/

### After: Moved Note
**File:** `Areas/Work/Research/vault-automation-tools.md`
```markdown
# Vault Automation Tools Research

Looked into several options for automating vault management:

## Options Evaluated

1. **Templater** - Powerful template engine
   - Can handle dynamic content
   - Supports scripting
   - Most promising for our use case

2. **Dataview** - Query language for vault
   - Great for data aggregation
   - Live queries in notes

3. **QuickAdd** - Rapid note creation
   - Fast capture workflows
   - Macro support

## Recommendation

Templater appears most suitable for dynamic content generation and vault automation needs.
```

### Result
✓ Note moved to work research area
✓ Content lightly formatted for readability
✓ No tasks created (informational only)
✓ Inbox file deleted

---

## Example 4: Simple Task

### Before: Inbox File
**File:** `+Inbox/dentist-reminder.md`
```markdown
Call dentist to schedule checkup
```

### Processing
1. **Detected**: Simple task (one line, single action)
2. **Type**: Personal task
3. **No note needed** (just an action item)

### Things3 Task Created
```
Title: Call dentist to schedule checkup
Tags: personal, health, phone-call
```

### Result
✓ Things3 task created
✓ Inbox file deleted
✓ No note file created (too simple for reference)

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

### After Processing

**Item 1 - Meeting prep task:**
```
Things3 Task: "Prepare slides for Q1 meeting with John"
When: today
Tags: work, meeting, preparation
Notes: Meeting tomorrow with John about Q1 planning
```

**Item 2 - Personal task:**
```
Things3 Task: "Buy pottery wheel for wife"
Tags: personal, gifts
```

**Item 3 - Research note:**
```
File: Areas/Work/Research/vault-automation.md
Content: Research automation tools for vault management
```

### Result
✓ Split into 3 separate items
✓ 2 Things3 tasks created
✓ 1 research note created
✓ Original inbox file deleted

---

## Example 6: Client Meeting

### Before: Inbox File
**File:** `+Inbox/acme-kickoff.md`
```markdown
Kickoff call with Acme Corp

Attendees: Susan (CEO), Mike (CTO), me

Discussed:
- Project scope and timeline
- Technical requirements
- Budget: $50k approved
- Start date: Feb 1

Action items:
- Send proposal document
- Schedule technical deep-dive
- Set up project workspace
```

### Processing
1. **Detected**: Client meeting (company name, formal structure)
2. **Meeting type**: Client kickoff
3. **Participants**: Acme Corp (Susan, Mike)
4. **Topic**: Project Kickoff

### After: Formatted Note
**File:** `Areas/Work/Meeting notes/2026-01-30 [Client] [Acme Corp] Project Kickoff.md`
```markdown
TITLE: Client Acme Corp Project Kickoff

_Pre-notes:_

– Kickoff call with Acme Corp leadership
– Attendees: Susan (CEO), Mike (CTO)

_Meeting Notes:_

– **Project Scope**: Discussed overall scope and timeline
– **Technical Requirements**: Reviewed technical needs
– **Budget**: $50,000 approved for project
– **Start Date**: February 1, 2026
– **Next Steps**: Proposal review and technical deep-dive

_Action Items:_

◯ Send proposal document to Susan
◯ Schedule technical deep-dive with Mike
◯ Set up project workspace (Slack, repos, etc.)

_Things3 Tasks Created:_

- Send project proposal to Acme Corp
- Schedule technical deep-dive with Acme CTO
- Set up Acme project workspace

#client #project-kickoff #acme   @Susan @Mike
```

### Things3 Tasks
- "Send project proposal to Acme Corp" - when: today, tags: [work, client, urgent]
- "Schedule technical deep-dive with Acme CTO" - when: tomorrow, tags: [work, client, meeting]
- "Set up Acme project workspace" - tags: [work, setup, acme]

### Result
✓ Professional client meeting note formatted
✓ 3 tasks created in Things3 with context
✓ Proper categorization with client tag
✓ Inbox file deleted

---

## Example 7: Project Idea

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

Could really help with visibility
```

### Processing
1. **Detected**: Project idea (multi-phase initiative, significant scope)
2. **Type**: New project
3. **Action**: Create project file from template

### After: Project File Created
**File:** `_System/Projects/analytics-dashboard.md`
```markdown
# Analytics Dashboard
Status: Planning
Started: 2026-01-30

## Overview
Build internal analytics dashboard to visualize team metrics and improve visibility into project status.

## Goals
- Track PR velocity for development team
- Show bug trends over time
- Display current project status
- Generate automated weekly reports

## Technical Approach
- Frontend: React
- Visualization: D3.js
- Data source: GitHub API + Jira
- Deployment: Internal server

## Timeline
Estimated 6-8 weeks for initial version

## Current State
**Planning phase**:
- Concept defined
- Tech stack selected
- Next: Create detailed requirements and wireframes

## Things3 Tasks
- Define detailed requirements for dashboard
- Create wireframes for dashboard layout
- Set up development environment

## Related Notes
- Created from inbox capture: 2026-01-30

## Related Sessions
- (Will be populated as work progresses)
```

### Things3 Tasks Created
- "Define analytics dashboard requirements" - tags: [work, analytics-dashboard, planning]
- "Create dashboard wireframes" - tags: [work, analytics-dashboard, design]
- "Set up dashboard dev environment" - tags: [work, analytics-dashboard, setup]

### Result
✓ Full project file created in _System/Projects/
✓ 3 initial tasks created in Things3
✓ Project ready for tracking
✓ Inbox file deleted

---

## Example 8: Empty File

### Before: Inbox File
**File:** `+Inbox/untitled.md`
```markdown


```
(File is empty or only whitespace)

### Processing
1. **Detected**: Empty file
2. **Ask user**: "This file appears empty. Delete it?"
3. **User confirms**: Yes

### Result
✓ Empty file deleted from inbox
✓ No other action taken

---

## Example 9: Ambiguous Content

### Before: Inbox File
**File:** `+Inbox/productivity-book.md`
```markdown
Read "Atomic Habits" by James Clear

Book about building better systems and habits
Could help with personal productivity
Also relevant for team processes
```

### Processing
1. **Detected**: Ambiguous (could be personal or work)
2. **Indicators**:
   - Personal: "personal productivity"
   - Work: "team processes"
3. **Confidence**: Low
4. **Ask user**: "Is this personal or work-related?"
5. **User responds**: "Personal"

### After: Personal Note or Task
**User chooses**: Create as Things3 task

### Things3 Task Created
```
Title: Read "Atomic Habits" by James Clear
Notes: Book about building better systems and habits.
Focus on personal productivity improvement.
Tags: personal, reading, self-improvement
When: someday
```

### Result
✓ User clarified ambiguous categorization
✓ Things3 task created with personal tags
✓ Inbox file deleted

---

## Example 10: Very Long Capture

### Before: Inbox File
**File:** `+Inbox/conference-notes.md`
```markdown
Notes from Developer Conference 2026

[... 300 lines of detailed notes ...]

Keynote highlights:
- AI integration trends
- Cloud architecture patterns
- Security best practices

Workshop sessions:
- Advanced Git workflows
- Microservices at scale
- Database optimization

[... continues for many more lines ...]
```

### Processing
1. **Detected**: Very long file (>300 lines)
2. **Alert user**: "This is a large capture (conference notes)"
3. **Options presented**:
   - Process normally
   - Split into multiple topic notes
   - Keep in inbox for manual review
4. **User chooses**: Split by topic

### After: Multiple Notes Created

**File 1:** `Areas/Work/Conferences/dev-conf-2026-keynote.md`
**File 2:** `Areas/Work/Conferences/dev-conf-2026-workshops.md`
**File 3:** `Areas/Work/Reference/git-advanced-workflows.md`

### Result
✓ Large capture split into focused topic notes
✓ Each note filed appropriately
✓ Original inbox file deleted
✓ Content preserved and organized

---

## Common Patterns Summary

### Meeting Capture Pattern
```
Inbox capture with:
- Meeting participants mentioned
- Discussion points
- Action items

→ Format with template
→ Extract tasks to Things3
→ Move to Meeting notes/
```

### Simple Task Pattern
```
Inbox capture with:
- 1-2 lines
- Single action
- No context needed

→ Create Things3 task
→ Delete inbox file
```

### Personal Note Pattern
```
Inbox capture with:
- Personal keywords
- Home/family context
- Non-work topic

→ Ask: Task or note?
→ Create accordingly
→ Tag as personal
```

### Work Note Pattern
```
Inbox capture with:
- Technical content
- Research or analysis
- Reference information

→ Move to Areas/Work/
→ Light formatting
→ Preserve as reference
```

### Project Idea Pattern
```
Inbox capture with:
- Multi-phase initiative
- Significant scope
- Goals and plans

→ Create project file
→ Generate initial tasks
→ Move to _System/Projects/
```

### Multi-Item Pattern
```
Inbox capture with:
- Multiple distinct items
- Different categories
- Separated sections

→ Ask to split
→ Process each separately
→ Delete original
```
