---
type: system
date-created: 2026-02-25
purpose: Email triage rules, examples, and routing — v2 intent-based system
---

# Email Playbook v2

Hybrid playbook: deterministic rules for obvious patterns + example case library for judgment calls. Used by the intent classifier in `/process-email`.

**Design doc:** `_System/Projects/email-triage-v2.md`

## Global Rules

**NEVER trash/delete emails. Always archive.**
**Process newest emails first** (most recent → oldest)
**Always reply-all** unless Austin explicitly says to reply only to the sender.
**Never auto-send** — reply drafts always open in Apple Mail for review.

## Classification System

### Gating Order

Every email passes through these gates in order:

1. **Blacklist** → immediate auto-archive, no further processing. See `blacklist.md`.
2. **Whitelist** → always surfaces to Austin. Autonomous actions still execute (task, draft, forward, reference). See `whitelist.md`.
3. **Recent Correspondents** → full intent classification runs, all autonomous actions execute EXCEPT auto-archive. If classification = archive, surfaces to Austin instead. See `recent-correspondents.md`.
4. **Intent Classification** → fully autonomous. Uses deterministic rules below + example case library (`examples.md`).

### Action Buckets

An email can trigger one or more actions simultaneously:

| Action | What It Does | Autonomous? |
|--------|--------------|-------------|
| **archive** | Remove from inbox (GWS for Gmail, AppleScript for iCloud) | Yes (blocked for recent correspondents) |
| **task** | Create Things3 task with context + message:// link, then archive | Yes |
| **respond** | Draft reply in Apple Mail | Draft created, but always surfaces for review |
| **reference** | File to project/vault with email link, then archive | Yes |
| **forward** | Route to ticket system, invoices, etc., then archive | Yes |

### Account Weight

Account context is a signal, not a rule:
- **GIS / SJA / UMB** — nudge toward "actionable" (most email here matters)
- **Personal / iCloud** — nudge toward "archive" (most is noise)
- **KESA** — neutral (mix of business and noise)

## Deterministic Rules

Rules that don't need LLM judgment. Checked before the intent classifier runs.

### Sender Rules

