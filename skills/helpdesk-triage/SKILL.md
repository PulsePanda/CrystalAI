---
name: crystal:helpdesk-triage
description: L1 helpdesk triage for GIS (Twin Cities German Immersion School) and SJA (Sejong Academy) charter schools. Use this skill any time Austin receives, pastes, forwards, or describes a tech support issue from a school teacher, staff member, student, or parent — even if the word "ticket" is never used. This includes pasted emails from @germanschool-mn.org or @sejongacademy.org addresses, forwarded messages about broken Chromebooks, printer errors, password resets, Promethean board issues, Google Workspace access problems, projector/AV trouble, iPad carts, IXL access, or any other school IT problem. Reads the helpdesk KB, produces a structured triage table, researches if needed, drafts a reply in Austin's voice, and creates an Apple Mail draft. Trigger on: "work this ticket", "triage this", "someone's having trouble with", "a teacher emailed about", any GIS/SJA tech problem description, or /helpdesk-triage.
---

# /helpdesk-triage

L1 helpdesk triage for Twin Cities German Immersion School (GIS) and Sejong Academy (SJA). Both schools run Google Workspace for email, file sharing, and user management. ~400-500 students and 60-90 staff per school.

---

## School Context

| School | Abbrev | Domain | Default Reply Sender |
|--------|--------|--------|----------------------|
| Twin Cities German Immersion School | GIS | See `crystal.local.yaml` → `schools.gis.domain` | GIS email from `crystal.local.yaml` → `email_accounts.gis.address` |
| Sejong Academy | SJA | See `crystal.local.yaml` → `schools.sja.domain` | Escalate to Jesse |

## Escalation Contacts

| Situation | Contact |
|-----------|---------|
| GIS hardware / on-site | Austin |
| SJA issues | Jesse |
| Billing / contract questions | Austin |
| Physical security / access | Austin |
| Anything requiring Workspace admin credentials | Austin |

---

## Step 1: Parse the Ticket

Extract from the ticket:
- **Submitter** — who sent it (may differ from the affected user)
- **Affected users** — who's actually having the problem
- **School** — GIS or SJA (see detection rules below)
- **Issue summary** — one sentence

**School detection — in priority order:**
1. **Freshdesk "Company" field** — if present, use it directly (`Twin Cities German Immersion School` = GIS, `Sejong Academy` = SJA)
2. **Email domain** — `@tcgis.org` or `@germanschool-mn.org` = GIS; `@sejongacademy.org` = SJA
3. **Context clues** — school name mentioned in the ticket body

If the ticket is a forwarded chain, the submitter is the forwarder and the affected users are the people named in the body.

---

## Step 2: Load the KB

There are two reference sources. Use both as needed — they serve different purposes.

### KB Articles (issue-focused triage guides)

1. Read `Areas/Work/Helpdesk-KB/_index.md` to see all available categories
2. Based on the ticket content, load the 1-2 most relevant articles from `Areas/Work/Helpdesk-KB/`

| Article | When to load |
|---------|-------------|
| `account-auth.md` | passwords, Google groups, Drive access, Clever/SSO, email accounts |
| `chromebook-issues.md` | Chromebook hardware or software |
| `printer-issues.md` | printing |
| `student-devices.md` | student hardware |
| `staff-devices.md` | staff laptops and hardware |
| `network-issues.md` | WiFi, connectivity |
| `software-apps.md` | apps, classroom tools, software installs |
| `av-displays.md` | projectors, displays, classroom AV |
| `hardware-requests.md` | new hardware requests |
| `general.md` | anything that doesn't fit above |

### GIS Master Handbook (procedure reference — standalone)

`Areas/Work/Helpdesk-KB/[02] GIS MASTER HANDBOOK.md`

This is Austin's operational runbook for GIS — written during onboarding to document the exact steps for every common admin procedure. It is **not** a KB article and should not be restructured or absorbed into the KB. It is maintained as a standalone handoff document for human coverage (e.g., when Austin is on vacation).

