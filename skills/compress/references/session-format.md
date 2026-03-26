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
- `2026-01-30-1800-gis-data-analysis.md`
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

- **Problem:** Another issue
  **Solution:** Resolution approach
  **Why it worked:** Explanation

## Pending Tasks
- [ ] Task 1 description (Created in Things3)
- [ ] Task 2 description (Created in Things3)
- [ ] Task 3 if Things3 unavailable (Manual add needed)

## Files Modified
- `path/to/file1.md` - Added new section about X
- `path/to/file2.js` - Refactored function Y
- `path/to/file3.ts` - Fixed bug in Z component

## Setup & Configuration
- Installed Things3 MCP server via pipx
- Configured Claude Desktop with MCP endpoint
- Updated permissions in .claude/settings.local.json
- Created helper scripts in scripts/

## Errors & Workarounds
- **Error:** Things3 MCP async coroutine not awaited
  **Cause:** Entry point misconfiguration
  **Fix:** Created __main__.py wrapper with asyncio.run()
  **Prevention:** Verify entry points in pyproject.toml

- **Error:** API connection refused
  **Cause:** Obsidian REST API not running
  **Fix:** Fell back to filesystem access
  **Prevention:** Helper scripts auto-detect and fallback

---

## Raw Session Log

[Complete conversation transcript goes here]

User: [First message]