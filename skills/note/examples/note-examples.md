# /note Skill Examples

Real-world usage examples for quick note creation.

## Example 1: Meeting Start

### Scenario
User sits down for a meeting and needs to start taking notes immediately.

### Command
```
User: /note
```

### Action Taken
1. Generate timestamp: 2026-01-30 14:30
2. Create filename: `2026-01-30-1430.md`
3. Create file: `+Inbox/2026-01-30-1430.md`
4. Write content:
```markdown
# Note - 2026-01-30 14:30

Created: 2026-01-30 14:30

---


```
5. Construct URI: `obsidian://open?vault={vault_name}&file=%2BInbox%2F2026-01-30-1430.md`
6. Open with: `open "obsidian://open?vault={vault_name}&file=%2BInbox%2F2026-01-30-1430.md"`

### Result
```
Created: +Inbox/2026-01-30-1430.md
Opened in Obsidian - ready for your notes!
```

### User Experience
- Command runs in < 1 second
- Obsidian window opens with new file
- Cursor ready in empty content area
- User immediately types meeting notes
- No interruption to meeting flow

### Later Processing
```
User: /process-inbox

Claude finds: 2026-01-30-1430.md with meeting content
Claude detects: Meeting note
Claude formats: Applies meeting template
Claude creates: Things3 tasks from action items
Claude moves: To Areas/Work/Meeting notes/2026-01-30 [Meeting] [John] Q1 Planning.md
```

---

## Example 2: Quick Thought During Conversation

### Scenario
User is working with Claude and has a sudden idea to capture.

### Conversation
```
User: "I just realized we could automate the reporting process"
User: /note
Claude: Created: +Inbox/2026-01-30-1515.md
        Opened in Obsidian - ready for your notes!
User: [types idea in Obsidian]
User: "Okay, continuing with our current task..."
```

### Note Content (User Types)
```markdown
# Note - 2026-01-30 15:15

Created: 2026-01-30 15:15

---

Idea: Automate weekly reporting

Could use Python script to:
- Pull data from database
- Generate charts with matplotlib
- Create PDF report
- Email to stakeholders

Saves ~2 hours per week

TODO: Research reporting libraries
```

### Result
- Idea captured without losing conversation context
- User returns immediately to working with Claude
- Note preserved in inbox for later processing
- No disruption to workflow

---

## Example 3: Multiple Notes Same Day

### Scenario
User creates several notes throughout the day.

### Timeline
```
09:15 AM - User: /note (morning standup)
         Created: +Inbox/2026-01-30-0915.md

11:30 AM - User: /note (client call)
         Created: +Inbox/2026-01-30-1130.md

14:45 PM - User: /note (project brainstorm)
         Created: +Inbox/2026-01-30-1445.md

16:00 PM - User: /note (quick reminder)
         Created: +Inbox/2026-01-30-1600.md
```

### Inbox State
```
+Inbox/
├── 2026-01-30-0915.md (standup notes)
├── 2026-01-30-1130.md (client call notes)
├── 2026-01-30-1445.md (brainstorm ideas)
└── 2026-01-30-1600.md (reminder)
```

### End of Day
```
User: /process-inbox

Claude processes all 4 files:
- Standup → Formatted meeting note
- Client call → Formatted meeting note with tasks
- Brainstorm → Work note with ideas
- Reminder → Simple Things3 task

Result: Inbox cleared, all content organized
```

---

## Example 4: Conflict Handling

### Scenario
User creates two notes in the same minute (rare but possible).

### First Note
```
14:30:15 - User: /note
          Created: +Inbox/2026-01-30-1430.md
```

### Second Note (30 seconds later)
```
14:30:45 - User: /note
          Detected: 2026-01-30-1430.md already exists
          Created: +Inbox/2026-01-30-1430-2.md
          (or: 2026-01-30-143045.md with seconds)
```

### Result
- Both notes created successfully
- No overwrites or data loss
- User can use both notes
- Both process normally later

---

## Example 5: Meeting with Pre-Planning

### Before Meeting
```
User: /note
Created: +Inbox/2026-01-30-1400.md
```

### User Types Agenda
```markdown
# Note - 2026-01-30 14:00

Created: 2026-01-30 14:00

---

Meeting with John - Q1 Planning

Agenda:
- Review Q4 results
- Discuss Q1 goals
- Budget allocation
- Timeline concerns

Questions to ask:
- What's the priority?
- Who's on the team?
- What's the deadline?

---

[Meeting notes will go below during the meeting]
```

### During Meeting
User adds notes below the agenda as meeting progresses.

### Result
- Pre-planned agenda captured
- Meeting notes added in real-time
- Complete record of planning + discussion
- Single comprehensive note

---

## Example 6: Scratch Workspace

### Scenario
User needs temporary workspace for calculations or drafting.

