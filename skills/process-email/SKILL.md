---
name: crystal:process-email
description: Intent-based email triage with training mode. Use when the user asks to "triage email", "process my inbox", "check email", "clear my inbox", "/email", "what email do I have", or wants to get to inbox zero. Classifies emails by intent (not just sender), runs a 4-gate system (blacklist → whitelist → recent correspondents → intent classification), supports compound actions (task + respond + reference on the same email), and learns from corrections during the training period. Currently in supervised training mode — all classifications presented for confirmation. For raw email access operations only, use the `email` tool skill.
version: 2.0.0
allowed-tools: Bash, Read, Write, Edit
---

# /process-email v2 — Intent-Based Email Triage

Classify every email by what it's asking the user to do, not just who sent it. Run the gating system, present classifications with reasoning, learn from corrections.

> **Currently in training mode.** Every classification is presented for the user's confirmation. Corrections feed the example case library. Once accuracy hits 95%+ over ~1 month, the system goes fully autonomous.

> For raw email access patterns (GWS commands, AppleScript draft/reply ops), see the `email` tool skill.

**Design doc:** `Projects/email-triage-v2.md`

---

## Step 1: Load All Reference Files

Read these files to build the classification context:

1. `{SKILL_DIR}/references/playbook.md` — deterministic rules, intent guide, routing tables
2. `{SKILL_DIR}/references/whitelist.md` — protected senders/domains
3. `{SKILL_DIR}/references/blacklist.md` — blocked senders/domains
4. `${CLAUDE_PLUGIN_ROOT}/state/integrations/recent-correspondents.md` — rolling 6-month list
5. `${CLAUDE_PLUGIN_ROOT}/state/patterns/email-classification-examples.md` — case library of past corrections with reasoning

---

## Step 2: Check Heart Notifications

Read `${CLAUDE_PLUGIN_ROOT}/state/operational/heart-notifications.md`. If the table has any rows, these are emails Heart previously flagged but didn't execute on.

- Each row becomes a numbered item in the triage presentation alongside live inbox items
- Prefix with `[Heart]` in the item header so the source is clear
- Use the Message-ID to fetch the full email via GWS if body content is needed
- After the user makes a decision and it's executed, remove that row from `heart-notifications.md`

If the file has no rows, skip silently. (Note: Heart email triage is currently disabled during the v2 rebuild, so this section will typically be empty.)

---

## Step 3: Fetch Full Inbox

Fetch all accounts in parallel. All commands require `dangerouslyDisableSandbox: true`.

**Gmail accounts (UMB, GIS, SJA, KESA, Personal) — GWS only:**
```bash
GWS="${CLAUDE_PLUGIN_ROOT}/scripts/gws-mac.sh"
"$GWS" ACCOUNT gmail users messages list --params '{"userId":"me","q":"in:inbox","maxResults":50}' 2>/dev/null
```
Run all 5 in parallel. Returns Gmail hex message IDs.

Then fetch full content for each message:
```bash
"$GWS" ACCOUNT gmail users messages get --params '{"userId":"me","id":"MSG_ID","format":"full"}' 2>/dev/null
```

**iCloud — apple-mail-mcp only (no GWS):**
```
get_emails(account="iCloud", mailbox="INBOX", filter="all", limit=50)
```

---

## Step 4: Classify Each Email

For every email, run the gating system in order. The gate determines both what action to take AND whether the user needs to see it.

### Gate 1: Blacklist Check

Check sender address and domain against `blacklist.md`. If match → **auto-archive immediately**, no further processing, no presentation to the user. Log it silently.

### Gate 2: Whitelist Check

Check sender against `whitelist.md` in this order:
1. Protected Domains (domain match)
2. Protected Senders (exact email match)
3. Active Project Contacts (email or name match)

If match → **mark as "must surface"**. Still run intent classification to determine actions, but the user will always see this email regardless of classification result.

### Gate 3: Recent Correspondents Check

Check sender against `${CLAUDE_PLUGIN_ROOT}/state/integrations/recent-correspondents.md`. If match → **mark as "no auto-archive"**. Run intent classification normally. All autonomous actions can execute except archive — if classification says "archive," it surfaces to the user instead of executing.