| Sender/Domain | Action | Notes | Added |
|---------------|--------|-------|-------|
| noreply@airtable.com (form submissions) | archive | Form submissions auto-create tickets | 2026-03-01 |
| noreply@airtable.com (system warnings) | surface | System warnings need review | 2026-03-01 |
| @runescape.com | archive | Gaming subscription updates | 2026-02-25 |
| @ssa.gov | archive | Government newsletters/PSAs | 2026-02-25 |
| @ecmecc.org | archive | ECMECC mailing list - unwanted | 2026-02-25 |
| @menards.com | archive | Retail promo/ads | 2026-02-25 |
| @kaseya.com | archive | Vendor marketing/newsletters | 2026-02-26 |
| @zapier.com | archive | Zap error alerts - usually self-resolving | 2026-02-26 |
| @godaddy.com (GIS) | forward invoices@tcgis.org | GIS domain/hosting receipts | 2026-02-26 |
| @geico.com | archive | Auto insurance notifications/receipts | 2026-02-26 |
| @applecard.apple | archive | Apple Card payment receipts | 2026-02-26 |
| @playdeltaforce.com | archive | Gaming promo emails | 2026-02-26 |
| @wellsfargo.com | archive | Bank security PSAs/newsletters | 2026-02-26 |
| @brevo.com | archive | SMTP/email service notifications | 2026-02-27 |
| @goguardian.com | archive | Vendor marketing emails | 2026-02-27 |
| @thisisironclad.com | archive | Marketing/promo emails | 2026-02-27 |
| @cubebackup.com | archive | Monthly backup summaries - FYI only | 2026-03-01 |
| @opentable.com | archive | Reservation reminders and review requests | 2026-03-01 |
| @express.medallia.com | archive | Survey requests | 2026-03-01 |
| @goabode.com | archive | Home security alerts - go to phone | 2026-03-01 |
| @notifications.headspace.com | archive | Policy updates, app notifications | 2026-03-01 |
| @mohela.studentaid.gov | archive | Student loan auto pay notifications | 2026-03-01 |
| fireflightunraidtest771@gmail.com | archive | Unraid server alerts - usually FYI | 2026-03-01 |
| pncalerts@pnc.com | archive | Auto loan statements - auto pay handles it | 2026-03-01 |
| families-noreply@google.com | archive | Google family group notifications | 2026-03-01 |
| @privateinternetaccess.com | archive | VPN renewal notices | 2026-03-02 |
| @finance.safeco.com | archive | Home insurance billing — mortgage company pays | 2026-03-04 |
| @jamf.com | archive | Vendor sales outreach / AE check-ins | 2026-03-09 |
| @twingate.com | archive | Product update newsletters | 2026-03-10 |
| @ebay.com | archive | Order updates, shipping notifications | 2026-03-12 |
| members.ebay.com.hk | archive | eBay seller messages — dispatched confirmations | 2026-03-12 |
| @support.shadow.do | archive | Shadow app onboarding/product emails | 2026-03-12 |
| @embark.email | archive | Gaming promo emails (ARC Raiders) | 2026-03-17 |
| notifications@link.com | archive | Login notifications — security FYI | 2026-03-17 |
| @proxymity.io | archive | Shareholder filing notifications — FYI only | 2026-03-19 |
| @mail.wispr.ai | archive | Product marketing emails | 2026-03-19 |
| @iracing.freshdesk.com | archive | iRacing protest confirmations and support | 2026-03-19 |
| service@chewy.com | archive | Autoship delivery and shipping notifications | 2026-03-19 |
| @choicehotels.com | archive | Hotel survey requests | 2026-02-26 |
| @x.ai | archive | X/Twitter ads platform announcements | 2026-03-19 |
| @wargaming.net | archive | Gaming login/security notifications | 2026-03-19 |
| noreply-photos@google.com | archive | Google Photos sharing reminders | 2026-03-19 |
| support@iracing.com | archive | iRacing protest resolutions and support | 2026-03-19 |
| @aspiraconnect.com | archive | MN DNR promo newsletters | 2026-03-19 |
| @supabase.com | archive | Supabase project notifications (paused/inactive) | 2026-03-19 |
| no-reply@accounts.google.com | archive | Google security alerts (new sign-in notifications) | 2026-03-19 |
| @almeidaracingacademy.com | archive | Racing academy promo/onboarding emails | 2026-03-22 |
| email@updates.ynab.com | archive | YNAB account change notifications | 2026-03-22 |
| @youraccount.buffer.com | archive | Buffer account notifications (API keys, etc.) | 2026-03-22 |
| connexus@connexusenergy.com | archive | Utility bill notifications — on auto-pay | 2026-03-22 |
| @info.n8n.io | archive | n8n product emails / license keys | 2026-03-22 |
| noreply@plex.tv | archive | Plex sign-in notifications | 2026-03-22 |
| @substack.com | archive | Substack system emails (verification, social, shareable assets) | 2026-03-23 |
| umbrellasystems@substack.com | archive | Own Substack post delivery notifications | 2026-03-23 |
| @buffermail.com | archive | Buffer onboarding/marketing emails | 2026-03-23 |
| @squarespace.com | archive | Domain renewal reminders — auto-renew handles it | 2026-03-23 |
| notifications@infinitecampus.com | surface | Vendor notifications — may contain security/system alerts | 2026-03-23 |
| @drafthouse.com | archive | Movie ticket confirmations | 2026-03-24 |
| @offers.caseys.com | archive | Retail promo emails | 2026-03-24 |
| @ups.com | archive | Shipping notifications | 2026-03-24 |
| store@ui.com | archive | Ubiquiti Store order confirmations/shipping | 2026-03-24 |
| @garage61.net | archive | Sim racing platform account emails | 2026-03-24 |
| FccRegistration@fcc.gov | archive | FCC CORES security codes — ephemeral OTPs | 2026-03-24 |
| transactional@e.pnc.com | archive | PNC Bank newsletters/PSAs | 2026-03-24 |
| hello@buffer.com | surface | Buffer post failure notifications — may need content engine action | 2026-03-24 |

