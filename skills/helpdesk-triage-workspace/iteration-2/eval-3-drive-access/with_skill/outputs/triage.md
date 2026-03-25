---
type: helpdesk-triage
date: 2026-03-17
school: GIS
category: account-auth
---

# Triage: Google Drive Access Denied — GIS Staff

## Step 3: Triage Table

| Field | Value |
|-------|-------|
| **Submitter** | Kim Hackett (khackett@germanschool-mn.org) — GIS Director of Operations & HR |
| **Affected users** | Multiple GIS staff (count unknown; Kim says "a few") |
| **School** | GIS — Twin Cities German Immersion School (confirmed via Freshdesk Company field) |
| **Category** | account-auth — Google Drive / Shared Drive Access |
| **User type** | Staff |
| **Priority** | Medium — multiple users affected, ongoing for ~1 week, workaround unknown |
| **Tags** | `google-drive` `access-denied` `shared-drive` `permissions` `multiple-users` |
| **Escalation** | Yes — requires Google Workspace admin access to inspect Drive sharing settings, org unit permissions, and Shared Drive membership. Austin must check admin console. |

---

## Step 4: Diagnosis

### KB Finding
The `account-auth` KB article covers Google Drive access directly:
- "For 'lost access': check if permissions were intentionally reset (e.g., during a data migration). Re-grant appropriate role (viewer, content manager, or manager)."
- Escalation trigger applies: anything requiring Workspace admin credentials → Austin.

### Key Technical Factors (from web research)

The "shared but still denied" pattern in Google Workspace typically has three root causes:

1. **Shared Drive membership gap** — If the affected folder lives inside a Shared Drive (not My Drive), users must be *members of the Shared Drive itself*, not just have the individual folder shared with them. Folder-level sharing alone is insufficient when the parent is a Shared Drive.

2. **Sharing restrictions in Shared Drive settings** — A Shared Drive can be configured to block sharing with non-members. If that restriction is enabled, sharing the folder with someone outside the Shared Drive fails silently or surfaces an error only to the person sharing — not the person being denied.

3. **Google Workspace license or OU restriction** — Org-level Drive sharing policies (set in Admin Console > Apps > Google Workspace > Drive > Sharing settings) can restrict who can access Shared Drives based on Organizational Unit. If any affected staff were recently moved to a different OU, their access could have been silently revoked.

### Most Likely Root Cause
Given that this affects multiple staff on GIS accounts and has persisted for ~1 week: the most likely cause is a **Shared Drive membership issue** — the folder is inside a Shared Drive, and the staff were shared the folder directly rather than added as Shared Drive members. The "access denied" is correct behavior from Google's perspective; it just wasn't communicated clearly to whoever shared it.

A secondary possibility: a Workspace admin made a policy change ~1 week ago (OU restructure, sharing policy tightening) that revoked access without anyone realizing it.

### Admin Actions Required
Austin needs to:
1. Identify which Drive/folder Kim is referring to (name or link)
2. In Google Admin Console or Google Drive as admin: confirm whether it's a Shared Drive or a My Drive folder
3. If Shared Drive: check member list — add affected staff with appropriate role (Viewer or Content Manager)
4. If My Drive folder: re-share directly with affected staff email addresses
5. Check if any org-level Drive sharing policies were changed ~1 week ago

---

## Step 6: Internal Note

**Internal note:**
- Diagnosis: Most likely Shared Drive membership gap — staff were shared a folder inside a Shared Drive but not added as Shared Drive members. Google requires the latter for reliable access. Secondary possibility: an OU or admin policy change ~1 week ago silently revoked access.
- Admin actions needed: Austin must check admin console. Need to (a) get the folder/drive name/link from Kim, (b) confirm it's a Shared Drive vs. My Drive folder, (c) add affected staff as Shared Drive members or re-share the folder directly.
- Confidence: Medium — root cause is one of two well-known patterns; can't confirm without seeing the Drive. Reply asks Kim for the folder link/name to nail it down.
- Follow-up: If re-adding permissions doesn't resolve it, check whether a Workspace policy change (OU settings, Drive sharing policy) was made around ~1 week ago.