### Gate 4: Intent Classification

For emails not caught by gates 1-3, classify by intent:

**First, check deterministic rules** (playbook sender rules and subject pattern rules). If a rule matches, use that classification — no LLM judgment needed.

**If no rule matches, read the email content and classify by intent:**

- **Is someone asking the user to do something?** → `task` (+ `respond` if they expect a reply)
- **Does the user need to reply to this?** → `respond`
- **Does this relate to an active project or contain info the user needs later?** → `reference`
- **Does this need to go to someone else?** → `forward` (check routing tables in playbook)
- **None of the above?** → `archive`

**Account weight** is a signal: GIS/SJA/UMB emails with uncertain intent → lean toward surfacing. Personal/iCloud → lean toward archive.

**Compound actions:** A single email can trigger multiple actions (e.g., `task + respond + reference`). All actions are independent.

**For ambiguous cases:** Check the email classification examples in `${CLAUDE_PLUGIN_ROOT}/state/patterns/email-classification-examples.md` for similar past emails with confirmed classifications and reasoning.

---

## Step 5: Present Classifications (Training Mode)

Group by thread (normalize subjects, strip Re:/RE:/Fwd:/FW: prefixes). Present newest-first.

**In training mode, present ALL non-blacklisted emails** with classification reasoning so the user can confirm or correct.

**Thread format:**
```
**N. [Account] Subject** — From (Date) [GATE]
[1-2 sentence summary of latest message]
**Classification:** [action(s)] — [reasoning]
```

Gate labels:
- `[WHITELIST]` — always surfaces, autonomous actions will execute
- `[RECENT]` — can't be auto-archived
- `[AUTO]` — fully autonomous (in training mode, still shown for confirmation)
- `[RULE]` — matched a deterministic rule
- `[Heart]` — from Heart notifications

For threads with multiple messages:
```
**N. [Account] Subject** — 3 messages (newest: From, Date) [GATE]
[Summary covering the whole thread]
**Classification:** archive — thread resolved (final message is a "thanks" sign-off)
```

---

## Step 6: Wait for Response

The user responds to all items at once:
- Numbers with actions: `1 archive 2 task 3 archive`
- Shorthand: `1 2 3` = archive those | `all archive` = archive everything
- `yes` / `yup` = go with the classification | `all yup` = go with all classifications
- Actions: `archive`, `task`, `task: [description]`, `reply: [draft]`, `reference`, `forward`, `skip`, `stop`
- Corrections include the why: `3 task — this is actually asking me to do something because [reason]`

---

## Step 7: Execute All Actions

Execute confirmed actions in **separated batches by operation type** to prevent cascading failures.

**Batch 1 — GWS Archives (all Gmail accounts):**
```bash
GWS="${CLAUDE_PLUGIN_ROOT}/scripts/gws-mac.sh"
"$GWS" ACCOUNT gmail users messages modify --params '{"userId":"me","id":"MSG_ID"}' --json '{"removeLabelIds":["INBOX"]}' 2>/dev/null
```
Batch-archive multiple messages from the same account:
```bash
for id in MSG_ID1 MSG_ID2 MSG_ID3; do
  "$GWS" ACCOUNT gmail users messages modify --params "{\"userId\":\"me\",\"id\":\"$id\"}" --json '{"removeLabelIds":["INBOX"]}' 2>/dev/null
done
```

**Batch 2 — Things3 tasks (MCP tools):**
Use `things3` tool skill. Always include `message://` link in task notes. **NEVER mix Things3 operations with GWS archives in the same parallel batch** — if Things3 fails, it cancels all sibling calls.

**Building message:// links:** The link MUST use the real RFC `Message-ID` header from the email, NOT the Gmail hex ID. Gmail hex IDs (like `19d2546cebecae83`) are internal Gmail identifiers — they are NOT Message-IDs and will produce broken links. Extract the `Message-ID` header during Step 5 (fetch full content) and URL-encode it: `message://%3CACTUAL-MESSAGE-ID@domain.com%3E`.

**Batch 3 — Forwards/Drafts (AppleScript):**
AppleScript draft/reply/forward windows via `email` tool skill `references/applescript-snippets.md`. Reply drafts always open in Apple Mail for the user's review — never auto-send.

