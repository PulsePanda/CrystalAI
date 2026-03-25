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
│     └─ Extract action items → Things3
│        └─ Move to Areas/Work/Meeting notes/
│
└─ No → Continue...
   │
   Is it a single actionable task?
   ├─ Yes → Simple Task
   │  └─ Create in Things3
   │     └─ Delete inbox file
   │
   └─ No → Continue...
      │
      Is it personal content?
      ├─ Yes → Personal Note
      │  └─ Ask: Keep as note or create task?
      │     ├─ Note → Move to Areas/Personal/
      │     └─ Task → Create in Things3, delete file
      │
      └─ No → Continue...
         │
         Is it a project idea?
         ├─ Yes → Project Idea
         │  └─ Create project file from template
         │     └─ Move to _System/Projects/
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
- Format like: "meeting-john-2026-01-30"

**Content indicators (high confidence):**
```
Strong signals:
- "Meeting with [names]"
- "Standup with [team]"
- "Call with [person/company]"
- "Discussed:", "Agenda:", "Action:"
- Multiple speakers quoted
- Lists of topics + decisions + action items

Example:
Meeting with John and Sarah
- Discussed Q1 planning
- Decision: Use new process
- Action: Follow up next week
```

**Content indicators (medium confidence):**
```
Moderate signals:
- Multiple bullet points about discussion
- References to "we", "team", "discussed"
- Action items mixed with notes
- Date/time mentioned

Example:
Had sync with team
Covered the new features
Need to follow up on bugs
```

**When to ask user:**
- Confidence is low or ambiguous
- Could be meeting or work note
- Person mentioned but no clear meeting context

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
- "Renew license plate registration"
```

**Characteristics:**
- Short (< 50 words typically)
- No background information
- Just the action to take
- Doesn't need to be a note for reference

**Counter-indicators (NOT a simple task):**
```
- Has explanation or context
- Multiple related items
- Needs to be referenced later
- Part of larger topic

Example NOT a simple task:
"Update documentation
Need to add the new API endpoints
Reference the changes from PR #123
Should include examples"
```

### Personal Notes Detection

**Keyword indicators:**
```
Strong signals:
- "gift idea", "birthday", "anniversary"
- "vacation", "trip", "travel plans"
- "home", "house", "garden"
- "family", "spouse", "wife", "husband", "kids"
- "personal", "hobby", "interest"

Examples:
- "Gift for wife - pottery wheel"
- "Vacation ideas for summer"
- "Home improvement projects"
```

**Content patterns:**
```
Personal references:
- First person possessive: "my wife", "my home", "my hobby"
- Family members mentioned
- Personal activities: reading, hobbies, fitness
- Non-work purchases or plans

Example:
Weekend project ideas:
- Organize garage
- Plant vegetable garden
- Read that productivity book
```

**Work vs Personal ambiguity:**
```
Could be either:
- "Read [book about work topic]" → Could be professional development
- "Research [topic]" → Could be work or personal interest
- "Call [person]" → Context determines work vs personal

Resolution:
- Check for work indicators (projects, colleagues, company names)
- Check for personal indicators (home, family, hobbies)
- Ask user if still ambiguous
```

### Project Idea Detection

**Content patterns:**
```
Strong signals:
- "Project idea:", "New project:"
- Describes a multi-step initiative
- Has goals or objectives
- Significant scope (not just a task)

Examples:
- "Project idea: Build automation for daily reports"
- "New project - Organize photo library"
- "Website redesign concept"
```

**Characteristics:**
- Substantial effort involved
- Multiple phases or components
- Would benefit from tracking
- Not just a single task

**Distinguish from simple task:**
```
Simple task:
"Update the website header"

Project idea:
"Website redesign project
- New responsive layout
- Update branding
- Improve navigation
- Add blog section"
```

### Work Notes Detection

**This is the default category** when:
- Not meeting notes
- Not personal
- Not a simple task
- Not a project idea

**Typical content:**
```
- Technical notes
- Research findings
- Documentation drafts
- Analysis or thoughts
- Reference information

Examples:
- "Notes on API design patterns"
- "Research findings on database optimization"
- "Ideas for improving the build process"
```

**Subcategorization within Work:**
```
Common subcategories:
- Research → Areas/Work/Research/
- Documentation → Areas/Work/Docs/
- Technical notes → Areas/Work/Technical/
- General → Areas/Work/

Note: Create subcategories as needed
```

## Destination Mapping

### Meeting Notes
```
Source: +Inbox/meeting-capture.md
Destination: Areas/Work/Meeting notes/YYYY-MM-DD [Format] [People] Topic.md

Format types:
- [Standup] - Daily standup
- [Meeting] - General meeting
- [1-on-1] - One-on-one meeting
- [Client] - Client meeting
- [Planning] - Planning session
- [Retro] - Retrospective

Filename generation:
1. Extract or ask for: date, format, people, topic
2. Format: YYYY-MM-DD [Format] [Names] Topic.md
3. Ensure valid filename (no special characters)
```

### Personal Notes
```
Option 1 - Keep as note:
Source: +Inbox/personal-idea.md
Destination: Areas/Personal/[subcategory]/filename.md

Subcategories:
- Ideas/ - Thoughts and ideas
- Projects/ - Personal projects
- Reference/ - Reference material
- [Custom] - User-defined categories

