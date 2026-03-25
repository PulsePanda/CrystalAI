---
name: crystal:jesse-brief
description: This skill should be used when the user asks to "generate jesse brief", "create brief for jesse", "make a handoff doc", or types "/jesse-brief". Generates a clean, army-brief-style PDF summarizing all work activity for Jesse — wins, completed projects, in-flight work, and watch list. Covers GIS + SJA. Can also be called from /owners-meeting.
version: 1.0.0
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# Jesse Brief

Generate a concise, army-brief-style PDF summarizing all work activity at GIS and SJA for Jesse. Covers wins, completed projects, in-flight work, and watch list. Used for owners meetings and vacation handoffs.

## How It Works

1. **Read benchmark** — Get last meeting date from `state/operational/owners-meeting.md`
2. **Pull projects** — Read all work-tagged project files (GIS + SJA)
3. **Pull brag book** — Read `Areas/Work/Brag Book/GIS.md` and `SJA.md`
4. **Scan sessions** — Read session logs within lookback window for context
5. **Draft content** — Organize into brief sections
6. **Generate PDF** — Build HTML → Chrome headless → PDF
7. **Open PDF** — Ready to share or print

---

## Step-by-Step Workflow

### Step 1: Determine Lookback Window

Read the benchmark file:

```
Read: state/operational/owners-meeting.md
```

- If `Last Meeting Date` is set → lookback from that date to today
- If no date set (first run) → lookback window is **all-time**

Display the window to the user before proceeding:
```
Building Jesse Brief — covering [DATE] to today (or "all-time" if first run)
```

### Step 2: Pull All Work Projects

```
Glob: Projects/*.md
```

Exclude `_template.md`.

Read each project file (full read — need status, dates, and current state). Categorize:

**Completed projects** — `status: complete`
- For first run: include all completed projects
- For subsequent runs: only include if completed after the last meeting date
  - Check `Last Updated` date in the file as proxy for completion date
  - Or look for explicit completion date in file body

**Active projects** — `status: active` or `status: in-progress`
- Include all active work-related projects
- Filter to work-tagged only (tags containing `gis`, `sja`, `work`, `infrastructure`, `integration`)
- Skip personal projects (tags: `personal`, `wedding`, etc.) unless they somehow involve school work

### Step 3: Pull Brag Book Entries

```
Read: Areas/Work/Brag Book/GIS.md
Read: Areas/Work/Brag Book/SJA.md
```

- For first run: include all entries
- For subsequent runs: include only entries dated after last meeting date
  - Parse entry dates from `### YYYY-MM-DD:` headers

### Step 4: Scan Session Logs (Light Pass)

```
Glob: state/sessions/*.md
```

Filter to sessions within the lookback window (by filename date prefix).

Read each matching session's **Quick Reference section only** (first ~20 lines). Look for:
- Work items not captured in any project file
- Notable fixes, outages, one-off tasks, school-related actions
- Anything worth surfacing to Jesse that didn't spawn a project

Don't duplicate things already covered by projects or brag book.

### Step 5: Draft Brief Content

Organize into four sections. Army-brief style: declarative, blunt, scannable. Short fragments over full sentences. No filler.

**Section structure:**

```
COMPLETED  (since [DATE] / or "since inception" for all-time)
[List completed projects — name + one-line summary of what changed]

WINS
[Brag book entries — impact first, then brief detail]

IN FLIGHT
[Active projects — name, current status, next action, who's waiting on what]

WATCH LIST
[Upcoming dates, pending decisions, things that need eyes on]
```

**Tone guidance:**
- Completed: "What it was. What we did. Done."
- Wins: Lead with impact. "$X saved." "Problem eliminated." "X% improvement."
- In flight: Current state. What's blocking. What's next.
- Watch list: Dates, decisions, flags. No elaboration needed.

**School grouping:** If there are items for both GIS and SJA, add school label inline (e.g., `[GIS]`, `[SJA]`). If everything is one school, skip the labels.

### Step 6: Generate HTML

Read the template:
```
Read: assets/jesse-brief-template.html
```

Substitute the four placeholders with actual content:
- `{{DATE_RANGE}}` → the lookback window (e.g., "Feb 1 – Mar 15, 2026")
- `{{TODAY}}` → today's date (e.g., "March 15, 2026")
- `{{COMPLETED_ITEMS}}` → completed project `.item` divs
- `{{WINS_ITEMS}}` → brag book `.item` divs
- `{{IN_FLIGHT_ITEMS}}` → active project `.item` divs
- `{{WATCH_LIST_ITEMS}}` → watch list `.item` divs

Each content block is a series of `.item` divs:
```html
<div class="item">
  <div class="item-title">Project Name <span class="school-tag">GIS</span></div>
  <div class="item-detail">One-line summary.</div>
</div>
```

Write the populated HTML to:
```
/private/tmp/claude-501/jesse-brief-YYYY-MM-DD.html
```

### Step 7: Generate PDF

Output goes to `~/Downloads/jesse-brief-YYYY-MM-DD.pdf` so it's easy to find and share.

```bash
# Find Chrome
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# Generate PDF
"$CHROME" \
  --headless \
  --disable-gpu \
  --print-to-pdf="$HOME/Downloads/jesse-brief-YYYY-MM-DD.pdf" \
  --no-pdf-header-footer \
  --no-margins \
  "file:///private/tmp/claude-501/jesse-brief-YYYY-MM-DD.html" \
  2>/dev/null
```

If Chrome not found at default path, try:
```bash
which chromium || which google-chrome
```

### Step 8: Open PDF

```bash
open "$HOME/Downloads/jesse-brief-YYYY-MM-DD.pdf"
```

Report to user:
```
Brief generated: ~/Downloads/jesse-brief-YYYY-MM-DD.pdf
Covers: [DATE] → today
  - X completed projects
  - X wins
  - X in-flight items
  - X watch list items
```

---

## Brief Writing Guidelines

### Completed Projects
- One entry per project
- Title = project name
- Detail = one sentence: what it was, what the outcome was
- Do NOT explain the journey — only the result
- Example: "ISONAS Badge Automation. Self-service credential pipeline via PureAccess API + Zapier. No vendor involvement required."

### Wins
- Lead with the number/impact when quantified
- If no number: lead with what was eliminated or improved
- Keep to one line per win
- Example: "$100k E-rate recovery. Recovered before expiration window closed."
- Example: "Camera subscriptions. Cut $2k/year recurring cost."

### In Flight
- Title = project name in caps
- Line 1: Current status in one sentence
- Line 2: What's next / what's blocking
- Waiting-on person always named explicitly
- Example:
  - Title: "SPECTRUMVOIP"
  - Detail: "New quote: $607/mo all-in (~$94/mo gap vs. current). Kim + Elizabeth reviewing internally."

### Watch List
- Short flags only. One line max.
- Include dates when known
- Focus on things Jesse might need to act on or be aware of
- Example: "Raptor contract — budget approval needed before signing. April 6 Kyle reconnects."

---

## Error Handling

**No projects found:** Report "No work projects found in Projects/" and continue with brag book only.

**No brag book entries in window:** Note "No new brag book entries since last meeting" in Wins section.

**Chrome not found:** Write HTML only, open in browser, tell user to print to PDF manually.

**Benchmark file missing:** Treat as first run (all-time). Create the file after generating.