### Subject Pattern Rules

| Pattern | Action | Notes | Added |
|---------|--------|-------|-------|
| "We've updated our terms" | archive | Standard legal update | 2026-02-25 |
| "payment received" / "Auto Pay" / "Your Auto Pay payment" | archive | Payment receipts/confirmations | 2026-02-25 |
| "Unenrolled" (GIS/SJA) | forward to ticket system | Student unenrollment → IT cleanup | 2026-02-26 |
| "Automatic reply" / "Out of office" | archive | Auto-replies | 2026-02-26 |
| "Renewal complete" (GIS) | forward invoices@tcgis.org | GIS service renewals | 2026-02-26 |
| "Approved Event" (GIS) | forward techsupport@tcgis.org | Door scheduling from Kim | 2026-02-27 |

## Intent Classification Guide

When deterministic rules don't match, classify by **intent** — what the email is trying to get Austin to do.

**Pre-classification: Check sent mail first.** Before classifying any email as `respond` or `task`, check whether Austin has already replied to the thread. Query sent mail for the thread/subject. If Austin already responded → classify as `archive` instead.

**Read the email content.** Then determine which action bucket(s) apply:

- **GIS/SJA staff requesting tech help, software access, or IT support** → `forward techsupport` (techsupport@tcgis.org for GIS, techsupport@sejongacademy.org for SJA). These are support tickets, not direct asks for Austin. Always route to the ticket system.
- **Is someone asking Austin to do something?** → `task` (+ `respond` if they expect a reply)
- **Does Austin need to reply to this?** → `respond`
- **Does this relate to an active project or contain info Austin needs later?** → `reference`
- **Does this need to go to someone else?** → `forward` (ticket system, invoices, etc.)
- **None of the above?** → `archive`

**For ambiguous cases:** Check `examples.md` for similar emails with confirmed classifications.

**Account weight:** GIS/SJA/UMB emails with uncertain intent → lean toward surfacing. Personal/iCloud → lean toward archive.

## Routing Tables

### Support Ticket Routing

| Account | Forward To | Notes |
|---------|------------|-------|
| GIS | techsupport@tcgis.org | Student/staff support requests |
| SJA | techsupport@sejongacademy.org | Student/staff support requests |

**Always forward support tickets, even if self-resolved** — ticket system is source of truth.

### Invoice/Receipt Routing

| Account | Forward To | Notes |
|---------|------------|-------|
| GIS | invoices@tcgis.org | All receipts, renewals, invoices for GIS services |

**Forward then archive** — keeps accounting in the loop.

## Project-Related Emails

When an email is clearly related to an ongoing project:
1. Check if project exists in `_System/Projects/`
2. If yes: capture relevant context + message:// link to the project, then archive
3. If no but should exist: create the project first
4. Key context to capture: meeting dates, decisions, contacts, action items

### Email Linking

Use the **real RFC Message-ID header** from the email, NOT the Gmail hex ID. The Gmail hex ID (e.g., `19d2546cebecae83`) is an internal Gmail identifier — it will NOT work in `message://` links.

Extract the `Message-ID` header during Step 5 fetch, then URL-encode it:
```markdown
[Email thread](message://%3Creal-message-id@domain.com%3E)
```

Example: if the header is `Message-ID: <CAAAGpP-xyz@mail.gmail.com>`, the link is:
`message://%3CCAAAGpP-xyz@mail.gmail.com%3E`

## Time-Limited Requests

When processing emails about temporary changes (e.g., "forward emails for 3 days"):
- If the time period has passed, create a **follow-up task** to undo/clean up
- Archive the original email after creating the task

## Training Mode

**Currently active.** During training:
1. Every email is presented to Austin with classification + reasoning
2. Austin confirms or corrects each classification
3. Corrections are stored in `examples.md` with: trimmed email + correct action(s) + reasoning
4. Deterministic rules are added/updated when patterns are clearly repeatable
5. Track accuracy: total emails classified vs corrections needed
6. **Accuracy counting is exact.** Any item where Austin's final action differs from the presented classification counts as a correction — even if Austin doesn't explain why. "yes to the rest" confirms the remaining items, NOT all items. Count: corrections = items where Austin changed the action. Confirmed = items where Austin accepted the classification (explicit "yes/yup" or included in "yes to the rest" after specifying exceptions). Never report 0 corrections when Austin overrode any item.