**Load sections from this file when:**
- The Admin actions needed involve a specific GIS system procedure (not just a general Google/Chrome concept)
- You need exact steps, URLs, credentials references, or system-specific navigation paths

**Systems covered** (search these sections by keyword when relevant):

| System | Handbook section | When relevant |
|--------|-----------------|---------------|
| Access control (ISONAS) | `Access Control` | Badges, door schedules, facility rentals |
| Bell system (Primex) | `Bell System` | Bell schedule changes, volume |
| Clever | `Clever` | Student badges, SSO sync with IC |
| Chromebooks | `Chromebooks` | Cart combos, assignment, BOY/EOY checklists |
| Employee on/offboarding | `Employee / Contractor` | New hire setup, departing staff |
| Google Accounts | `Google Accounts` | Group management, new employee accounts |
| GoGuardian | `GoGuardian` | Behavior report notifications |
| InfiniteCampus | `InfiniteCampus` | IC login issues, MDE cert expiry |
| IXL | `IXL` | Adding intervention students to sync |
| Macbooks | `Macbooks` | Deploying, wiping via Jamf |
| iPads | `iPads` | App deployment via Jamf + Apple School |
| Printers | `Printers` | User codes, print queue setup, color printing |
| Phones (NEC) | `Phones and Phone System` | Voicemail, name changes, VM-to-email |
| Starlink | `Starlink` | Enabling/disabling backup internet |
| Student Enrollment | `Student Enrollment Changes` | Enrolling/unenrolling students |
| Worksheet Crafter | `Worksheet Crafter` | Installation, teacher access |
| Zoom | `Zoom` | Adding users |

**Key facts to know without reading:**
- School IPs, access control URL, contacts: see `crystal.local.yaml` → `schools.gis`
- Jamf wipe code: see `crystal.secrets.yaml` → `sensitive.helpdesk.jamf_wipe_code`
- Email username format: first initial + last name
- Passwords/credentials: in **Keeper**
- Asset inventory: **Snipe**
- Device/student tracking: **Airtable**
- Onboarding requests: see `crystal.local.yaml` → `schools.gis.contacts.ops_director`

**Maintaining the handbook:** When a procedure changes or a new one is learned, update the relevant section in the handbook directly. It should always be accurate enough to hand to a human covering for Austin.

---

## Step 3: Triage

Produce this table before doing anything else:

| Field | Value |
|-------|-------|
| **Submitter** | |
| **Affected users** | |
| **School** | GIS / SJA |
| **Category** | KB category — subcategory |
| **User type** | Student / Staff / Both |
| **Priority** | Low / Medium / High / Urgent |
| **Tags** | `tag1` `tag2` `tag3` |
| **Escalation** | Yes / No — brief reason if yes |

**Priority guide:**
- **Urgent** — classroom is down, teaching actively blocked, no workaround
- **High** — single user can't work, time-sensitive (exam, event, presentation)
- **Medium** — recurring issue or multiple users affected, workaround exists
- **Low** — minor inconvenience, non-urgent request

---

## Step 4: Research & Diagnose

Start with the KB article loaded in Step 2.

**If the KB has a matching category:** load the KB article for symptoms and escalation triggers, then load the referenced **GIS Master Handbook** section for step-by-step resolution procedures. State the diagnosis.

**If the KB doesn't fully cover it:** use WebSearch + WebFetch to find the answer. Write targeted, source-constrained search prompts — look for official documentation first, then community threads. Be specific about what you're trying to verify.

Good search prompt pattern:
> Search [official docs] and [community forums] to answer: [specific technical question]. Looking for: [what you need to confirm]. Prefer: [authoritative sources].

State the diagnosis clearly before moving to Step 5. If you can't determine root cause, say so in the internal note.

---

## Step 5: Draft the Reply

