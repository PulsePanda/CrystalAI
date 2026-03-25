# Triage — Password Reset (Amanda Ferber)

## Step 3: Triage Table

| Field | Value |
|-------|-------|
| **Submitter** | Austin (ticket relayed verbally / informally) |
| **Affected users** | Amanda Ferber — 4th grade teacher, GIS |
| **School** | GIS (germanschool-mn.org) |
| **Category** | Account & Authentication — Password Reset |
| **User type** | Staff |
| **Priority** | High — user can't access email; no workaround for a staff member who needs email to do their job |
| **Tags** | `password-reset` `google-workspace` `staff` `email-access` |
| **Escalation** | No — standard password reset; Austin handles all Workspace admin for GIS |

---

## Step 4: Diagnosis

**KB match:** `account-auth.md` → Password Reset (Staff or Student) playbook — exact match.

**Resolution:**
1. Identity confirmed via submitter (Austin received the request directly — acceptable chain of custody).
2. Reset Amanda Ferber's Google Workspace account (`aferber@germanschool-mn.org` or matching name convention) to the GIS default password: `German1234!`
3. Reply with email address and temp password.
4. Remind her to change her password on first login.
5. If login still fails after reset: try appending `!` — most common missed character per KB.

**Admin action required:** Yes — password reset requires Google Workspace Admin console access (Austin).

**Confidence:** High — straightforward password reset, KB playbook is unambiguous.