### Command
```
User: "I need to work out some calculations"
User: /note
```

### User Types
```markdown
# Note - 2026-01-30 15:30

Created: 2026-01-30 15:30

---

Budget calculations:

Revenue: $500k
Costs:
- Staff: $300k
- Tools: $50k
- Infrastructure: $30k
- Marketing: $40k
Total costs: $420k

Profit: $80k (16% margin)

Looks good for Q1!
```

### Result
- Quick workspace for thinking
- Can be discarded or saved
- Doesn't clutter conversation
- Clean separation of concerns

---

## Example 7: Error - Obsidian Not Installed

### Scenario
User on new system, Obsidian not installed.

### Command
```
User: /note
```

### Action
1. File created successfully: `+Inbox/2026-01-30-1430.md`
2. URI construction succeeds
3. `open` command fails (protocol not recognized)

### Response
```
Created: +Inbox/2026-01-30-1430.md

Note: Could not open in Obsidian automatically.
Is Obsidian installed and configured?

You can open the file manually:
${VAULT_PATH}/+Inbox/2026-01-30-1430.md
```

### Result
- File still created (data preserved)
- User informed of issue
- Can open manually
- Graceful degradation

---

## Example 8: Integration with /compress

### Full Workflow
```
10:00 AM - User: /note
          Created note for meeting

10:05 AM - User types meeting notes in Obsidian

10:45 AM - Meeting ends, user returns to Claude

10:46 AM - User: /compress

          Claude: Analyzes session
          Claude: Notes that +Inbox/2026-01-30-1000.md was created
          Claude: Session log includes: "Created meeting note in inbox"
          Claude: User can process inbox later to format properly
```

### Session Log Includes
```markdown
## Files Created

- +Inbox/2026-01-30-1000.md - Meeting capture note (unprocessed)

Note: Use /process-inbox to format and extract tasks
```

### Result
- Complete workflow documented
- User knows inbox has content
- Clear next step indicated

---

## Example 9: Daily Pattern

### User's Typical Day
```
Morning:
08:00 - /note → Daily planning
09:15 - /note → Standup
10:30 - /note → 1-on-1 with manager
12:00 - /note → Lunch meeting idea

Afternoon:
14:00 - /note → Client call
15:30 - /note → Project brainstorm
16:45 - /note → Quick reminder

End of Day:
17:30 - /process-inbox → Process all 7 notes
        - 4 meetings → Formatted
        - 2 ideas → Filed
        - 1 reminder → Things3 task
```

### Result
- Fast capture throughout day
- No structure needed during capture
- Batch processing at end of day
- Everything organized and actionable

---

## Command Variations

### Explicit Request
```
User: "Create a new note"
→ Triggers /note skill
→ Creates and opens note
```

### Direct Skill Call
```
User: /note
→ Most direct
→ Fastest invocation
```

### With Context
```
User: "I'm starting a meeting, create a note"
→ Triggers /note skill
→ User immediately types meeting notes
```

### Multiple Times
```
User: /note
[time passes]
User: /note
[time passes]
User: /note

Result: 3 separate timestamped notes
All in inbox for processing
```

---

## Integration Patterns

### Pattern 1: Meeting Capture Flow
```
Before meeting: /note
During meeting: Type in Obsidian
After meeting: Return to Claude
End of day: /process-inbox
Result: Formatted meeting note + Things3 tasks
```

### Pattern 2: Idea Capture Flow
```
During work: /note
Quick capture: Type idea
Continue: Return to Claude
Later: /process-inbox
Result: Idea filed appropriately
```

### Pattern 3: Daily Batch Flow
```
Throughout day: /note (multiple times)
End of day: /process-inbox
Next morning: /resume (shows processed content)
Result: Full daily cycle complete
```

### Pattern 4: Research Flow
```
User: /note
User: Types research findings
User: Continues research with Claude
User: /compress (session saved)
User: /process-inbox (research filed)
Result: Research documented and organized
```

---

## Performance Benchmarks

### Typical Timing
```
File creation: 5-10ms
URI construction: < 1ms
Opening Obsidian: 200-500ms
User ready to type: < 1 second
Total operation: < 1 second
```

### User Experience
- Feels instant
- No perceptible delay
- Obsidian opens smoothly
- Cursor ready immediately
- Seamless workflow

---

## Best Practices from Examples

**Do:**
- Use /note liberally (it's instant and free)
- Create separate notes for different topics
- Let inbox accumulate during busy periods
- Batch process with /process-inbox
- Trust the timestamp filename format

**Don't:**
- Worry about structure during capture
- Try to format perfectly while noting
- Delete inbox notes manually
- Skip creating note to "save time"
- Overthink the capture process

**Key Insight:**
Separation of capture (/note) and processing (/process-inbox) enables fast workflow without sacrificing organization.