Invoke `/write` to draft the reply in Austin's voice.

- **To:** ticket submitter — always reply to whoever sent the ticket
- **CC:** affected users if different from submitter, **unless they can't receive email** (see below)
- **Sender:** match the school account (resolve from `crystal.local.yaml` → `email_accounts`)
- **Tone:** casual but competent, short paragraphs, no bullet points in casual emails

**One-touch resolution:** Solve the problem in the email itself. Don't send holding replies ("I'll look into it and get back to you") — diagnose, resolve, and send. If the issue genuinely requires on-site or async follow-up, say what the next step is and when, but don't leave it open-ended.

**Don't explain the backend:** Never mention the tools used to diagnose or fix the issue (GoGuardian, Google Admin, Google Workspace, etc.). Staff don't need to know the plumbing. Just give them what they asked for, or tell them what to do if they can self-resolve.

**Important — when the affected user can't receive email:** If the issue involves a locked-out account, a new account being created, or any scenario where the affected user can't access their inbox, do NOT address the reply to them. Address the reply to the submitter and include the relevant info (e.g., temp password, instructions) in the body with a note to relay it. The affected user's email is inaccessible — they won't see a message sent there.

Once the draft is ready, invoke `/email` to create an Apple Mail draft window via AppleScript. Never display draft text in the terminal as the final deliverable — it must be an actual Mail draft.

---

## Step 6: Internal Note

Always end with a brief internal note for the human reviewer. The "Admin actions needed" field is a specific, ordered list of steps Austin must take to resolve the ticket — not a summary. Think of it as the runbook Austin follows after reading the triage.

```
**Internal note:**
- Diagnosis: [what's actually wrong — root cause, not just symptoms]
- Admin actions needed:
  1. [Step 1 — specific action, tool, location]
  2. [Step 2 — etc.]
  (These are the steps I can't yet take myself. Once I have access, I'll do them directly.)
- Confidence: [High / Medium / Low]
- Follow-up: [anything to watch for or revisit after resolution]
```

---

## Correction & Learning Protocol

This skill is actively being trained. When Austin corrects a response:

1. **Update the KB article** — add the new case, edge case, or nuance to the relevant article in `Areas/Work/Helpdesk-KB/`. Do NOT remove or invalidate existing content unless it was factually wrong — the KB is a growing handbook, not a rewrite target.
2. **Update this SKILL.md** — add or fix the relevant step, rule, or note so the behavior changes going forward
3. **Log to corrections.md** — append a row to `state/operational/corrections.md`
4. **Update auto-memory** — save a feedback memory file if the rule is cross-session

Do this automatically on every correction — don't wait to be asked.

**How to treat the KB:**
The KB is a guide, not a perfect rulebook. No two tickets are identical even when they look similar. When a ticket doesn't fit the KB exactly:
- Use the KB to orient the diagnosis and identify the most likely path
- Solve the specific ticket based on what's actually happening
- If the resolution reveals a new case or edge case not in the KB, add it
- Don't assume the KB is wrong just because the ticket took a different path — assume the KB is incomplete and extend it

Over time the KB becomes a comprehensive handbook through this process. Treat every correction as an addition, not a rewrite.

**Training loop model:**
- I diagnose the issue and tell Austin the exact steps to resolve it (Admin actions needed)
- Austin takes those steps and reports back what he found
- If my diagnosis or draft was wrong, Austin corrects it
- I add the new case to the KB and update the skill so I get it right next time
- Goal: once I have direct tool access, I take those steps myself

---

## Future Capabilities (scaffolded, not yet active)

### Freshdesk Integration
Pull recently updated tickets via Freshdesk API instead of requiring Austin to paste them in manually. Post internal notes and update ticket status via API after triage.

### Google Workspace Admin Access
Verify group membership, check Drive sharing permissions, reset passwords, and audit distribution group membership directly — rather than flagging for Austin to check manually. Requires Workspace Admin credentials.
