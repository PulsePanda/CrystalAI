---
type: helpdesk-triage
date: 2026-03-17
school: GIS
category: software-apps
---

# Triage — IXL Login Denied (3rd Grade)

## Step 3: Triage Table

| Field | Value |
|-------|-------|
| **Submitter** | Sara Meyerhoff (smeyerhoff@germanschool-mn.org), 3rd grade teacher |
| **Affected users** | Sara Meyerhoff's 3rd grade students |
| **School** | GIS — Twin Cities German Immersion School (confirmed via Freshdesk Company field) |
| **Category** | Software & Apps — IXL grade restriction |
| **User type** | Student |
| **Priority** | Low — no active teaching blocked; IXL is supplemental, grade restriction is a known policy |
| **Tags** | `ixl` `grade-restriction` `licensing` `3rd-grade` |
| **Escalation** | No — clear KB resolution; policy question can be directed to admin if teacher wants to push back |

## Step 4: Diagnosis

KB article `software-apps.md` has an exact match under "IXL Access / Licensing":

> IXL is licensed for **4th and 5th grade only** — 3rd grade and intervention students may not have access.

The teacher's report ("they don't have access") and the grade context (3rd grade, previously had IXL in 2nd grade at a different school year/grade level) align precisely with this policy. Students had IXL last year when they were in 2nd grade — it's possible the school had a broader license then, or the teacher is misremembering. Either way, under the current licensing agreement, 3rd grade is not included.

No admin action is required unless the school decides to expand the license. The KB also provides a response template (`ixl-grade-restriction`) for this exact scenario.

If Sara wants to contest the policy, the right contact is admin/Esther — not IT.

## Step 6: Internal Note

**Internal note:**
- Diagnosis: IXL is licensed for 4th–5th grade only at GIS. 3rd grade students are outside the licensed scope — this is expected behavior, not a technical fault.
- Admin actions needed: None. No Workspace changes, no license modifications needed on IT's side.
- Confidence: High — exact match in KB with dedicated response template and an identical prior ticket (#7398).
- Follow-up: None required unless Sara escalates to admin and admin decides to expand the license. If that happens, IT would need to add 3rd grade students via spreadsheet or Clever sync.