**Go-live threshold:** 95%+ accuracy over ~1 month of supervised triage.

## Learning Log

Track decisions for pattern recognition. Format:
`YYYY-MM-DD | sender | subject (truncated) | action | why`

| Date | Sender | Subject (truncated) | Action | Why |
|------|--------|---------------------|--------|-----|
| 2026-03-17 | adobesign@adobesign.com | Completed: signed doc notification | archive | Completed document notification — no action |
| 2026-03-17 | @almeidaracingacademy.com | Welcome / Confirm account | archive | Racing academy signup confirmation |
| 2026-03-17 | no-reply@email.kraken.com | 2025 Form 1099-DA/MISC | archive | Below IRS threshold — FYI only |
| 2026-03-17 | service@chewy.com | package shipping | archive | Shipping notification — FYI |
| 2026-03-17 | noreply@notifications.allydvm.com | vet reminders | task + archive | Vet vaccine reminders — always create task |
| 2026-03-17 | keepersecurity@servicenowservices.com | case comments | task + archive | Support case needing reply — always task |
| 2026-03-19 | noreply@proxymity.io | Important information from M1 (x2) | archive | Shareholder filing notifications |
| 2026-03-19 | hello@mail.wispr.ai | Voice-to-text promo | archive | Product marketing |
| 2026-03-19 | support@iracing.freshdesk.com | Received Protest | archive | Protest confirmation — FYI |
| 2026-03-19 | service@chewy.com | Autoship delivered | archive | Delivery notification |
| 2026-03-19 | do_not_reply@intuit.com | Subscription canceled | archive | Austin said archive — not concerned |
| 2026-03-19 | ant.wilson@supabase.com | Jarvis Dev pausing | archive | Project not actively needed |
| 2026-03-19 | salesforceadmins@renaissance.com | Action Required on ticket | archive | Issue likely resolved |
| 2026-03-19 | support@freshworks.com | Set your Freshworks password | archive | Expired reset link |

