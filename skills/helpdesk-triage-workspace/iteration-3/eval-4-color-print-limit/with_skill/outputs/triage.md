---
ticket: eval-4-color-print-limit
date: 2026-03-17
skill_version: with_skill
---

# Triage — Color Print Limit (Heidi Schroeder)

## Step 1: Parse

- **Submitter:** Heidi Schroeder (hschroeder@germanschool-mn.org)
- **Affected users:** Heidi Schroeder
- **School:** GIS — confirmed via Freshdesk Company field ("Twin Cities German Immersion School") and email domain (@germanschool-mn.org)
- **Issue summary:** Teacher hit monthly color print quota; received a "limit" error when attempting to print a class worksheet.

---

## Step 2: KB Loaded

- `printer-issues.md` — direct match on "Limit error or color printing not working"

---

## Step 3: Triage Table

| Field | Value |
|-------|-------|
| **Submitter** | Heidi Schroeder |
| **Affected users** | Heidi Schroeder |
| **School** | GIS |
| **Category** | Printer Issues — Color Print Limit Exceeded |
| **User type** | Staff |
| **Priority** | Medium — user can't print color, but B&W workaround exists and teaching isn't fully blocked |
| **Tags** | `color-print` `quota` `limit` `staff` `gis` |
| **Escalation** | No — standard quota hit; user can self-serve B&W or wait for 1st-of-month reset. Mid-month exception would require approver authorization. |

---

## Step 4: Diagnosis

KB playbook match: **Color Print Limit Exceeded** (printer-issues.md, line 50–55).

Root cause: Heidi has exhausted her monthly color page quota (typically 50 pages; some staff have 150). The "limit" error is the print management system rejecting the job.

Key detail from KB: Even documents that look black and white count against the color quota unless "black and white" is explicitly selected in the print dialog. This is a common source of faster-than-expected quota burn.

Resolution path:
1. Inform Heidi she's hit her monthly color limit.
2. Advise B&W workaround — explicitly select black and white in print dialog.
3. Limits auto-reset on the 1st of each month.
4. If she needs an early reset, that requires approver authorization (designated TCGIS approver / DTS). Do not reset unilaterally.

No admin action required unless she requests an early exception.

---

## Step 6: Internal Note

**Internal note:**
- Diagnosis: Monthly color print quota exhausted. Standard mid-month state.
- Admin actions needed: None unless Heidi requests an early limit reset — that would require TCGIS approver sign-off. If reset is needed, Austin (or DTS) handles it.
- Confidence: High — KB has a direct playbook entry and auto-response template for this exact scenario.
- Follow-up: If she replies asking for an early reset, route to approver. No further action needed otherwise — limit auto-clears on the 1st.
