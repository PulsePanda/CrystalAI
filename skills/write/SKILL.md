---
name: crystal:write
description: This skill should be used when the user asks to "/write", "draft an email", "write a message", "help me write", or wants content drafted in Austin's voice. Drafts emails, messages, and other content in Austin's personal writing style, learns from corrections, and creates Apple Mail drafts on approval.
version: 1.0.0
allowed-tools: Read, Write, Edit
---

# /write - Draft Content in Austin's Voice

Write emails, messages, or other content in Austin's personal writing style. This skill learns from corrections — when Austin fixes something, the underlying rule is saved for future drafts.

## Usage

```
/write [description of what to write]
```

**Examples:**
- `/write an email to all staff at GIS letting them know that Jesse is going to cover for me on the 19th`
- `/write a reply to Kate about the radio interference issue`
- `/write a message to Kim following up on the VOIP quote`

## How It Works

### Step 1: Load Writing Style + Rules

1. Read `references/writing-rules.md` for accumulated rules learned from previous corrections
2. Identify which rules are relevant to this draft (by recipient, content type, context)

> Writing style and voice patterns are in the vault root `CLAUDE.md` (auto-loaded — no need to re-read).

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
- Recipient is known from previous context (e.g., "Kate" = friendly, "all staff" = professional but warm)

### Step 4: Draft Content

Write the content following Austin's style:

**Tone:**
- Casual but competent
- Friendly without being performative
- Adjust formality based on relationship

**Structure:**
- Short paragraphs, no bullet points in casual emails
- Break things up naturally but don't over-organize

**Voice patterns:**
- "Basically" to simplify technical stuff
- "Let me know your thoughts" or "Let me know" to close
- "I think," "I assume," "I'm not sure" — direct but not overconfident
- Occasional mild language when it fits
- ALL CAPS for emphasis sparingly
- Contractions always

**Technical explanations:**
- Context first, then the problem, then options
- Use concrete examples
- Admit uncertainty when it exists

**Never use:**
- "I hope this finds you well"
- "Please don't hesitate to reach out"
- "Rest assured"
- "I completely understand"
- Excessive em-dashes
- Bullet points in casual emails
- Corporate filler or fake warmth

### Step 5: Create Draft in Apple Mail (emails only)

**Never show the draft text in the terminal.** For emails, go straight to creating the draft in Apple Mail via AppleScript. Austin edits and sends from Mail directly.

Use the **`email` tool skill** to create the draft. Confirm with one line: "Draft created in Mail — [To] / [Subject]."

**Skip this step if:**
- Content is not an email (message, Slack, etc.) — output those inline
- User explicitly says they don't want a draft created

### Step 6: Revise and Learn

When the user requests changes via reply:

1. **Apply the fix** and create a new draft in Apple Mail
2. **Extract the underlying rule** — not just what changed, but *why* and *when* to apply it in the future
3. **Save the rule** to `references/writing-rules.md` under the appropriate section

**How to extract rules:**

| User says | Rule to save |
|-----------|--------------|
| "Add the techsupport email" | When writing to GIS staff about coverage/absence, include techsupport@tcgis.org and the ticket bookmark |
| "Too formal" | [Recipient] prefers casual tone |
| "Don't use 'cheers'" | Never use "cheers" as a closing |
| "Always CC Kim on vendor stuff" | When writing to vendors, mention CC'ing Kim or include her |

**Rule format in writing-rules.md:**

```markdown
### [Context heading]
- [When to apply]: [What to do]
- [Additional details if needed]
```

**After saving, confirm:** "Got it — I'll remember that for next time."
