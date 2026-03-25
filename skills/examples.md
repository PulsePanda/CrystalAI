---
type: system
purpose: Case library for intent-based email classification — real examples with correct actions and reasoning
maintained-by: process-email skill (appends during training corrections)
---

# Email Classification Examples

Real emails (trimmed) with correct classification and reasoning. Used by the intent classifier to pattern-match ambiguous emails during triage.

## How This File Works

During the training period, every time Austin corrects a classification, the system stores:
1. **Trimmed email** — headers + meaningful body content (no signatures, quoted chains, legal disclaimers, image placeholders)
2. **Correct action(s)** — the action(s) Austin confirmed or corrected to
3. **Reasoning** — Austin's explanation of WHY this is the correct classification

The classifier references these examples when encountering similar emails to make better decisions.

## Examples

### Example 001
**From:** dstegmann@tcgis.org
**To:** GIS
**Subject:** Printer Code?
**Date:** 2026-03-24
**Body:**
Austin, Are you the one to ask for the printer code? I just lost my sticky note with it written on it. Thank you for your help. Denise

**Classification:** forward techsupport@tcgis.org
**Reasoning:** GIS staff asking for IT help (printer code). This is a support request that should route to the ticket system, not a direct reply from Austin. Even though she emailed Austin directly, the right action is forward to techsupport so it's tracked as a ticket.

### Example 002
**From:** tgerhart@germanschool-mn.org
**To:** GIS
**Subject:** Missing Chromebook
**Date:** 2026-03-24
**Body:**
Hi Austin, Frau Stillwell reports that a Chromebook went missing from her classroom this morning. Is there a way to track it, like "Find My" for Apple devices? Thank you, - Tonya

**Classification:** forward techsupport@tcgis.org
**Reasoning:** GIS staff reporting a missing device and asking about tracking. This is a support ticket — route to techsupport. Don't classify as "respond" even though she's asking a question.

### Example 003
**From:** jmonfre@germanschool-mn.org
**To:** GIS
**Subject:** Badge
**Date:** 2026-03-24
**Body:**
My badge ripped off again in the same spot in the same way. I was working in the equipment room, it got caught on something, ripped off, and disappeared.

**Classification:** archive (Austin already responded)
**Reasoning:** Check sent mail first. Austin had already replied to this before triage ran. When Austin has already responded, classify as archive — don't create duplicate tasks or drafts.

### Example 004
**From:** sdonahoe@germanschool-mn.org
**To:** GIS
**Subject:** work sheet crafter
**Date:** 2026-03-24
**Body:**
Good morning: Is this available to download? Susanne

**Classification:** forward techsupport@tcgis.org
**Reasoning:** GIS teacher asking about software access/availability. Software access requests are IT support tickets — route to techsupport.

### Example 005
**From:** korlova@germanschool-mn.org
**To:** GIS
**Subject:** Worksheet crafter
**Date:** 2026-03-24
**Body:**
Austin, Can you give me access to worksheet crafter? Thank you. Kallie

**Classification:** archive (Austin already responded)
**Reasoning:** Check sent mail first. Austin had already replied. Same topic as Example 004 — software access requests from GIS staff should route to techsupport, but in this case Austin already handled it directly.
