---
type: helpdesk-triage
date: 2026-03-17
school: GIS
ticket_source: eval-6-promethean-offline
---

# Triage — Promethean Board No Internet (Room 214)

## Step 3: Triage Table

| Field | Value |
|-------|-------|
| **Submitter** | Michael Torres (mtorres@germanschool-mn.org) |
| **Affected users** | Michael Torres, Room 214 |
| **School** | GIS (Twin Cities German Immersion School) |
| **Category** | AV & Displays — Promethean / Smart Board |
| **User type** | Staff |
| **Priority** | Urgent — classroom teaching blocked, no workaround stated |
| **Tags** | `promethean` `smart-board` `no-internet` `wifi` `room-214` |
| **Escalation** | No — standard KB playbook applies; escalate only if wall power cycle + antenna check both fail |

---

## Step 4: Diagnosis

**KB article used:** `av-displays.md` — "Promethean / Smart Board Not Responding"

**Diagnosis:** Promethean board has lost its network connection. The internet indicator light being off confirms the board itself is not connected — this is not a browser or lesson-app issue. The remote power cycle already failed, which is expected: remote power cycling often soft-reboots the Android OS but does not reset the board's network stack fully.

**Likely causes (in order):**
1. Board needs a full wall-power cycle (30–60 seconds unplugged) — this is the most common fix and was not yet tried
2. WiFi antenna stubs on the side of the board may be loose or damaged (physically knocked by students)
3. Less likely: board is stuck on a bad IP / DHCP lease that will self-resolve on full power loss

**Recommended resolution path:**
1. Instruct Michael to unplug the board from the wall outlet (not remote power-off) for 30–60 seconds, then plug back in and power on
2. Ask him to visually check the two small antenna stubs on the side panel — confirm both are present and fully screwed in
3. If still offline after the above: collect the board's serial number (on the label on the back/side, e.g., `9B756MC51`) and open a Promethean support ticket

**Confidence:** High — this is the standard documented playbook for this exact symptom; KB example #7863 matches.

---

## Step 6: Internal Note

```
Internal note:
- Diagnosis: Promethean board lost WiFi connectivity; remote soft power cycle insufficient — full wall unplug required to reset network stack
- Admin actions needed: None for L1. If wall power cycle fails, need serial number to open Promethean support ticket. Physical antenna damage would require on-site visit.
- Confidence: High — exact symptom match in KB (ticket #7863); standard resolution playbook
- Follow-up: If wall power cycle doesn't resolve within ~5 minutes of reconnect, follow up with Michael to collect serial number and check antennas in person
```
