# Availability Rules & Scheduling Preferences

Reference for the /calendar-booking skill. Read this before selecting slots to propose.

## Time Zone

The user's timezone should be defined in their config or integration state. All times presented to the user or included in emails must be in their local timezone. Never show UTC, ISO timestamps, or timezone offsets.

When reading calendar data, be aware that some calendar APIs return UTC times that need conversion.

## Recurring Weekly Patterns

These show as calendar events, so the calendar query catches them. Listed here for context when a day looks "open" but isn't really.

**Customize this section** with the user's actual recurring commitments:

| Day | Commitment | Typical Time | Notes |
|-----|-----------|--------------|-------|
| _Example: Tuesday_ | _On-site at office_ | _8:00-12:00_ | _Travel time before/after_ |
| _Example: Thursday_ | _Team standup_ | _9:00-9:30_ | _Recurring weekly_ |

Delete the examples and fill in real patterns. If the user has no recurring patterns, leave this section empty.

## Slot Selection Preferences

### Personal appointments (vet, doctor, errands)
- **Prefer mornings** — easier to fit before work ramps up
- **Best days:** Days without on-site obligations
- **Avoid days with early departures** — morning appointments conflict with early commutes

### Work meetings (vendors, partners, internal calls)
- **Prefer afternoons** — mornings often have on-site or focus-work commitments
- **On-site days:** Can meet on-site if the meeting is related; otherwise schedule around the on-site block

### General rules
- **30-minute buffer** between events — don't schedule back-to-back
- **Default duration:** 30 minutes unless specified otherwise
- **Weekdays only** unless the user explicitly says weekends are OK
- **3-5 options** is the sweet spot — enough choice without overwhelming
- **Spread across days** — don't propose 3 slots on the same day if other days are open

## Presenting Times in Emails

Use natural, conversational language. Match the user's voice.

**Do this:**
- "Wednesday March 18th, anytime works"
- "Friday morning, before noon"
- "Thursday after 1pm"
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
