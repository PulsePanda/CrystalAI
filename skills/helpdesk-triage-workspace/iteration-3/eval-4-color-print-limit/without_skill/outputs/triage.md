# Triage — Color Print Limit Error

## Triage Table

| Field | Value |
|-------|-------|
| Ticket submitter | Heidi Schroeder (hschroeder@germanschool-mn.org) |
| Role | Teacher, GIS |
| Issue summary | Color printing failed with a "limit" error when printing a classroom worksheet |
| Category | Print Management |
| Subcategory | Color Print Quota / Limit |
| Priority | Medium |
| Affected system | School printer (color), Google Workspace print environment |
| Scope | Single user (possibly school-wide policy) |
| Impact | Teacher unable to print color materials for class |
| SLA target | Respond same day; resolve within 1 business day |

---

## Diagnosis

### Most Likely Cause
GIS has a **color print quota policy** in place. Heidi has hit her allocated color page limit for the month (or billing period). The printer or print management software (e.g., PaperCut, embedded printer quota, or a Chromebook/Google Cloud Print policy) returned a "limit" error indicating her quota is exhausted.

### Supporting Evidence
- Error message explicitly references "limit" — consistent with quota enforcement, not a hardware or driver error.
- Color printing quotas are common in K-12 environments to control supply costs.
- Issue is isolated to her account, not a general printer outage.

### Other Possibilities (lower probability)
- Print job was sent to a color printer that is set to "color-restricted" for her user group (role-based restriction rather than usage quota).
- A monthly reset hasn't fired yet and she's temporarily over-quota.
- Misread error — could be a toner/supply limit on the printer itself (low/empty color cartridge), though wording "limit" in context of user account suggests user-level enforcement.

### Resolution Path
1. Check print management system (PaperCut or equivalent) for Heidi's current quota balance and reset date.
2. If quota exhausted: Admin can either (a) grant a one-time quota top-up, or (b) advise her to wait for the reset.
3. If role restriction: Add her to the color-printing-allowed group or adjust her printer permissions.
4. If toner/hardware: Escalate to facilities/printer vendor.
5. Interim workaround: If the worksheet is urgent, admin can print it on her behalf, or she can print in black-and-white if acceptable.

---

## Internal Note

Heidi Schroeder (GIS teacher) hit a color print quota/limit error trying to print a class worksheet. Likely her monthly color page quota is exhausted. Check PaperCut (or whatever print management system GIS uses) for her quota balance. If she's over limit and it's a legitimate classroom need, a one-time top-up is reasonable — teachers printing worksheets is core use. If GIS doesn't use quota software and this is a surprise, it may be a printer-level group restriction that needs to be revisited for teaching staff. No hardware issue suspected. Low urgency but blocks classroom prep — same-day response appropriate.
