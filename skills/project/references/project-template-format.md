# Project Template Format

Reference guide for the structure and sections of project files.

## File Location

All project files live in:
```
~/Documents/Projects/
```

## Format

Every project uses folder format. No single-file projects.

```
Projects/project-name/
├── _project.md        ← tracker
├── reference/         Research, specs, background docs
├── deliverables/      Outputs, proposals, reports
└── notes/             Meeting notes, call notes, working notes
```

## Filename Convention

- Lowercase project name
- Spaces replaced with hyphens
- No special characters
- Directory name matches the project name

Examples:
- "Website Redesign" → `website-redesign`
- "API v2.0 Migration" → `api-v20-migration`
- "Client Onboarding" → `client-onboarding`

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

## Optional Sections (add when relevant)

### Waiting On
```markdown
## Waiting On

| Person | For What | Since | Follow-up By | Task Created |
|--------|----------|-------|--------------|--------------|
| Name | What we're waiting for | YYYY-MM-DD | YYYY-MM-DD | yes/no |
```

### Technical Approach
For engineering/technical projects.

### Timeline
When there are known deadlines.

### Team & Stakeholders
For collaborative projects with multiple people.

### Resources
When there are external links or references.

## Update Frequency

- **As work happens:** Current State, Key Decisions
- **Weekly:** Status check, Waiting On follow-ups
- **On completion:** Status → complete, add Completed date
