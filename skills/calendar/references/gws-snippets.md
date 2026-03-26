# GWS Calendar CLI Snippets

Ready-to-use bash commands. All require `dangerouslyDisableSandbox: true`.

## Setup Variables (copy these to the top of any multi-command block)

```bash
GWS="/Users/Austin/Documents/GitHub/CrystalAI/scripts/gws-mac.sh"
EXCLUDE="INTERNAL Staff Calendar|PUBLIC Twin Cities|Chromebook Cart|Room Reservations|Holidays in United States|US Holidays|Brendan Work|Work"

# Calendar IDs (for non-primary calendars — use with --calendar or calendarId param)
CAL_GIS="c_f1ae8b8d099f2af9b4843a78bfd64baa88dc10d005cc264b5d61571fc3bf6cd0@group.calendar.google.com"
CAL_SJA="c_02de9857eb1153947b77619b0e153c1a852cba7b5c90eb47eea982ffd7aa9311@group.calendar.google.com"
CAL_UMB_INTERNAL="c_c60d9c87c48e881b5cc91fef734965db41495bcb22a00a7134a36f409e7a5de5@group.calendar.google.com"
# Primary calendars: gis=avanalstyne@germanschool-mn.org, umb=austin@umbrellasystems.net,
#   personal=ajv857@gmail.com, kesa=austin@kesa.pro (use "primary" in params)
```

---

## List Today's Events (Single Account)

```bash
"$GWS" gis calendar +agenda --today --format table 2>/dev/null
```

## List Events for Date Range

```bash
"$GWS" umb calendar events list --params '{"calendarId":"primary","timeMin":"2026-03-17T00:00:00-05:00","timeMax":"2026-03-18T00:00:00-05:00","singleEvents":true,"orderBy":"startTime"}' --format table 2>/dev/null
```

## List All of Austin's Events Today (Parallel)

```bash
for acct in gis umb personal kesa; do
  "$GWS" "$acct" calendar +agenda --today --format table 2>/dev/null &
done
wait
```

Filter output to exclude: `INTERNAL Staff Calendar TCGIS`, `PUBLIC Twin Cities German Immersion School`, Chromebook carts, room reservations, holiday calendars.

## List Events for Specific Calendar

```bash
"$GWS" umb calendar +agenda --today --calendar "GIS" --format table 2>/dev/null
```

Or by calendar ID:
```bash
"$GWS" umb calendar events list --params '{"calendarId":"c_f1ae8b8d099f2af9b4843a78bfd64baa88dc10d005cc264b5d61571fc3bf6cd0@group.calendar.google.com","timeMin":"2026-03-17T00:00:00-05:00","timeMax":"2026-03-18T00:00:00-05:00","singleEvents":true,"orderBy":"startTime"}' 2>/dev/null
```

## List Available Calendars

```bash
"$GWS" umb calendar calendarList list --format table 2>/dev/null
```

---

## Create Event (Helper)

```bash
"$GWS" personal calendar +insert \
  --summary "Dentist appointment" \
  --start "2026-03-20T14:00:00-05:00" \
  --end "2026-03-20T15:00:00-05:00" \
  --location "123 Main St" \
  --description "Cleaning + checkup" \
  2>/dev/null
```

Times must be RFC 3339 (ISO 8601 with timezone offset). Austin is `America/Chicago` (CDT = `-05:00`, CST = `-06:00`).

## Create Event on Non-Primary Calendar

```bash
"$GWS" umb calendar +insert \
  --calendar "c_f1ae8b8d099f2af9b4843a78bfd64baa88dc10d005cc264b5d61571fc3bf6cd0@group.calendar.google.com" \
  --summary "Camera install" \
  --start "2026-03-20T08:00:00-05:00" \
  --end "2026-03-20T09:00:00-05:00" \
  2>/dev/null
```

## Create All-Day Event

```bash
"$GWS" personal calendar events insert \
  --params '{"calendarId":"primary"}' \
  --json '{"summary":"PTO","start":{"date":"2026-03-21"},"end":{"date":"2026-03-22"}}' \
  2>/dev/null
```

Note: all-day event `end` date is exclusive (next day after last day of event).

## Create Event with Attendees

```bash
"$GWS" umb calendar +insert \
  --summary "Sync with Jesse" \
  --start "2026-03-20T10:00:00-05:00" \
  --end "2026-03-20T10:30:00-05:00" \
  --attendee "jesse@umbrellasystems.net" \
  2>/dev/null
```

---

## Update Event (Patch)

```bash
"$GWS" gis calendar events patch \
  --params '{"calendarId":"primary","eventId":"EVENT_ID_HERE"}' \
  --json '{"summary":"Updated title","location":"New location"}' \
  2>/dev/null
```

Get `eventId` from the `id` field in event list results.

## Delete Event

```bash
"$GWS" gis calendar events delete \
  --params '{"calendarId":"primary","eventId":"EVENT_ID_HERE"}' \
  2>/dev/null
```

