---
name: content-build
description: Turn content ideas into publishable blog posts and social media content. Use this skill when the user wants to "build content", "write posts", "work on content", "turn ideas into posts", "content session", "let's write some posts", "/content-build", "work the content pipeline", "what's in the content backlog", or wants to review the ideas backlog and produce Substack articles and social media posts. This is the production engine of the Umbrella Content Engine — where ideas become actual content. Also trigger when the user says "let's do a content build session" or "time to make some posts".
---

# Content Build

Turn ideas from the backlogs into Substack blog posts and platform-specific social media posts, then schedule them for publishing.

## Context

This skill sits in the middle of the content pipeline:
- `/content-dump` and `/content-capture` feed ideas into the backlogs
- **This skill** turns ideas into finished content
- `/content-publish` posts the scheduled content to platforms via Buffer API

Two voices, always distinct:
- **Umbrella** — "How we help schools do X." Company capability, professional warmth.
- **Personal voice** — "What I've learned about X." First-person, opinionated, story-driven.

For channel IDs, platform constraints, and voice framing details, read `references/channels-and-platforms.md`.

## The Build Session

A content build session is collaborative. You draft, the user refines. The content authenticity rule: AI provides structure and polish, the user provides the substance — real stories, genuine opinions, lived experience. If a draft feels generic, ask the user for the specific detail that makes it real.

### Step 1: Review the Backlogs

Read both backlog files:
- `Areas/Content/umbrella/ideas.md`
- `Areas/Content/austin/ideas.md`

Present all ideas with status `new`:

```
Content backlog — [N] new ideas:

UMBRELLA:
1. [Title] — [first sentence of description]
2. [Title] — [first sentence of description]

AUSTIN:
3. [Title] — [first sentence of description]
4. [Title] — [first sentence of description]

BOTH (appears in both backlogs):
5. [Title] — [first sentence of description]

Which ones do you want to work on? Pick by number, or "all".
```

If the backlogs are empty, say so and suggest running `/content-dump` first.

### Step 2: Generate Substack Post

For each picked idea, generate a long-form blog post draft.

**Blog post specs:**
- 800-1500 words
- Conversational but substantive — reads like a smart person explaining something they know well
- Structure: hook → context → the meat → takeaway/action items
- Use subheadings to break up the content
- Include specific details, numbers, examples where possible — vague posts don't perform
- End with something actionable or thought-provoking, not a generic "hope this helps"

**Also generate alongside the blog post:**
- **Subtitle** — A one-line hook for Substack's subtitle field. The title says *what* the post is about; the subtitle says *why the reader should care*. It shows up in email subject previews, RSS feeds, and the Substack post listing. Example: Title = "Summer Project Planning Checklist for School IT", Subtitle = "The sequencing checklist we actually use every summer — and when to start."
- **Tags** — 3-5 short Substack tags for internal organization and reader filtering. Keep them discovery-oriented (what a reader would search for). Examples: "School IT", "K-12 Education", "EdTech", "IT Management", "E-Rate". These go in the blog post frontmatter.

**If the idea appears in both backlogs**, generate two versions:
- Umbrella version: "we" perspective, capability framing
- Personal voice version: "I" perspective, story/experience framing

**Present to the user for review:**

IMPORTANT: Never present draft text in the terminal. Always write the draft to a temp file (`/private/tmp/claude/content-draft-[slug].md`) and open it in VS Code (`open -a "Visual Studio Code" /path/to/file`). The user edits directly in VS Code. When they're done, they'll tell you — then read the file back to pick up their changes.

This is the most important review point. The user will likely want to:
- Add specific stories or examples the AI couldn't know
- Adjust tone or framing
- Cut sections that feel generic
- Expand sections that hit on something real

Incorporate feedback and re-present if needed. "Looks good" or "approved" means move on.

### Step 3: Derive Social Posts

For each approved blog post, generate MULTIPLE platform-specific social posts designed to fill a week. Read `references/channels-and-platforms.md` for platform constraints and voice framing.

**Publishing cadence:**
- Blog post publishes on Substack every **Monday morning**
- Social posts are derived from the blog and spread **evenly throughout the week** (Monday through Sunday) until the next blog post
- No fixed target number — generate however many distinct angles the blog supports (typically 4-7 per platform)
- Each post should extract a different angle, tip, insight, or story from the blog — never repeat the same point
- **No Twitter threads** — Buffer cannot post threads. Every Twitter post must be a standalone single tweet.

**Generate for each voice:**

For an Umbrella blog post → generate:
- Umbrella Twitter individual posts (multiple — one per distinct angle)
- Umbrella LinkedIn posts (multiple — one per distinct angle)
- Umbrella Facebook posts (multiple — one per distinct angle)

For a personal voice blog post → generate:
- Personal voice Twitter individual posts (multiple)
- Personal voice LinkedIn posts (multiple)

**Social post principles:**
- Each post stands alone as value — not just "check out my blog post"
- Extract a DIFFERENT angle from the blog for each post — slice the content, don't summarize it repeatedly
- Platform-native: a LinkedIn post reads differently than a tweet
- **NEVER say "link in comments", "link in bio", or reference anything not in the post itself.** The user won't add comments and Claude can't either.
- **Always include the actual Substack URL in the post body** when referencing a blog post. Use the real link (e.g. `https://umbrellasystems.substack.com/p/slug`). If you don't have the URL, ask the user for it before writing the post.
- No thread formatting (1/, 2/, etc.) — every post is a single standalone item

