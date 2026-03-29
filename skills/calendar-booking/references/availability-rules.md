# Availability Rules & Scheduling Preferences

Reference for the /calendar-booking skill. Read this before selecting slots to propose.

## Time Zone Conversion

Calendar events from GWS come with timezone offsets (e.g., `2026-03-17T09:00:00-05:00`). the user is in Central Time (America/Chicago).

| Period | Offset | Example |
|--------|--------|---------|
| CDT (Mar–Nov) | UTC − 5 / `-05:00` | Already local time in GWS output |
| CST (Nov–Mar) | UTC − 6 / `-06:00` | Already local time in GWS output |

Always present times in Central Time. Never show UTC, ISO timestamps, or timezone offsets to the user or in emails.

## Recurring Weekly Patterns

These show as calendar events, so the calendar query catches them. Listed here for context when a day looks "open" but isn't really.

| Day | Commitment | Typical CT | Notes |
|-----|-----------|------------|-------|
| Tuesday | GIS on-site | ~7:30–10:30 AM | the user leaves home at 6:30 AM |
| Thursday | GIS on-site | ~7:30–10:30 AM | Same pattern |
| Monday | GIS on-site | ~7:30–10:30 AM | Same pattern |
| Varies | SJA (Jesse) | Check calendar | Jesse's on-site days vary |
| Bi-weekly Thu | Operations Meeting | 9:30–10:30 AM | Alternating Thursdays |

## Slot Selection Preferences

### Personal appointments (vet, doctor, errands)
- **Prefer mornings** — easier to fit before work ramps up
- **Best days:** Days without on-site obligations, or where on-site is afternoon-only
- **Avoid Tuesdays** — early departure (6:30 AM) makes morning appointments tight
- **School breaks and PD days** are more flexible — the user isn't on-site

### Work meetings (vendors, partners, internal calls)
- **Prefer afternoons** — mornings often have on-site commitments
- **On-site days:** Can meet at GIS if the meeting is GIS-related; otherwise schedule around the on-site block
- **Ops meeting weeks:** Thursday afternoon is tighter (bi-weekly)

### General rules
- **30-minute buffer** between events — don't schedule back-to-back
- **Default duration:** 30 minutes unless specified otherwise
- **Weekdays only** unless the user explicitly says weekends are OK
- **3–5 options** is the sweet spot — enough choice without overwhelming
- **Spread across days** — don't propose 3 slots on the same day if other days are open

## Presenting Times in Emails

Use natural, conversational language. Match the user's voice — casual, not corporate.

**Do this:**
- "Wednesday March 18th, anytime works"
- "Friday morning, before noon"
- "Thursday after 1pm CT"
- "Any day the week of April 6th — I have a pretty open week"
- "Monday or Wednesday morning would be ideal"

**Not this:**
- "2026-03-18T00:00:00"
- "I have availability on 03/18, 03/20, and 03/27"
- "Please select from the following time slots: 9:00 AM, 10:00 AM, 11:00 AM"
- "I am available during the following windows..."

When a full day is genuinely open, say "anytime" rather than listing every hour. When most of a day is open with one small commitment, just say the day works — only mention the exception if the recipient might try to book during that specific block.

## Edge Cases

- **Same-day scheduling:** If the user wants to schedule something today, check what's left on the calendar and propose remaining open blocks.
- **Multi-week timeframes:** Group options by week ("next week I'm pretty open; the week after is tighter — Monday or Friday would work best").
- **Recurring meetings:** If setting up a recurring meeting, find a consistent weekly slot that works across multiple weeks.
- **Vague requests:** If the user just says "schedule something with X" without specifying when, default to checking the next 2 weeks.
