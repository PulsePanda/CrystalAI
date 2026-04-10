# Memory File Format

## Session Log

**Location:** `${STATE_PATH}/sessions/YYYY-MM-DD-HHmm-topic.md`

Key sections to read during resume:
- **Quick Reference** — topics, projects, outcome (always read this)
- **Decisions Made / Key Learnings** — read when relevant to current work
- **Raw Session Log** — full conversation, only read when you need detail

## Project Files

**Location:** `~/Documents/Projects/project-name.md` or `~/Documents/Projects/project-name/_project.md`

Frontmatter `status` field is the source of truth:
- `active` — show in resume summary
- `complete` — omit from resume summary
- `on-hold` / `planned` — show if relevant, omit from default resume

Read with `limit: 5` during resume to get frontmatter without loading full content.
