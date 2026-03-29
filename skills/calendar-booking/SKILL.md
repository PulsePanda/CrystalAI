---
name: crystal:calendar-booking
description: "ALWAYS use this skill when the task involves creating a NEW calendar entry or checking availability in order to plan something. This includes: booking/scheduling any meeting, appointment, call, or event (work or personal); drafting any email that proposes specific dates or times to someone else; blocking off new time on the calendar; checking when you're free ('when am I free', 'what days work', 'do I have time') to plan anything — a meeting, vet appointment, vendor visit, personal errand; or putting something new on the calendar even conditionally ('put this on my calendar once he confirms', 'add that once we have a date'). Trigger on: 'set up a call', 'book time', 'put this on my calendar', 'block off time', 'find a time', 'when am I free', 'draft with my availability', 'get something scheduled'. Do NOT trigger for: pure calendar reads ('what's on my calendar', 'show my schedule', 'what meetings do I have'); modifying or moving existing events ('move this to Wednesday', 'reschedule this to next week', 'change the time'); or canceling events — all of those go to /calendar directly."
version: 1.0.0
allowed-tools: Bash, Read, Write, Edit
---

# /calendar-booking — Calendar-Aware Scheduling

Schedule meetings, appointments, and calls using the user's real calendar availability. This skill is the bridge between "I need to set something up" and the actual email draft or calendar event — it makes sure proposed times are actually open.

## Why This Exists

Scheduling emails without checking the calendar first are useless — they create extra round-trips when proposed times don't work. This skill always checks availability first, then acts.

## Usage

```
/calendar-booking [what to schedule]
```

## Workflow

### Step 1: Parse the Request

Extract from the user's message:
- **What:** meeting, appointment, call, etc.
- **Who:** the other party (person, org, email if known)
- **Duration:** how long (default 30 min if unspecified)
- **Timeframe:** when to look (default: next 2 weeks if unspecified)
- **Constraints:** morning only, after 2pm, specific days, etc.
- **Action needed:** email outreach, direct event creation, or just report availability

### Step 2: Pull Calendar via /calendar Skill

Invoke the **calendar** tool skill to query events across the full timeframe. Read `references/availability-rules.md` for the user's recurring patterns, time zone conversion, and slot preferences — these shape which slots to propose.

Key rules (details in the reference file):
- Filter to the user's calendars only — exclude PUBLIC, resource, Chromebook, and INTERNAL Staff calendars
- All mcp-ical times are UTC — convert to Central Time before presenting
- Never call GWS calendar commands directly — always go through the /calendar skill

### Step 3: Analyze Open Slots

Build a picture of availability:
1. Map all existing events across the timeframe
2. Overlay the user's recurring constraints (on-site days, typical patterns from the reference file)
3. Apply any user-specified constraints
4. Select the best 3-5 slots to propose

The reference file has detailed preferences for slot selection — mornings for personal appointments, afternoons for work meetings, buffer time between events, and so on. Read it before selecting slots.

Also read `references/scheduling-preferences.md` — this contains learned preferences from the user's past corrections (person-specific timing, day-of-week rules, duration defaults, etc.). These take priority over the general rules in availability-rules.md when they conflict.

### Step 4: Take Action

**Drafting an email** (scheduling with external parties):
- Invoke the **/write** skill with the scheduling context — recipient, what's being scheduled, and the open slots to include
- /write handles creating the Apple Mail draft
- Format times naturally: "Wednesday March 18th, anytime" or "Thursday after 1pm" — never ISO timestamps

**Creating a calendar event** (time already confirmed):
- Invoke the **/calendar** skill to create the event on the appropriate calendar
- Confirm with one line: "Event created — [title] on [date] at [time] on [calendar]"

**Reporting availability** ("when am I free"):
- Present open slots grouped by day
- Note relevant context ("Thursday morning is open but you're on-site at GIS in the afternoon")

### Step 5: Follow-Up Task

When the scheduling requires a response from the other party, invoke the **/things3** skill to create a follow-up task:
- Title: "Follow up: [scheduling context]"
- Due date: 3-5 business days out
- Notes: who to follow up with, how to reach them, what was proposed

### Step 6: Learn from Corrections

When the user corrects a scheduling decision — changes the proposed times, overrides a slot preference, specifies a new constraint — extract the underlying preference and save it to `references/scheduling-preferences.md` under the appropriate section.

This is how the skill gets smarter over time. Examples of corrections that become preferences:
- "No, not mornings for vendor calls" → Time-of-Day: vendor calls in afternoons only
- "I always meet Kim at the school" → Person/Org-Specific: meetings with Kim → at GIS, on-site days
- "Make it an hour for SpectrumVOIP" → Duration: SpectrumVOIP calls default to 60 min
- "Don't book anything on Fridays" → Day-of-Week: Fridays blocked

After saving, confirm briefly: "Got it — saved that preference for next time."
