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
4. Construct URI and open in Obsidian
5. Confirm: `Created: +Inbox/2026-01-30-1430.md — open in Obsidian.`

### User Experience
- Command runs in < 1 second
- Obsidian window opens with new file
- Cursor ready in empty content area
- User immediately types meeting notes

---

## Example 2: Multiple Notes Same Day

### Timeline
```
09:15 AM - /note → +Inbox/2026-01-30-0915.md
11:30 AM - /note → +Inbox/2026-01-30-1130.md
14:45 PM - /note → +Inbox/2026-01-30-1445.md
```

### End of Day
```
User: /process-inbox

Processes all 3 files:
- Standup → Formatted meeting note
- Client call → Formatted meeting note with tasks
- Brainstorm → Work note with ideas
```

---

## Example 3: Conflict Handling

User creates two notes in the same minute (rare but possible).

```
14:30:15 - /note → +Inbox/2026-01-30-1430.md
14:30:45 - /note → +Inbox/2026-01-30-1430-2.md (conflict resolution)
```

Both notes created successfully, no data loss.

---

## Integration Patterns

### Pattern 1: Meeting Capture Flow
```
Before meeting: /note
During meeting: Type in Obsidian
After meeting: Return to assistant
End of day: /process-inbox
Result: Formatted meeting note + tasks
```

### Pattern 2: Idea Capture Flow
```
During work: /note
Quick capture: Type idea
Continue: Return to assistant
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

## Best Practices

**Do:**
- Use /note liberally (it's instant and free)
- Create separate notes for different topics
- Let inbox accumulate during busy periods
- Batch process with /process-inbox

**Don't:**
- Worry about structure during capture
- Try to format perfectly while noting
- Delete inbox notes manually
- Skip creating note to "save time"

**Key Insight:**
Separation of capture (/note) and processing (/process-inbox) enables fast workflow without sacrificing organization.