---

## Parsing Responses

### Extract Event ID After Create

```bash
EVENT_ID=$("$GWS" personal calendar +insert \
  --summary "Meeting" \
  --start "2026-03-20T14:00:00-05:00" \
  --end "2026-03-20T15:00:00-05:00" \
  2>/dev/null | python3 -c "import json,sys; print(json.load(sys.stdin)['id'])")
```

Create returns full event JSON. Key fields: `id` (for patch/delete), `htmlLink` (shareable URL), `iCalUID`.

### Extract Multiple Fields

```bash
"$GWS" personal calendar +insert ... 2>/dev/null | python3 -c "
import json,sys; d=json.load(sys.stdin)
print(f'ID: {d[\"id\"]}')
print(f'Calendar: {d[\"organizer\"].get(\"displayName\", d[\"organizer\"][\"email\"])}')
print(f'Start: {d[\"start\"][\"dateTime\"]}')
"
```

### Check Delete Success

Delete returns `{"bytes":0,"mimeType":"text/html","status":"success"}` — check exit code:
```bash
"$GWS" personal calendar events delete \
  --params '{"calendarId":"primary","eventId":"EVENT_ID"}' \
  2>/dev/null && echo "Deleted" || echo "Failed"
```

### Handle Empty Calendar Response

When a calendar has no events for the queried range, `+agenda` returns:
```json
{"count":0,"events":"","timeMax":"...","timeMin":"..."}
```
This is NOT an error — just no events. The `--format table` output will show just headers.

---

## Filtering Excluded Calendars from Output

When fetching all events (no `--calendar` filter), pipe table output through grep to remove excluded calendars:

```bash
"$GWS" gis calendar +agenda --today --format table 2>/dev/null | \
  grep -v -E "(INTERNAL Staff Calendar|PUBLIC Twin Cities|Chromebook Cart|Room Reservations|Holidays in United States)"
```

Or for JSON output, filter in Python:

```bash
"$GWS" gis calendar +agenda --today --format json 2>/dev/null | python3 -c "
import json, sys
EXCLUDE = ['INTERNAL Staff Calendar TCGIS', 'PUBLIC Twin Cities German Immersion School',
           'Holidays in United States']
data = json.load(sys.stdin)
events = data.get('events', [])
if isinstance(events, list):
    for e in events:
        cal = e.get('calendar', '')
        if not any(x in cal for x in EXCLUDE) and 'Chromebook' not in cal and 'Room Reservations' not in cal:
            print(f'{e.get(\"start\",\"?\")} | {cal} | {e.get(\"summary\",\"?\")}')
"
```

---

## Sequential Fetch (All Accounts, Clean Output)

Parallel (`&` + `wait`) interleaves output and is harder to parse. Use sequential when you need to process results:

```bash
GWS="/Users/Austin/Documents/GitHub/CrystalAI/scripts/gws-mac.sh"
EXCLUDE="INTERNAL Staff Calendar|PUBLIC Twin Cities|Chromebook Cart|Room Reservations|Holidays in United States"

for acct in gis umb personal kesa; do
  "$GWS" "$acct" calendar +agenda --today --format table 2>/dev/null | \
    grep -v -E "$EXCLUDE" | tail -n +2
done
```

`tail -n +2` strips the header row from each account's output (keep only the first header if combining).

---

## Delete on Non-Primary Calendar

Must pass the full group calendar ID — not `"primary"`:

```bash
"$GWS" umb calendar events delete \
  --params '{"calendarId":"c_f1ae8b8d099f2af9b4843a78bfd64baa88dc10d005cc264b5d61571fc3bf6cd0@group.calendar.google.com","eventId":"EVENT_ID"}' \
  2>/dev/null
```

Same applies to patch on non-primary calendars.

---

## Calendar IDs Reference

| Calendar | Account | ID |
|----------|---------|-----|
| TCGIS | gis | `primary` (avanalstyne@germanschool-mn.org) |
| GIS | umb | `c_f1ae8b8d099f2af9b4843a78bfd64baa88dc10d005cc264b5d61571fc3bf6cd0@group.calendar.google.com` |
| SJA | umb | `c_02de9857eb1153947b77619b0e153c1a852cba7b5c90eb47eea982ffd7aa9311@group.calendar.google.com` |
| Umbrella - Personal | umb | `primary` (austin@umbrellasystems.net) |
| Umbrella Internal | umb | `c_c60d9c87c48e881b5cc91fef734965db41495bcb22a00a7134a36f409e7a5de5@group.calendar.google.com` |
| Personal | personal | `primary` (ajv857@gmail.com) |
| KESA | kesa | `primary` (austin@kesa.pro) |

## Timezone

Austin is in `America/Chicago`.
- CDT (March-November): UTC-5 → use `-05:00`
- CST (November-March): UTC-6 → use `-06:00`

Currently CDT as of March 2026.
