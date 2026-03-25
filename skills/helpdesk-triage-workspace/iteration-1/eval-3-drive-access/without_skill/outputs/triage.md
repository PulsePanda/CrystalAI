# Helpdesk Triage — Google Drive Access Denied

**Ticket received:** 2026-03-17
**Reported by:** Kim Hackett (Director of Operations & HR, GIS)

---

## Triage Table

| Field | Value |
|-------|-------|
| Submitter | Kim Hackett — Director of Operations & HR |
| Affected users | Multiple GIS staff (count unknown — "a few") |
| Category | Google Drive / Shared Drive Access |
| User type | Staff (GIS Google Workspace accounts) |
| Priority | High — multi-user, ongoing for ~1 week |
| Tags | `google-drive`, `access-denied`, `shared-drive`, `permissions`, `multi-user` |
| Escalation flag | YES — multi-user scope, 1-week duration, requires Google Workspace admin review |

---

## Diagnosis

### Most Likely Root Causes (in order of probability)

**1. Shared Drive permissions not applied correctly (high probability)**
Files in Shared Drives (formerly Team Drives) have a separate permissions model from My Drive. Sharing a *folder* within a Shared Drive does not grant access to the Shared Drive itself — users must be added as members of the Shared Drive at the drive level, not just the folder level. If someone shared a folder link, affected staff may still get "access denied" at the drive root.

**2. Permissions were reset during a recent change or migration (medium-high probability)**
The ~1-week window suggests something changed around that time — a folder reorganization, admin action, or Drive settings update. Worth checking the activity log on the affected drive.

**3. Users accessing via personal Google accounts instead of GIS accounts (medium probability)**
If affected staff are signed into Chrome or Drive with a personal Gmail account, they'll get access denied even if their GIS account has access. Common when staff switch browsers or clear cookies.

**4. Sharing settings restricted at the domain level (lower probability)**
GIS Google Workspace admin settings may restrict sharing to within the domain, or a Drive-level setting may have been tightened (e.g., "Editors can't share" or "Only managers can manage members"). If a non-admin tried to re-share, it may not have taken effect.

**5. Folder ownership issue (lower probability)**
If the folder/drive was owned by a former employee whose account was suspended or deleted, access could have been broken without anyone explicitly changing permissions.

---

## Recommended Resolution Steps

1. **Identify the specific drive/folder** — ask Kim for the exact name or URL.
2. **Get a list of affected users** — name and email for each.
3. **Check how the folder is structured** — is it a Shared Drive or a folder inside someone's My Drive? (This changes the fix.)
4. **If Shared Drive:** Add affected users as members directly at the drive level with the appropriate role (Contributor or Content Manager).
5. **If My Drive folder:** Confirm sharing was done with the correct GIS email address and the correct permission level (Viewer vs. Editor).
6. **Check for a recent admin change** — review Drive audit logs in Google Admin Console for activity around ~1 week ago.
7. **Confirm users are signed in with GIS accounts** — have one affected user try in an Incognito window and sign in with their GIS credentials explicitly.

---

## Internal Note for Human Reviewer

**This ticket needs Austin's attention.** It affects multiple staff accounts, has been ongoing for a week, and likely requires Google Workspace admin console access to diagnose properly (audit logs, Shared Drive membership management, or domain sharing settings). The KB playbook covers the resolution steps but the diagnosis requires admin-level visibility.

**Escalation trigger matched:** Multi-user scope + "can't access files" = operational impact. Per escalation guide, assign to Austin for GIS.

**Confidence:** Medium (~70%) — root cause is almost certainly a permissions misconfiguration, but the exact fix depends on whether this is a Shared Drive or My Drive folder, which we don't have yet. Draft reply below collects that info before committing to a fix.

**Do NOT auto-send a fix.** Get the drive URL and affected user list first.
