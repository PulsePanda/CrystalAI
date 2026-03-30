# Session Log Format Specification

Complete specification for session log file structure and content.

## Filename Convention

**Format:** `YYYY-MM-DD-HHmm-topic.md`

**Components:**
- `YYYY-MM-DD` - Date of session (ISO 8601)
- `HHmm` - Time in 24-hour format (e.g., 1630 for 4:30 PM)
- `topic` - Brief description (2-4 words, lowercase, hyphenated)

**Examples:**
- `2026-01-30-1630-obsidian-setup.md`
- `2026-01-30-1730-meeting-processing.md`
- `2026-01-31-0930-bug-fix-auth.md`

## File Structure

### Complete Template

```markdown
# Session: YYYY-MM-DD HH:MM - topic-description

## Quick Reference
**Topics:** keyword1, keyword2, keyword3
**Projects:** Project-Name, Another-Project
**Outcome:** One-sentence summary of what was accomplished

## Decisions Made
- Decision 1 with brief rationale
- Decision 2 with context
- Why this approach was chosen over alternatives

## Key Learnings
- Non-obvious insight 1
- Pattern discovered 2
- Understanding gained 3
- Context about why this matters

## Solutions & Fixes
- **Problem:** Description of issue
  **Solution:** How it was resolved
  **Why it worked:** Technical or logical reasoning

## Pending Tasks
- [ ] Task 1 description (Created in task manager)
- [ ] Task 2 description (Created in task manager)
- [ ] Task 3 description (Manual add needed)

## Files Modified
- `path/to/file1.md` - Added new section about X
- `path/to/file2.js` - Refactored function Y

## Setup & Configuration
- Installed X via Y
- Configured Z with settings
- Updated permissions for W

## Errors & Workarounds
- **Error:** Description of error
  **Cause:** Root cause
  **Fix:** What resolved it
  **Prevention:** How to avoid in future

---

## Raw Session Log

[Complete conversation transcript goes here]

User: [First message]
```
