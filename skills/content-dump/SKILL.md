---
name: crystal:content-dump
description: Interactive brain-dump for content ideas. Use this skill whenever Austin wants to capture content ideas, says things like "I have a content idea", "here's something I could write about", "brain dump", "content dump", "/content-dump", mentions wanting to jot down a post idea, talks about something that would make good content, or describes a situation/story/lesson that could become a blog post or social media content. Also trigger when Austin says "that could be a post" or "we should write about this" during other work. This is the active input funnel for the Umbrella Content Engine.
---

# Content Dump

Capture Austin's content ideas through conversation and file them into the right backlogs.

## Context

This skill is part of the Umbrella Content Engine pipeline. Austin runs two content voices:

- **Umbrella voice** — company perspective. "How we help schools do X." Professional, capability-focused. Goes to `Areas/Content/umbrella/ideas.md`.
- **Austin voice** — personal expert perspective. "What I've learned about X from running IT at charter schools." First-person, opinionated, story-driven. Goes to `Areas/Content/austin/ideas.md`.

Some ideas fit both voices with different framing — that's fine, file them in both backlogs.

**Content pillars** (use these as mental categories, not rigid boxes):
- School IT best practices / tips
- E-Rate guidance and funding optimization
- Cybersecurity for schools (FERPA, COPPA, etc.)
- Device management at scale
- Seasonal content (back-to-school prep, break projects, testing season)
- Case studies / war stories (anonymized)
- Building in public (Austin voice only — AI automation, Claude Code, content engine, MSP operations)

## How This Works

The dump is a conversation, not a form. Austin talks, you listen and extract.

### Step 1: Open the conversation

If Austin didn't already provide ideas in their message, prompt them casually:

> What's on your mind? Could be one idea, ten ideas, a rant, a story — whatever you've got.

If they already dropped ideas in their message, skip straight to processing.

### Step 2: Process what Austin says

For each distinct idea in the dump:

1. **Extract a title** — short, descriptive, would make sense scanning a table later. 5-10 words.
2. **Write a description** — 2-3 sentences capturing the core idea, angle, or story. Preserve Austin's original framing and language where possible. The description should contain enough context that `/content-build` can turn it into a full post later without needing to ask Austin again.
3. **Classify the voice** — umbrella, austin, or both. Use these signals:
   - Building in public, AI/automation, personal opinions, "I" stories → austin
   - Company capabilities, service offerings, "we help schools" → umbrella
   - General school IT knowledge, tips, how-tos → could be both (different framing)
   - If unsure, default to both — `/content-build` can sort it out later

Don't interrupt Austin to classify each idea one-by-one. Let them finish dumping, then present everything at once.

### Step 3: Present for confirmation

Show Austin what you captured in a clean summary:

```
Here's what I got:

1. **[Title]** (austin)
   [Description]

2. **[Title]** (umbrella + austin)
   [Description]

3. **[Title]** (umbrella)
   [Description]
```

Ask if anything needs adjusting — wrong voice, missing context, ideas to merge or split. Austin might also add more ideas at this point. Quick confirmation is fine: "yup" or "all good" means proceed.

### Step 4: File the ideas

For each confirmed idea, append a row to the appropriate backlog file(s):

**File:** `Areas/Content/umbrella/ideas.md` and/or `Areas/Content/austin/ideas.md`

**Format:** Append to the table under `## Backlog`:
```
| YYYY-MM-DD | Idea title | brain-dump | new | 2-3 sentence description |
```

- Date = today's date
- Source = `brain-dump` (distinguishes from passive captures by `/content-capture`)
- Status = `new`

Use the Edit tool to append rows. Read the file first to find the end of the table.

### Step 5: Summarize

Brief recap of what went where:

> Filed 3 ideas — 1 to Umbrella backlog, 2 to Austin's, 1 appears in both. [X] total ideas in the pipeline now.

Count the total rows in both backlogs (excluding the header) to give the pipeline total.

## Handling Different Dump Styles

Austin might dump ideas in different ways:

- **Single idea with detail** — extract one well-formed idea with a rich description
- **Rapid-fire list** — multiple terse ideas. Extract each as its own row, write descriptions that expand on the terse input
- **Story/rant** — a long narrative about something that happened. Extract the core content angle (what's the lesson? what's the takeaway?) as the idea. The story itself is context for `/content-build`.
- **"That thing we just did"** — Austin references work from the current session. Use your conversation context to fill in the description with specifics.
- **Mixed** — some combination of the above. Handle each piece appropriately.

## Important

- **Don't over-polish.** The ideas backlog is a capture tool, not a publication. Preserve Austin's voice and raw energy. Clean enough to be useful later, rough enough to be fast now.
- **Don't filter.** If Austin says it, capture it. Curation happens during `/content-build`. The dump is for volume.
- **Don't generate ideas.** This skill captures Austin's ideas, not AI-generated ones. You can help him articulate what he's thinking, but the substance comes from him. If he trails off or is vague, ask a clarifying question rather than filling in the blank yourself.