**LinkedIn specifically** (this matters for reach):
- Hook in the VERY first line — if it doesn't stop the scroll, nothing else matters
- One idea per short paragraph, lots of white space
- Have a defensible take, not a platitude
- End with a question that invites real replies
- 3-5 specific hashtags

**Present all social posts in a single file opened in VS Code**, grouped by platform, with suggested day labels (Day 1 = Monday, Day 2 = Tuesday, etc.).

### Step 4: Schedule and Save

Once the user approves:

**4a: Save blog posts to vault**

Write each blog post as a markdown file:
- Umbrella: `Areas/Content/umbrella/posts/YYYY-MM-DD-slug.md`
- Austin: `Areas/Content/austin/posts/YYYY-MM-DD-slug.md`

Frontmatter:
```yaml
---
type: content
voice: umbrella  # or personal
date: YYYY-MM-DD
title: "Post Title"
subtitle: "Hook-style subtitle for Substack"
tags: [Tag1, Tag2, Tag3]
status: drafted
idea-source: "Original idea title from backlog"
substack-url: ""  # filled in after manual Substack publish
---
```

**4b: Render HTML for Substack**

Generate a clean HTML file from the blog post for copy-pasting into Substack. Substack doesn't accept raw markdown — you need to paste rendered HTML from a browser.

Write the HTML to `/private/tmp/claude-501/substack-[slug].html` with this structure:
- Clean, readable typography: `-apple-system` font stack, `18px` body, `1.7` line-height
- `max-width: 680px`, centered with `40px` top margin
- Proper heading sizes (`h1: 32px`, `h2: 24px`)
- Good spacing on paragraphs (`16px` margin-bottom) and list items (`10px`)
- No title in the HTML body — Substack has its own title/subtitle fields
- Just the body content: paragraphs, subheadings, lists, bold text

Open it in Chrome: `open -a "Google Chrome" "file:///private/tmp/claude-501/substack-[slug].html"`

Tell the user: "HTML is open in Chrome. Cmd+A, Cmd+C, then paste into Substack's editor. Title: [title]. Subtitle: [subtitle]. Tags: [tag1, tag2, tag3]."

**4c: Save social posts archive**

Save the social posts alongside the blog post for reference:
- `Areas/Content/umbrella/posts/YYYY-MM-DD-slug-social.md` (or austin/)

**4d: Schedule social posts**

Default cadence (unless the user specifies otherwise):
- **Monday:** Substack blog post publishes. First social posts go out same day (blog announcement + thread).
- **Tuesday–Sunday:** Remaining social posts spread evenly across the week. Alternate platforms to avoid flooding one channel.
- Posts per day per platform: max 1. Spread them out.
- Suggested posting times: 9:00 AM for LinkedIn, 10:00 AM for Twitter, 11:00 AM for Facebook.

Append to the appropriate queue file (`Areas/Content/umbrella/queue.md` or `Areas/Content/austin/queue.md`):

```
| YYYY-MM-DD | 10:00 | twitter | UmbrellaSysMN | scheduled | [full post text] |
| YYYY-MM-DD | 12:00 | linkedin | umbrella-systems-mn | scheduled | [full post text] |
```

Use channel names from `references/channels-and-platforms.md`. The `/content-publish` skill will match these to Buffer channel IDs.

**4e: Update backlog status**

Edit the ideas in both backlog files to change status from `new` to `drafted`.

### Step 5: Summary

```
Content build complete:

Blog posts:
- "[Title]" — Umbrella version saved to posts/YYYY-MM-DD-slug.md
- "[Title]" — Personal voice version saved to posts/YYYY-MM-DD-slug.md

Social posts scheduled:
- [N] Umbrella posts (Twitter, LinkedIn, Facebook) — [date range]
- [N] personal voice posts (Twitter, LinkedIn) — [date range]

Next: Publish the Substack posts manually, then `/content-publish` will handle the social posts on schedule.

[N] ideas remaining in backlog.
```

## Edge Cases

- **Idea only in one backlog** — generate content for that voice only, social posts for that voice's channels only
- **The user wants to skip the blog post** — go straight to social posts. Some ideas work better as standalone social content without a full article.
- **The user wants to batch multiple ideas** — work through them one at a time within the same session. Present each for review before moving to the next.
- **The user provides the blog post themselves** — skip generation, go straight to deriving social posts from their draft
- **The user wants to edit inline** — they might paste revised text directly. Use it as-is.
- **Scheduling conflict** — if queue already has posts for a suggested date, shift the new ones to avoid stacking

## What This Skill Does NOT Do

- **Does not publish to Substack** — Substack has no public API. The user publishes manually by copy-pasting the rendered HTML into Substack's web editor. This skill generates the HTML, subtitle, and tags — the user handles the actual publish.
- **Does not publish to Buffer** — that's `/content-publish`'s job. This skill only adds to the queue.
- **Does not generate ideas from scratch** — ideas come from the backlogs (fed by `/content-dump` and `/content-capture`). If the backlog is empty, suggest running `/content-dump`.