Option 2 - Convert to task:
Create in Things3 with "personal" tag
Delete inbox file
```

### Work Notes
```
Source: +Inbox/work-note.md
Destination: Areas/Work/[subcategory]/filename.md

Subcategories:
- Research/ - Research findings
- Documentation/ - Docs and guides
- Technical/ - Technical notes
- Projects/ - Project-specific (if doesn't warrant _System/Projects/)
- [Root] - General work notes

Filename:
- Keep original name or improve clarity
- Use descriptive, searchable names
- Lowercase-hyphenated recommended
```

### Project Ideas
```
Source: +Inbox/project-idea.md
Destination: _System/Projects/project-name.md

Process:
1. Read project template: _System/Projects/_template.md
2. Extract information from inbox capture
3. Populate template fields
4. Generate filename from project title
5. Create project file
6. Delete inbox file
```

### Simple Tasks
```
Source: +Inbox/simple-task.md
Destination: Things3 (no file kept)

Process:
1. Extract task title from content
2. Determine timing (today, tomorrow, or unscheduled)
3. Assign appropriate tags
4. Create in Things3
5. Delete inbox file (content now in Things3)
```

## Multi-Item Files

**When one inbox file contains multiple unrelated items:**

### Detection
```
Indicators:
- Multiple distinct topics
- Separated by blank lines or headers
- Different content types mixed
- Numbered list of unrelated items

Example:
1. Meeting tomorrow with John
2. Gift idea for wife
3. Research automation tools
```

### Handling Options

**Option 1: Split into separate items**
```
Process each item according to its type:
- Item 1 → Meeting prep task in Things3
- Item 2 → Personal note or task
- Item 3 → Work note in Areas/Work/

Delete original inbox file after all processed
```

**Option 2: Keep together with primary categorization**
```
If items are loosely related:
- Determine primary category
- Keep all items in one note
- Extract any tasks to Things3
- File under primary category
```

**Option 3: Ask user preference**
```
Present the items:
"This file contains 3 different items:
1. Meeting topic
2. Personal idea
3. Work research

Would you like to:
A) Split into separate notes/tasks
B) Keep together in [category]
C) Let me decide for each item"
```

## Edge Cases

### Empty or Nearly Empty Files

**Detection:**
- File has < 10 characters
- Only whitespace or single word
- No meaningful content

**Action:**
- Ask: "This file appears empty. Delete it?"
- If yes, delete
- If no, ask what to do with it

### Duplicate Content

**Detection:**
- Content matches existing note
- Similar filename exists in destination
- Same topic recently captured

**Action:**
- Alert user: "Similar note exists at [location]"
- Options:
  - Merge with existing
  - Keep as separate note
  - Discard duplicate

### Unclear or Ambiguous

**When categorization is uncertain:**

```
Signals of ambiguity:
- Mixed work/personal indicators
- Could be meeting or work note
- Could be task or note
- Multiple valid interpretations

Action:
- Present options to user
- Explain why it's ambiguous
- Let user choose categorization
- Learn from user's choice
```

### Very Long Captures

**Detection:**
- File > 500 lines
- Large amount of pasted content
- Multiple distinct sections

**Action:**
- Alert user: "This is a large capture"
- Options:
  - Process normally
  - Split into multiple notes
  - Keep in inbox for manual review

## Learning from User Choices

**Track patterns:**
- How user categorizes ambiguous content
- Preferences for personal vs work
- Custom subcategories created
- Task vs note preferences

**Apply learning:**
- Use past decisions for similar content
- Suggest categorization based on history
- Adapt to user's workflow patterns

## Confidence Levels

**High confidence (auto-process):**
- Clear indicators present
- Matches known patterns exactly
- No ambiguity

**Medium confidence (suggest):**
- Some indicators present
- Likely category identified
- Present plan for user approval

**Low confidence (ask):**
- Ambiguous or mixed signals
- Multiple valid interpretations
- No clear pattern match

## Examples

### Example 1: Clear Meeting Note
```
File: "standup-2026-01-30.md"
Content:
Standup with team
- John: Working on API
- Sarah: Bug fixes
- Action: Review PR

Analysis:
- Filename: "standup" keyword → Meeting
- Content: "with team", action items → Confirmed meeting
- Confidence: High
- Decision: Format as meeting note
```

### Example 2: Ambiguous Content
```
File: "productivity-book.md"
Content:
Read "Atomic Habits" book
Good for building better systems

Analysis:
- Could be personal (self-improvement)
- Could be work (professional development)
- No clear work/personal indicators
- Confidence: Low
- Decision: Ask user "Is this personal or work-related?"
```

### Example 3: Simple Task
```
File: "dentist.md"
Content:
Call dentist for checkup

Analysis:
- Very brief (4 words)
- Single action
- No context needed
- Confidence: High
- Decision: Create Things3 task, delete file
```

### Example 4: Multi-Item
```
File: "various.md"
Content:
- Meeting tomorrow: Q1 planning
- Gift: pottery wheel
- Research: automation tools

Analysis:
- Three distinct items
- Different categories
- Confidence: High (for each item separately)
- Decision: Ask to split, then process:
  1. Meeting prep task
  2. Personal task/note
  3. Work research note
```
