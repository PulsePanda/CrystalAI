# Helpdesk Triage — Google Drive Access Denied (Multiple Staff)

---

## Step 1: Ticket Parse

- **Submitter:** Kim Hackett (GIS Director of Operations & HR)
- **Affected users:** Multiple GIS staff (count unknown — "a few")
- **School:** GIS (Twin Cities German Immersion School)
- **Issue summary:** Multiple staff getting "access denied" on a shared Google Drive folder despite it appearing to have been shared with them, ongoing for approximately one week.

---

## Step 2: KB Loaded

- `account-auth.md` — Google Drive / Shared Drive Access section

---

## Step 3: Triage

| Field | Value |
|-------|-------|
| **Submitter** | Kim Hackett |
| **Affected users** | Multiple GIS staff (specific names unknown) |
| **School** | GIS |
| **Category** | Accounts & Authentication — Google Drive / Shared Drive Access |
| **User type** | Staff |
| **Priority** | High |
| **Tags** | `google-drive` `shared-drive` `access-denied` `permissions` `multi-user` |
| **Escalation** | Yes — requires Google Workspace Admin access to verify/fix Drive permissions and sharing settings |

**Priority rationale:** Multiple users affected, has persisted a week, likely blocking collaboration on shared files. Not Urgent because it's not a single classroom-down situation, but High because it's multi-user and ongoing.

---

## Step 4: Research & Diagnosis

### KB Coverage

The `account-auth.md` playbook covers Drive access at a high level:
- Re-grant appropriate role (viewer, content manager, or manager)
- Permissions may have been reset during a data migration

This is partially useful but doesn't fully explain why sharing "appears" to work but access is still denied for multiple users simultaneously.

### Additional Research (WebSearch — support.google.com)

Sources consulted:
- https://support.google.com/a/answer/7337638 (Troubleshoot shared drives for users — Admin Help)
- https://support.google.com/a/users/answer/12382709 (Troubleshoot issues with shared drives — Learning Center)
- https://support.google.com/a/users/answer/12380484 (How file access works in shared drives)

### Likely Root Causes (in order of probability)

1. **Shared folder vs. Shared Drive membership:** The folder may be inside a Shared Drive (not a regular My Drive folder). For Shared Drives, users must be added as **members of the Shared Drive itself** — sharing the folder or file alone is not sufficient and may appear to work from the sharer's side while still denying access.

2. **Admin-level sharing restriction changed:** A Workspace admin setting may have been tightened (e.g., external sharing policy, or "only members can access content in this shared drive" setting) that silently revoked access for users who were shared via link or direct share rather than formal Shared Drive membership.

3. **Permissions reset during migration or ownership change:** If the Drive or folder was recently reorganized, moved, or ownership was transferred, permissions can be silently dropped. Consistent with "about a week ago."

4. **Access level too low:** Users may have been added as Viewer when they need Contributor or Content Manager, or weren't added at the Shared Drive level at all.

### Diagnosis

Most likely cause: This is a Shared Drive where staff were shared via folder link or direct file share rather than being added as members of the Shared Drive, OR a sharing policy change ~1 week ago (admin setting or Drive restructure) silently dropped their access. Admin-level verification required to confirm.

### Admin Actions Required

- Log into Google Workspace Admin Console
- Navigate to Apps > Google Workspace > Drive and Docs > Manage shared drives
- Find the affected Shared Drive
- Check current member list and access levels
- Check sharing settings (especially: "Allow people who aren't shared drive members to be added to files")
- Re-add affected staff as members with appropriate role (Contributor or Content Manager)
- Check if any org-level sharing policy changed in the last 7 days (Admin Console > Reports > Audit > Drive)

---

## Step 5: Draft Reply

See `draft_reply.txt`.

---

## Step 6: Internal Note

**Internal note:**
- Diagnosis: Almost certainly a Shared Drive membership/settings issue — staff appear shared but aren't formal Shared Drive members, or a recent sharing policy/structure change revoked access. Has been going on ~1 week which aligns with a discrete change event.
- Admin actions needed: Workspace admin access required. Need to check the Shared Drive member list, sharing settings, and audit log for any policy changes in the last 7–10 days. Austin needs to log into Admin Console to resolve.
- Confidence: Medium-High — strong match to known Shared Drive "access denied after sharing" pattern, but exact cause (membership gap vs. policy change vs. migration) can't be confirmed without admin console access.
- Follow-up: Ask Kim which specific Drive/folder is affected and who the affected staff are. Once fixed, verify each user can access before closing. If this was caused by a sharing policy change, check whether other Drives are similarly broken.
