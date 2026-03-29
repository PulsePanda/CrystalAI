---
name: crystal:teach
description: This skill should be used when the user asks to "/teach", "teach you my style", "here's an example of my writing", "learn from this email", or pastes writing examples for Claude to analyze. Analyzes writing samples to extract patterns, updates the style guide, and saves examples for future reference.
version: 1.0.0
allowed-tools: Read, Write, Edit
---

# /teach - Teach Writing Style from Examples

Analyzes writing samples the user provides, extracts new patterns, and updates the permanent style reference.

---

## Step 1: Receive Examples

Accept one or more writing examples — emails, Slack messages, texts, anything. If context would help ("who was this to, what was the situation?"), ask briefly.

---

## Step 2: Analyze Patterns

Compare against the `# Writing Style` section in the vault root CLAUDE.md and look for:

- **New patterns:** phrases, openers/closers, structural habits not yet documented
- **Existing patterns confirmed:** note if examples reinforce what's already there
- **Anti-patterns:** things the user clearly avoids that aren't documented yet
- **Context-specific rules:** formal vs casual, internal vs external differences

If an example contradicts existing style rules, flag it and ask which is correct.

---

## Step 3: Save Examples

Append to `${CLAUDE_PLUGIN_ROOT}/state/behavioral/writing-examples.md`:

```markdown
## YYYY-MM-DD - [Brief context]

**Context:** [Who it was to, situation if known]

> [Full example text, blockquoted]

---
```

---

## Step 4: Update Style Guide

If new patterns were discovered, update the `# Writing Style` section in the vault root CLAUDE.md (`${VAULT_PATH}/CLAUDE.md`):
- Add new phrases/patterns to the appropriate subsection
- Add new "never use" items if found
- Note context-specific rules

---

## Step 5: Confirm

```
Got it. Saved [X] example(s) and learned:
- [New pattern 1]
- [New pattern 2]
- [Confirmed: existing pattern]
```

One response, no filler.