**Batch 4 — File operations:**
Project file updates, playbook updates, Heart notification clearing, email classification examples updates.

**Archiving iCloud — AppleScript only (no GWS):**
See `email` tool skill `references/applescript-snippets.md` for the iCloud archive pattern.

**CRITICAL: One Bash error in a parallel batch cancels ALL sibling calls in that batch.** This is why batches must be separated by risk profile.

---

## Step 8: Learn from Corrections

Corrections can take many forms. Generally, when the user replies to the message, they'll list out the emails corrections/actions by the number it was presented with. If the response to the email step is different than the one you recommended, it is considered a correction.

When the user corrects a classification, two things happen:

### 8a: Store Example in Case Library

For each correction, append to `${CLAUDE_PLUGIN_ROOT}/state/patterns/email-classification-examples.md`:

```markdown
### Example NNN
**From:** sender@domain.com
**To:** account
**Subject:** Subject line
**Date:** YYYY-MM-DD
**Body:**
[Trimmed email content — strip signatures, quoted reply chains, legal disclaimers, image placeholders. Keep meaningful content and headers only.]

**Classification:** [correct action(s)]
**Reasoning:** [the user's explanation of WHY this is the correct classification]
```

If the user doesn't provide explicit reasoning, ask: "Why is this [action] instead of [what I guessed]?" The reasoning is what makes the case library useful — it teaches the distinctions that matter.

### 8b: Update Deterministic Rules

If the correction reveals a clearly repeatable pattern (same sender always gets the same action, subject pattern always means the same thing), add it to the playbook's deterministic rules. Don't add rules for one-off judgment calls — those belong in the examples.

### 8c: Update Learning Log

Add the decision to the playbook's Learning Log table.

### 8d: Update Gmail Filters

When archiving a new sender with no action and the pattern is clearly repeatable, add an entry to `${CLAUDE_PLUGIN_ROOT}/state/integrations/gmail-filters.xml`.

---

## Step 9: Verify All Actions

**This step is mandatory. Never skip it.**

1. Re-fetch inbox for ALL accounts that had messages (not just 1-2 — all of them)
2. Confirm `resultSizeEstimate: 0` for each
3. If any messages remain, re-archive them immediately
4. Only after verification passes → report results

**Never report "done" or "inbox zero" without running this verification.** Silent failures have caused emails to stay in inbox without the user knowing.

---

## Step 10: Report Results

Summarize the session:
- Total emails processed
- Classifications confirmed vs corrected (accuracy tracking)
- Actions executed
- New rules or examples added
- Any emails skipped or left in inbox

**Auto-continue** until all inboxes are empty. Never ask "continue?" between batches.

---

## Safety Rules

1. **Never auto-send** — reply drafts always open in Apple Mail for review
2. **Never trash/delete** — always archive
3. **Always reply-all** — unless the user says otherwise
4. **Whitelist is sacred** — whitelisted emails always surface, no exceptions
5. **Recent correspondents can't be auto-archived** — other autonomous actions are fine
6. **Corrections include the why** — if the user corrects without explaining, ask why

---

## Thread Handling

- **Collapsed threads:** Group all messages with same normalized subject. Summarize whole thread, classify based on latest state.
- **Resolved threads:** Clearly done (sign-off replies, "thanks", "sounds good") → classify as archive.
- **Older thread messages in inbox:** Once the user decides on thread, archive all messages together.

---

## Related

- `email` tool skill — raw email access patterns (GWS commands, AppleScript snippets)
- `things3` tool skill — task creation (MCP tools + AppleScript patterns)
- `Projects/email-triage-v2.md` — design doc
- `{SKILL_DIR}/references/playbook.md` — deterministic rules + intent guide
- `{SKILL_DIR}/references/whitelist.md` — protected senders
- `{SKILL_DIR}/references/blacklist.md` — blocked senders
- `${CLAUDE_PLUGIN_ROOT}/state/integrations/recent-correspondents.md` — 6-month rolling window
- `${CLAUDE_PLUGIN_ROOT}/state/patterns/email-classification-examples.md` — case library
- `${CLAUDE_PLUGIN_ROOT}/state/integrations/gmail-filters.xml` — Gmail filter rules
