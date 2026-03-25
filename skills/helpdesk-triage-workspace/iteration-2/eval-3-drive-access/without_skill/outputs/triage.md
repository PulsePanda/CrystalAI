# Helpdesk Triage — Google Drive Access Denied

**Ticket submitted:** 2026-03-17
**Submitter:** Kim Hackett (khackett@germanschool-mn.org)
**Company:** Twin Cities German Immersion School (GIS)
**Environment:** Google Workspace, GIS accounts

---

## Triage Table

| Field | Value |
|-------|-------|
| Category | Google Workspace — Drive / Permissions |
| Priority | Medium-High |
| Urgency | Moderate (1 week ongoing, multiple staff affected) |
| Scope | Multiple users, shared Drive folder(s) |
| Impact | Staff blocked from shared files — workflow disruption |
| Escalation needed? | Possibly — if Workspace Admin action required |
| Assigned to | Austin (Umbrella/IT) |

---

## Diagnosis — Root Causes (Ranked by Likelihood)

### 1. Shared Drive membership vs. item-level sharing mismatch (Most Likely)
If the files live inside a **Shared Drive** (formerly Team Drive), simply sharing the folder/file with someone doesn't grant access. The user must be added as a **member of the Shared Drive** itself (Viewer, Commenter, Contributor, Content Manager, or Manager). Item-level sharing on a Shared Drive is overridden by membership settings.

**Indicators:** Worked fine in the past → someone may have re-shared individual items without adding users to the Shared Drive membership.

---

### 2. Drive sharing settings restricted by Workspace Admin
GIS Workspace Admin may have a policy restricting file sharing to:
- Domain-only (files can't be shared with non-GIS accounts — irrelevant here, but...)
- Target audiences or Groups only
- Specific organizational units

If a recent Workspace Admin policy change was made, it could break previously working shares.

**Indicators:** "About a week" aligns with a potential admin change or policy rollout.

---

### 3. Users added to wrong Google Group or removed from one
If access was granted via a Google Group (e.g., `staff@germanschool-mn.org`) rather than individual emails, users who were recently added to staff may not yet be in the Group — or existing staff may have been accidentally removed.

**Indicators:** Multiple staff affected at once; new hires or account changes in the past week.

---

### 4. Shared folder is a shortcut, not a real share
If the folder shared with users is a **Drive shortcut** pointing to another folder, the shortcut itself doesn't inherit permissions. Users need access to the underlying folder.

**Indicators:** "Shared the folder" — if done via a shortcut, access won't work as expected.

---

### 5. Organizational Unit (OU) or license issue
If any of the affected accounts were recently moved to a different OU (e.g., during an org restructure or school year rollover), Drive sharing policies applied to OUs could affect their access. Also, if their Workspace license was changed (e.g., downgraded), Drive access could be restricted.

**Indicators:** Less likely unless there was recent account maintenance.

---

### 6. Owner of the Drive content is suspended or deleted
If the files are in **My Drive** (not a Shared Drive) and owned by an account that was suspended or deleted, shared access may have been revoked automatically.

**Indicators:** Files in a specific person's Drive, not a team/shared location.

---

## Recommended Diagnostic Steps (for Austin)

1. Confirm whether the folder is in **My Drive** or a **Shared Drive** — this determines the fix path entirely.
2. If Shared Drive: check if affected users are listed as Shared Drive members in Admin Console > Drive > Manage shared drives.
3. Check Admin Console > Reports > Drive activity for the folder — look for permission changes in the past 7-10 days.
4. Check if access was granted via a Google Group — verify group membership for affected users.
5. Ask Kim for the names of 1-2 affected staff and the Drive folder name/URL.
6. Review Workspace Admin Console > Apps > Google Workspace > Drive and Docs > Sharing settings for any recent policy changes.

---

## Internal Note

Kim reports multiple GIS staff getting "access denied" on a shared Google Drive folder — ongoing for about a week. Likely a Shared Drive membership issue (most common cause of this exact symptom) or an admin policy change. Need to confirm: (1) My Drive vs. Shared Drive, (2) how access was granted (direct share vs. group vs. Shared Drive membership), (3) which specific folder/file. Should be resolvable in one admin session once the folder type is confirmed. No escalation needed yet — Austin can resolve via Admin Console.
