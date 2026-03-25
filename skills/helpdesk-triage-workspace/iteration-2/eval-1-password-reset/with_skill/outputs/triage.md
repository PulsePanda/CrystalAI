# Triage: Password Reset — Amanda Ferber

## Triage Table

| Field | Value |
|-------|-------|
| **Submitter** | Unknown (forwarding party — "Hey Austin") |
| **Affected users** | Amanda Ferber — 4th grade teacher |
| **School** | GIS (Freshdesk "Company" = Twin Cities German Immersion School) |
| **Category** | account-auth — Password Reset |
| **User type** | Staff |
| **Priority** | High — single user can't access email; no workaround for locked-out account |
| **Tags** | `password-reset` `staff` `google-workspace` `email` |
| **Escalation** | No — straightforward password reset; KB covers it fully |

---

## Diagnosis

Amanda Ferber (4th grade teacher, GIS) is locked out of her Google Workspace email account due to a forgotten password. Per the KB `account-auth.md` Password Reset playbook:

1. Identity confirmed via submitter (forwarded request from a known contact).
2. Reset to GIS default temp password: `German1234!`
3. Reply goes to the submitter with the temp password to relay — Amanda can't receive email on a locked-out account.
4. Include reminder to change password on first login.
5. If login still fails after reset: try adding `!` to the end (most common missed character).

Admin action needed: Austin must reset the password in Google Workspace Admin for `aferber@germanschool-mn.org` (or whatever her actual account address is — confirm if unknown).
