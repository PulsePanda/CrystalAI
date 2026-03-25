# Memory File Format

## Session Log

**Location:** `_System/Memory/Sessions/YYYY-MM-DD-HHmm-topic.md`

Key sections to read during resume:
- **Quick Reference** — topics, projects, outcome (always read this)
- **Decisions Made / Key Learnings** — read when relevant to current work
- **Raw Session Log** — full conversation, only read when you need detail

## Project Files

**Location:** `_System/Projects/project-name.md`

Frontmatter `status` field is the source of truth:
- `active` — show in resume summary
- `complete` — omit from resume summary
- `on-hold` / `idea` — show if relevant

Read with `limit: 5` during resume to get frontmatter without loading full content.
