# Project Template Format

Reference guide for the structure and sections of project files.

## File Location

All project files live in:
```
${VAULT_PATH}/Projects/
```

## Two Formats

### Single-file
```
Projects/project-name.md
```
A standalone tracking doc for simple initiatives — skill builds, one-off tasks, planning documents.

### Folder
```
Projects/project-name/
├── _project.md        ← tracker (same structure as single-file)
├── reference/         Research, specs, background docs
├── deliverables/      Outputs, proposals, reports
└── notes/             Meeting notes, call notes, working notes
```
For projects that accumulate material over time — sales prospects, client engagements, multi-phase initiatives.

## Filename Convention

- Lowercase project name
- Spaces replaced with hyphens
- No special characters
- `.md` extension (single-file) or directory name (folder)

Examples:
- "Website Redesign" → `website-redesign`
- "Twin Cities German Immersion" → `twin-cities-german-immersion`
- "API v2.0 Migration" → `api-v20-migration`

## Core Sections (always present)

```markdown
---
type: project
date-created: YYYY-MM-DD
status: planning | active | on-hold | complete
tags: [tag1, tag2]
---

# Project Name

**Started:** YYYY-MM-DD

## Overview
Brief description — what, why, expected outcome.

## Goals
- Goal 1
- Goal 2

## Current State

### Done
### In Progress
### Next

## Key Decisions

## Notes

---

**Last Updated:** YYYY-MM-DD
```

### Important: Status lives in frontmatter only

The `status:` field in YAML frontmatter is the single source of truth. Do NOT add a `**Status:**` line in the body — it creates drift between two locations.

### Folder format adds: Project Files section

```markdown
## Project Files

This project uses folder format:
- `reference/` — Research, specs, background docs
- `deliverables/` — Outputs, proposals, reports
- `notes/` — Meeting notes, call notes, working notes

Use `/project-load {filename}` to load project context.
```

## Optional Sections (add when relevant)

### Waiting On
When there are known blockers or dependencies on other people:
```markdown
## Waiting On

| Person | For What | Since | Follow-up By | Things3 Task |
|--------|----------|-------|--------------|--------------|
| Name | What we're waiting for | YYYY-MM-DD | YYYY-MM-DD | yes/no |
```

### Technical Approach
For engineering/technical projects:
```markdown
## Technical Approach

### Architecture
- Key technical decisions

### Implementation Notes
- Important details and gotchas
```

### Timeline
When there are known deadlines:
```markdown
## Timeline

**Estimated:** X weeks/months
**Key milestones:**
- Milestone 1: Date
```

### Team & Stakeholders
For collaborative projects:
```markdown
## Team & Stakeholders

**Team:**
- Role: Person name

**Stakeholders:**
- Stakeholder 1
```

### Resources
When there are external links:
```markdown
## Resources

- [Link](url)
- Documentation: [[Internal doc]]
```

### Dataview Queries
Only when explicitly requested. Note: session logs live in CrystalAI `state/sessions/`, not in the vault.

## Update Frequency

- **As work happens:** Current State, Key Decisions
- **Weekly:** Status check, Waiting On follow-ups
- **On completion:** Status → complete, add Completed date

## Real-World Examples

Lean prospect project (TCGIS):
```markdown
---
type: project
date-created: 2026-03-27
status: active
tags: [work, umbrella, sales, prospect]
---

# Twin Cities German Immersion School

**Started:** 2026-03-27

## Overview
Sales prospect research and relationship management for TCGIS.

## Goals
- Maintain comprehensive prospect dossier for meeting prep
- Track relationship touchpoints and contract status

## Current State

### Done
- Initial prospect dossier generated (2026-03-27)

### In Progress
### Next

## Key Decisions

## Notes

## Project Files
This project uses folder format:
- `reference/` — Prospect dossier, research artifacts
- `deliverables/` — Quotes, proposals, bid documents
- `notes/` — Meeting notes, call logs

Use `/project-load twin-cities-german-immersion` to load project context.

---

**Last Updated:** 2026-03-27
```
