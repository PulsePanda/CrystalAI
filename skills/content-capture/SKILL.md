---
name: crystal:content-capture
description: Autonomous passive content idea scanner for the Umbrella Content Engine. Runs on Heart via heartbeat dispatcher — scans session logs, Freshdesk tickets, and daily notes for content-worthy ideas and appends them to the backlogs. Use this skill when the heartbeat triggers a content scan, when Austin says "run the content scanner", "scan for content ideas", "/content-capture", "check for new content candidates", or when any autonomous process needs to feed the content pipeline with fresh ideas from recent activity.
---

# Content Capture

Passively scan sources for content-worthy ideas and feed them into the backlogs.

## Context

This is the passive input funnel for the content pipeline. It runs autonomously on Heart (via heartbeat) and scans three sources for material that could become blog posts or social media content. The goal is to make sure nothing content-worthy slips through the cracks — Austin's daily work generates a constant stream of stories, solutions, and insights that are valuable content if captured.

Capture broadly. Curation happens later during `/content-build`. It's better to capture 10 ideas and skip 7 during build than to miss 3 good ones because the filter was too tight.

## Sources

### 1. Session Logs (`state/sessions/*.md`)

Session logs document everything Austin works on with Claude. Rich source for:
- **Building in public** — automation built, skills created, system architecture decisions
- **War stories** — bugs debugged, unexpected root causes, multi-hour troubleshooting
- **Technical discoveries** — workarounds, tool integrations, patterns that worked

Scan the `## Key Learnings`, `## Solutions & Fixes`, and `## Decisions Made` sections — these are pre-distilled content candidates.

### 2. Freshdesk Tickets (Heart only)

Resolved support tickets contain real problems real school staff hit. The ticket triage state file at `/home/crystalos/.crystalos/ticket-triage-state.json` tracks tickets. Look for:
- Problems that would generalize to other schools
- Recurring issues that indicate a pattern
- Particularly tricky diagnoses where the fix wasn't obvious
- Anything involving security, compliance, or data protection

If the triage state file doesn't exist (running on MacBook), skip this source silently.

### 3. Daily Notes (`Daily Notes/*.md`)

Austin sometimes jots down observations, meeting takeaways, or raw ideas in daily notes. Look for:
- Explicit content ideas ("that could be a post", "write about", "content idea")
- Meeting notes that surfaced interesting problems
- Observations about school IT trends or patterns

## Execution Flow

### Step 1: Load State

Read `Areas/Content/capture-state.json`. If it doesn't exist, create it:

```json
{
  "last_scan": {
    "sessions": "2026-01-01T00:00:00",
    "tickets": "2026-01-01T00:00:00",
    "daily_notes": "2026-01-01T00:00:00"
  },
  "captured_sources": []
}
```

`captured_sources` tracks which specific files/tickets have been processed to prevent duplicates.

### Step 2: Scan Each Source

For each source, find items newer than the last scan timestamp.

**Sessions:** Glob `state/sessions/*.md`, filter by file modification time > `last_scan.sessions`. Read each new session log and look for content candidates.

**Tickets:** Read the triage state file, find tickets resolved since `last_scan.tickets`. If the state file doesn't exist, skip silently.

**Daily notes:** Glob `Daily Notes/*.md`, filter by modification time > `last_scan.daily_notes`. Read each new daily note and look for content candidates.

### Step 3: Extract Ideas

For each content candidate found:

1. **Title** — concise, 5-10 words, descriptive enough to scan in a table
2. **Description** — 2-3 sentences with enough context for `/content-build` to generate a full post without needing to go back to the source
3. **Voice** — classify as umbrella, austin, or both:
   - Building in public, AI/automation, personal stories → austin
   - Company capabilities, service delivery → umbrella
   - General school IT knowledge → both
4. **Source** — `session-scan`, `ticket-scan`, or `daily-scan`

### Step 4: Deduplicate

Before appending, check existing backlog entries. Compare the new idea title against existing titles — if there's a close match (same topic, similar phrasing), skip it. Also check `captured_sources` in the state file to ensure the same source file/ticket isn't processed twice.

### Step 5: Append to Backlogs

For each new idea, append a row to the appropriate backlog file(s):

**File:** `Areas/Content/umbrella/ideas.md` and/or `Areas/Content/austin/ideas.md`

**Format:**
```
| YYYY-MM-DD | Idea title | [source-type] | new | 2-3 sentence description |
```

Use the Edit tool to append rows to the end of the table.

### Step 6: Update State

Update `Areas/Content/capture-state.json`:
- Set all `last_scan` timestamps to now
- Add processed file paths/ticket IDs to `captured_sources`

Keep `captured_sources` trimmed — only retain entries from the last 30 days to prevent the file from growing forever.

### Step 7: Log and Report

Append a summary to `state/operational/heart-log.md`:

```
### YYYY-MM-DD HH:MM — Content Capture
Scanned: [N] sessions, [N] tickets, [N] daily notes
Captured: [N] new ideas ([N] umbrella, [N] austin, [N] both)
Ideas: [list of titles]
```

If nothing was captured, log that too — it's useful to know the scanner ran even if nothing qualified.

## What Qualifies as Content-Worthy

Think like a school IT professional scrolling LinkedIn or Twitter. Would this make them stop and read?

**Strong signals:**
- "I spent [time] figuring out that..." — war story gold
- A problem that multiple schools would hit
- Seasonal relevance (E-Rate deadlines, back-to-school, testing season)
- Security/compliance implications
- Cost savings or efficiency improvements
- Something that contradicts common assumptions
- A process Austin built or improved

**Weak signals (skip these):**
- Routine task completion ("updated DNS records")
- Internal tooling changes with no broader lesson
- Conversations that were purely about project management mechanics
- Things that are too specific to Austin's exact setup to generalize

When in doubt, capture it. Austin can skip it later during `/content-build`. A skipped idea costs nothing; a missed insight is lost forever.

## Edge Cases

- **First run:** No state file exists. Create it, scan the last 7 days of sessions and daily notes (not all-time — that would be overwhelming).
- **Heart down for a while:** The catch-up scan might find a lot of new content. That's fine — capture it all. `/content-build` handles curation.
- **MacBook execution:** Skip Freshdesk source, scan sessions and daily notes normally.
- **Empty scan:** Log it and exit. Don't create noise about "no ideas found."
- **Backlog files don't exist:** Create them with the standard header before appending.
