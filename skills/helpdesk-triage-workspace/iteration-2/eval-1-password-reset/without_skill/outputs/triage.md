# Helpdesk Triage — Password Reset

## Triage Table

| Field | Value |
|---|---|
| Submitter | Unknown (internal staff, likely IT or admin) |
| Affected User | Amanda Ferber |
| Category | Account Access / Password Reset |
| User Type | Staff — Teacher (4th grade) |
| Priority | Medium |
| Tags | password-reset, google-workspace, staff, GIS |
| Escalation Flag | No |

---

## Diagnosis

Standard Google Workspace password reset. Amanda Ferber is a GIS staff member who cannot access her email due to a forgotten password. GIS uses Google Workspace for email and authentication.

No elevated risk factors — no indication of compromised account, suspicious activity, or MFA lockout. Straightforward credential reset.

**Fix:**
1. Log into Google Admin Console (admin.google.com) with a GIS admin account
2. Navigate to Directory > Users
3. Search for Amanda Ferber
4. Click her account > Security > Reset password
5. Generate a temporary password (or set one manually)
6. Check "Require password change at next sign-in"
7. Deliver the temporary password to Amanda via a secondary channel (phone, in-person, or through the person who submitted the ticket)

No additional steps needed unless she reports ongoing issues after reset (e.g., MFA loop, device sync issues).

---

## Internal Note

Ticket: Amanda Ferber (4th grade teacher, GIS) — forgot password, locked out of email.
Action: Google Workspace admin password reset performed. Temp password issued with forced change on next login.
Delivery: Temp password delivered via [phone/in-person — fill in].
No suspicious activity noted. No escalation needed.
Resolved by: Austin V.
