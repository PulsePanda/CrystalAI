---
name: write
description: This skill should be used when the user asks to "/write", "draft an email", "write a message", "help me write", or wants content drafted in the user's voice. Drafts emails, messages, and other content in the user's personal writing style, learns from corrections, and outputs drafts for review.
version: 1.0.0
allowed-tools: Read, Write, Edit
---

# /write - Draft Content in the User's Voice

Write emails, messages, or other content in the user's personal writing style. This skill learns from corrections -- when the user fixes something, the underlying rule is saved for future drafts.

## Usage

```
/write [description of what to write]
```

**Examples:**
- `/write an email to the team letting them know I'll be out Friday`
- `/write a reply to the vendor about the pricing proposal`
- `/write a message to the client following up on the demo`

## How It Works

### Step 1: Load Writing Style + Rules

1. Read `state/behavioral/writing-style.md` for the user's voice patterns (populated by `/teach`)
2. Read `references/writing-rules.md` for accumulated rules learned from previous corrections
3. Identify which rules are relevant to this draft (by recipient, content type, context)

If `state/behavioral/writing-style.md` doesn't exist, use sensible defaults (concise, professional but human, no corporate filler) and suggest running `/teach` with a few writing samples.

### Step 2: Parse the Request

Extract from the user's request:
- **Content type:** email, message, reply, etc.
- **Recipient(s):** who it's going to
- **Topic:** what it's about
- **Key points:** any specific information to include

### Step 3: Assess Relationship (if unclear)

If the recipient relationship isn't obvious from context or previous sessions, ask:

> How formal should this be? (casual/friendly, professional, formal)

**Skip this step if:**
- User specified tone in the request
- Recipient is known from previous context

### Step 4: Draft Content

Write the content following the user's style from `state/behavioral/writing-style.md`.

**If no style guide exists yet, use these safe defaults:**

**Tone:**
- Professional and clear
- Adjust formality based on the relationship and context

**Structure:**
- Short paragraphs
- Natural flow — don't over-organize

**Note:** Run `/teach` with a few writing samples so Claude can match your actual voice. Until then, drafts will use a generic professional tone.

### Step 5: Present the Draft

**For emails:** Present the draft with To, Subject, and Body clearly formatted. If the user has an email client integration configured (e.g., Apple Mail MCP, Gmail MCP), offer to create a draft directly. Otherwise, output the text for the user to copy.

**For non-email content** (Slack messages, texts, etc.): Output the text inline.

### Step 6: Revise and Learn

When the user requests changes via reply:

1. **Apply the fix** and present the updated draft
2. **Extract the underlying rule** -- not just what changed, but *why* and *when* to apply it in the future
3. **Save the rule** to `references/writing-rules.md` under the appropriate section

**How to extract rules:**

| User says | Rule to save |
|-----------|--------------|
| "Too formal" | [Recipient/context] prefers casual tone |
| "Don't use 'cheers'" | Never use "cheers" as a closing |
| "Always CC [name] on vendor stuff" | When writing to vendors, CC [name] |
| "Add the support email" | When writing about [topic], include [resource] |
| "Shorter" | [Context] prefers brevity -- cut greetings, get to the point |

**Rule format in writing-rules.md:**

```markdown
### [Context heading]
- [When to apply]: [What to do]
- [Additional details if needed]
```

**After saving, confirm:** "Got it -- I'll remember that for next time."
