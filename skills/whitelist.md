---
type: system
purpose: Protected senders — emails from these sources always surface to Austin
maintained-by: process-email skill (auto-updates from project files) + manual curation
---

# Email Whitelist

Emails matching any rule below **always surface to Austin** during triage. Autonomous actions (task, draft, forward, reference) still execute, but Austin always sees the email and verifies.

## Protected Domains

All email from these domains surfaces regardless of sender or content.

| Domain | Reason | Added |
|--------|--------|-------|
| @germanschool-mn.org | GIS staff — all emails are actionable | 2026-03-19 |
| @sejongacademy.org | SJA staff — all emails are actionable | 2026-03-19 |
| @tcgis.org | GIS org domain — all emails are actionable | 2026-03-19 |

## Protected Senders

Specific email addresses that always surface.

| Sender | Reason | Added |
|--------|--------|-------|
| jesse@rebootsystems.net | Business partner (Umbrella 50/50) | 2026-03-19 |
| jesse.schonfeld@gmail.com | Business partner (personal) | 2026-03-19 |

## Active Project Contacts

**Auto-populated** from `Projects/` files. Any sender mentioned in an active project file is treated as whitelisted. This section is rebuilt each time `/process-email` runs by scanning project files for email addresses and contact names.

_Last rebuilt: never (pending first run)_

## Rules

1. Domain match is checked first (fastest)
2. Then specific sender match
3. Then active project contact match
4. If any match → email surfaces to Austin
5. Autonomous actions still execute — whitelist doesn't disable processing, it ensures visibility
