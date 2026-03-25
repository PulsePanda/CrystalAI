# Helpdesk Triage — Password Reset

**Ticket received:** 2026-03-17

---

## Triage Table

| Field | Value |
|---|---|
| Submitter | Unknown (ticket implies a colleague or Austin himself as submitter/reporter) |
| Affected User | Amanda Ferber |
| Category | Account Access / Password Reset |
| User Type | Staff — 4th grade teacher |
| Priority | Medium |
| Tags | `google-workspace`, `password-reset`, `staff`, `GIS`, `email-access` |
| Escalation Flag | No — routine admin action, resolvable by IT admin directly |

---

## Diagnosis

**What's wrong:** Amanda Ferber has lost access to her Google Workspace account (GIS domain) due to a forgotten password. She cannot log in to her school email.

**Root cause:** User-side credential loss. No indication of account compromise, policy enforcement, or lockout — standard forgotten password scenario.

**Fix:**

1. Log in to Google Workspace Admin Console (`admin.google.com`) with a GIS admin account.
2. Navigate to **Directory > Users**.
3. Search for Amanda Ferber.
4. Click her account > **Reset password**.
5. Generate a temporary password (or set one manually) and enable **"Require password change at next sign-in"**.
6. Communicate the temporary password to her via a channel she can access (in-person, phone, or a secondary contact method — not her GIS email since she's locked out of it).

**No further investigation needed.** Straightforward L1 resolution.

---

## Internal Note (for human reviewer)

Routine password reset. No red flags — no account compromise indicators, no policy triggers mentioned. Amanda is an active staff member (4th grade teacher at GIS). Standard fix is admin-initiated reset via Google Admin Console with forced password change on next sign-in.

Delivery of the temp password must happen out-of-band (not to her GIS email). Confirm she can receive it via phone or in-person. If she's unavailable, coordinate with her grade-level team or front office.

No escalation needed. Estimated resolution time: under 5 minutes once admin console is accessed.
