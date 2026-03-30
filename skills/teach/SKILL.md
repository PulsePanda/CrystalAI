---
name: teach
description: This skill should be used when the user asks to "/teach", "teach you my style", "here's an example of my writing", "learn from this email", or pastes writing examples for Claude to analyze. Analyzes writing samples to extract patterns, updates the style guide, and saves examples for future reference.
version: 1.0.0
allowed-tools: Read, Write, Edit
---

# /teach - Teach Writing Style from Examples

Analyzes writing samples the user provides, extracts new patterns, and updates the permanent style reference.

---

## Step 1: Receive Examples

Accept one or more writing examples -- emails, Slack messages, texts, anything. If context would help ("who was this to, what was the situation?"), ask briefly.

---

## Step 2: Analyze Patterns

Read `state/behavioral/writing-style.md` (relative to the CrystalAI root). Compare the existing style rules against the new samples and look for:

- **New patterns:** phrases, openers/closers, structural habits not yet documented
- **Existing patterns confirmed:** note if examples reinforce what's already there
- **Anti-patterns:** things the user clearly avoids that aren't documented yet
- **Context-specific rules:** formal vs casual, internal vs external differences

If an example contradicts existing style rules, flag it and ask which is correct.

### Analysis Framework

For each sample, extract:

| Dimension | What to Look For |
|-----------|-----------------|
| **Tone** | Formality level, warmth, humor, confidence |
| **Structure** | Paragraph length, use of bullets/lists, greeting/closing patterns |
| **Vocabulary** | Signature phrases, technical register, filler words, contractions |
| **Voice** | Active vs passive, first person patterns, hedging vs assertiveness |
| **Formatting** | Capitalization habits, punctuation style, emphasis (bold, caps, italics) |
| **Context-switching** | How tone shifts between audiences (boss vs peer vs client) |

---

## Step 3: Save Examples

Append to `state/behavioral/writing-examples.md` (relative to CrystalAI root):

```markdown
## YYYY-MM-DD - [Brief context]

**Context:** [Who it was to, situation if known]

> [Full example text, blockquoted]

---
```

Create the file if it doesn't exist, with this frontmatter:

```markdown
---
type: behavioral
description: Writing examples used to teach personal style
last-updated: YYYY-MM-DD
---

# Writing Examples
```

---

## Step 4: Update Style Guide

If new patterns were discovered, update `state/behavioral/writing-style.md`:

- Add new phrases/patterns to the appropriate subsection
- Add new "never use" items if found
- Note context-specific rules (e.g., "formal with clients, casual with team")

If the file doesn't exist, create it with this structure:

```markdown
---
type: behavioral
description: User's personal writing style guide, learned from examples
last-updated: YYYY-MM-DD
---

# Writing Style

## Tone
[Extracted tone rules]

## Structure
[Paragraph, greeting, closing patterns]

## Vocabulary
### Signature Phrases
[Phrases the user uses repeatedly]

### Never Use
[Phrases the user avoids]

## Voice
[Active/passive, hedging, confidence patterns]

## Context-Specific Rules
[How style shifts by audience or medium]
```

---

## Step 5: Confirm

```
Got it. Saved [X] example(s) and learned:
- [New pattern 1]
- [New pattern 2]
- [Confirmed: existing pattern]
```