| 2026-03-19 | cblackburn@x.ai | X Ads platform migration | archive | Vendor platform announcement — no active campaigns |
| 2026-03-19 | dstegmann@tcgis.org | Re: Extra Chromebook Charger | archive | Thread resolved — drop-off location confirmed, task already exists |
| 2026-03-19 | necvoicemail@mg.centraltelephone.com | Voice Message ATHENS GA (0m 6s) | archive | Voicemail <30s — robocall |
| 2026-03-19 | ant.wilson@supabase.com | Jarvis Dev paused | archive | Free-tier auto-pause, project not active |
| 2026-03-19 | noreply@wargaming.net | Invalid password attempt | archive | Login security notification — FYI |
| 2026-03-19 | noreply-photos@google.com | Photo sharing reminder | archive | Recurring privacy reminder — no action |
| 2026-03-19 | support@iracing.com | Resolved Protest | archive | Protest resolution — FYI |
| 2026-03-19 | MN DNR | Spring fishing opportunities | archive | Promo newsletter |
| 2026-03-19 | no-reply@accounts.google.com | Security alert (UMB) | archive | Google sign-in notification — FYI |
| 2026-03-19 | microsoft-noreply@microsoft.com | Credit card declined (GIS M365) | task | GIS billing — create task, no need to forward (they already know) |
| 2026-03-19 | no-reply@accounts.google.com | Security alert copy (KESA) | archive | Recovery email copy of UMB alert |
| 2026-03-19 | csmieja@nmfamn.org | Invoice payment reminder (KESA) | task | Check mailed 3/6 — need to confirm receipt |
| 2026-03-20 | noreply@airtable.com | Student Onboarding form submission | archive | RULE: form submissions auto-create tickets |
| 2026-03-20 | geico@et.geico.com | Auto Pay payment processed soon | archive | RULE: @geico.com |
| 2026-03-20 | jesse@umbrellasystems.net | Fwd: IT Support (x4) + Cold | reference → archive | Sales outreach context → school-prospects project |
| 2026-03-20 | ivollenweider@germanschool-mn.org | Re: Reboot systems 1099 address change | archive | Austin already replied |
| 2026-03-20 | ivollenweider@germanschool-mn.org | Re: New Card | archive | Austin already replied |
| 2026-03-20 | maplebrookpet@gmail.com | Koda invoice 3.20.26 | archive | Vet invoice/receipt |
| 2026-03-22 | hello@youraccount.buffer.com | New API key created on Buffer (x2) | archive | FYI notification from Austin's own action |
| 2026-03-22 | email@updates.ynab.com | Your password has been changed | archive | Security FYI from Austin's own action |
| 2026-03-22 | fireflightunraidtest771@gmail.com | Unraid Status: UPS Alert (x2) | archive | RULE: Unraid server alerts = FYI |
| 2026-03-22 | @almeidaracingacademy.com | You left something unfinished / MX-5 / Community Power (x3) | archive | RULE: @almeidaracingacademy.com |
| 2026-03-22 | connexus@connexusenergy.com | Notice of New Connexus Energy Bill | archive | Utility bill on auto-pay |
| 2026-03-22 | hello@info.n8n.io | Free n8n license key | archive | FYI — retrievable later if needed |
| 2026-03-22 | noreply@plex.tv | New sign-in to your Plex account | archive | Expected sign-in from own infrastructure |
| 2026-03-22 | necvoicemail@mg.centraltelephone.com | Voice Message ATHENS GA (0m 4s) | archive | Voicemail <30s = robocall |
| 2026-03-22 | jesse@sejongacademy.org | Fwd: CRT Related Proposal | archive | Austin already replied (CORRECTION: should have checked sent mail) |
| 2026-03-22 | hoh@sejongacademy.org | Re: Sejong School Calendar | respond + archive | Follow-up question from Oh — draft created |
| 2026-03-23 | umbrellasystems@substack.com | Summer Project Planning Checklist (x2 + shareable assets) | archive | Own Substack post notifications |
| 2026-03-23 | no-reply@substack.com | Verification code + People you know | archive | Substack system emails |
| 2026-03-23 | onboarding@buffermail.com | Need help coming up with content? | archive | Buffer onboarding/marketing |
| 2026-03-23 | microsoft-noreply@microsoft.com | Credit card declined (GIS M365) | archive | Repeat of 3/19 — task already exists |
| 2026-03-23 | notifications@infinitecampus.com | Security incident notice | reference | Vendor breach disclosure — Salesforce access, not customer DBs |
| 2026-03-23 | no-reply@squarespace.com | Domain renewal in 15 days (SJA) | archive | sejongacademy.org auto-renews Apr 6, $20 — no action |
| 2026-03-23 | noreply@plex.tv | New sign-in (Personal) | archive | RULE: noreply@plex.tv |
| 2026-03-24 | hello@buffermail.com | Your daily recap | archive | RULE: @buffermail.com |
| 2026-03-24 | onboarding@buffermail.com | 3 tips to create your first post | archive | RULE: @buffermail.com |
| 2026-03-24 | no-reply@substack.com | Growth tip: Share snippets | archive | RULE: @substack.com |
| 2026-03-24 | jesse@umbrellasystems.net | Fwd: IT Support (Laura Jeffrey) | reference + archive | School prospect outreach history |
| 2026-03-24 | jesse@umbrellasystems.net | Fwd: IT Support (TCGIS exec) | reference + archive | School prospect outreach history |
| 2026-03-24 | hello@buffer.com | One of your updates failed to post | task + archive | Content engine X post failed — needs investigation |
| 2026-03-24 | ezehnpfennig@tcgis.org | Re: RFP or not? | reference + archive | Procurement policy context for today's in-person conversation |
| 2026-03-24 | info@tcgis.org | Raise Craze Kick-Off | archive | School community newsletter |
| 2026-03-24 | ealbers@tcgis.org | Re: Governance Drive Permissions | archive | Thread resolved — "Yes! Thank you" |
| 2026-03-24 | CC881G@att.com | Federal School Safety Network (x2) | archive | Cold outreach + self-correction |
| 2026-03-24 | dstegmann@tcgis.org | Re: Extra Chromebook Charger | archive | Thread resolved — "Thank you" |
| 2026-03-24 | quickbooks@notification.intuit.com | Payment received Invoice #10474 | archive | RULE: "payment received" subject |
| 2026-03-24 | pkginfo@ups.com | Your Package Has Shipped (Ubiquiti) | archive | Shipping notification |
| 2026-03-24 | hello@garage61.net | Activate your account | archive | Account setup email |
| 2026-03-24 | store@ui.com | Order US4952560 shipped + confirmed (x2) | archive | Order notifications |
| 2026-03-24 | FccRegistration@fcc.gov | Temporary Security Code (x2) | archive | Expired OTPs |
| 2026-03-24 | tickets@drafthouse.com | Order Confirmation: PROJECT HAIL MARY | archive | Ticket confirmation |
| 2026-03-24 | transactional@e.pnc.com | Don't fall for a scam | archive | Bank PSA/newsletter |
| 2026-03-24 | dstegmann@tcgis.org | Printer Code? | archive | Austin already responded — helpdesk request |
| 2026-03-24 | tgerhart@germanschool-mn.org | Missing Chromebook | archive | Austin already responded — forwarded to techsupport |
| 2026-03-24 | jmonfre@germanschool-mn.org | Badge | archive | Austin already responded — badge replacement |
| 2026-03-24 | sdonahoe@germanschool-mn.org | work sheet crafter | forward techsupport | Software access request |
| 2026-03-24 | korlova@germanschool-mn.org | Worksheet crafter | archive | Austin already responded — software access |
| 2026-03-24 | offers@offers.caseys.com | TODAY ONLY! | archive | Retail promo |
| 2026-03-24 | alerts@mail.zapier.com | GIS Badge Requests Zap error | archive | RULE: @zapier.com |
| 2026-03-25 | jesse@umbrellasystems.net | Re: E-Rate Urgent Email Chain | reference + archive | Jesse feedback on outreach emails, will send with fixes |
| 2026-03-25 | jesse@umbrellasystems.net | Re: Website images | respond (images dumped) | Jesse sent 19 images, asked questions needing Austin's reply |
| 2026-03-25 | onboarding@buffermail.com | Turn your first post into 3x | archive | RULE: @buffermail.com |
| 2026-03-25 | no-reply@substack.com | Weekly Stack digest | archive | RULE: @substack.com |
| 2026-03-25 | no-reply@notifications.ui.com | UniFi Console User Role Changed (x2) | archive | Expected notification from own action |
| 2026-03-25 | support@xfinitymobile.com | Your payment failed (GIS) | archive | Austin already fixing it — no task needed |
| 2026-03-25 | kgogo@germanschool-mn.org | Re: Proposal 2112437658 approved | task + archive | Apple iPad SpEd purchase approved — convert to order |
| 2026-03-25 | info@tcgis.org | Board Meeting Reminder 3/26 | archive | Community newsletter |
| 2026-03-25 | estillwell@tcgis.org | Re: Missing Chromebook | archive | Thread resolved — student found it |
| 2026-03-25 | dginter@sejongacademy.org | Re: Bullying in Gym Closet (3 msgs) | archive | Austin already solved the permissions request |
| 2026-03-25 | jesse@sejongacademy.org | Fwd: color printing for March | archive | Oh approved, just archive per Austin |
| 2026-03-25 | nmeester@nuancefinancial.com | Re: TY2025 Return | reference + task + archive | CPA sent full returns, proposes May meeting |
| 2026-03-25 | pkginfo@ups.com | Package coming today / Pre-arrival (x2) | archive | RULE: @ups.com |
| 2026-03-25 | support@xfinitymobile.com | Payment successful + card updated (x2) | archive | Confirmation of Austin's fix |

**Last Updated:** 2026-03-25
