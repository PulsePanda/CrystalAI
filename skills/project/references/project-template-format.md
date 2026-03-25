# Project Template Format

Reference guide for the structure and sections of project files.

## File Location

All project files live in:
```
/Users/Austin/Library/Mobile Documents/iCloud~md~obsidian/Documents/VaultyBoi/Projects/
```

## Filename Convention

- Lowercase project name
- Spaces replaced with hyphens
- No special characters
- .md extension

Examples:
- "Website Redesign" → `website-redesign.md`
- "Q1 Planning" → `q1-planning.md`
- "API v2.0 Migration" → `api-v20-migration.md`

## Template Structure

### Header (YAML frontmatter optional)

```markdown
# Project Name

**Status:** Planning | Active | Paused | Complete
**Started:** YYYY-MM-DD
**Completed:** (if applicable)
```

### Overview Section

Brief description of project purpose, goals, and expected outcomes.

Typically 2-4 sentences explaining:
- What is this project?
- Why are we doing it?
- What's the expected outcome?

### Goals Section

Bulleted list of primary objectives:
```markdown
## Goals

- Primary goal 1
- Primary goal 2
- Primary goal 3
```

Keep to 3-5 main goals, not an exhaustive task list.

### Current State Section

Three subsections tracking progress:

```markdown
## Current State

**Done:**
- Completed milestone 1
- Completed milestone 2

**In Progress:**
- Current work item 1
- Current work item 2

**Next:**
- Planned work item 1
- Planned work item 2
```

Update regularly as project progresses.

### Key Decisions Section

Document important choices made during the project:

```markdown
## Key Decisions

### YYYY-MM-DD: Decision Title
- **Decision:** What was decided
- **Rationale:** Why this approach
- **Alternatives considered:** Other options
- **Impact:** What this affects
```

Chronological order (newest first or oldest first, be consistent).

### Things3 Tasks Section

Links to task management:

```markdown
## Things3 Tasks

To view tasks related to this project:
- Search Things3 for: "Project Name"
- Or use MCP: "Show me tasks for [project]"
- Link to Things3 project/area if applicable

**Active tasks:**
- (Query Things3 for current status)
```

Tasks live in Things3, not duplicated here.

### Technical Approach Section

For technical projects, document architecture and implementation:

```markdown
## Technical Approach

### Architecture
- Key technical decisions
- Tools and technologies
- Design patterns

### Implementation Notes
- Important technical details
- Gotchas or considerations
- Performance implications
```

Optional for non-technical projects.

### Timeline Section

```markdown
## Timeline

**Estimated:** X weeks/months
**Key milestones:**
- Milestone 1: Date
- Milestone 2: Date
- Launch: Target date
```

Update estimates as project progresses.

### Related Notes Section

Wikilinks to relevant notes:

```markdown
## Related Notes

- [[Note 1]]
- [[Note 2]]
- [[Reference Document]]
```

### Related Sessions Section

Links to session logs from /compress:

```markdown
## Related Sessions

- [[YYYY-MM-DD-HHmm-session-topic]]
- [[YYYY-MM-DD-HHmm-session-topic]]
```

Automatically updated by /compress when sessions reference this project.

### Team & Stakeholders Section

```markdown
## Team & Stakeholders

**Team:**
- Role: Person name

**Stakeholders:**
- Stakeholder 1
- Stakeholder 2
```

### Resources Section

External links and internal documentation:

```markdown
## Resources

- [External link 1](url)
- [External link 2](url)
- Documentation: [[Internal doc]]
```

### Notes Section

Free-form additional context:

```markdown
## Notes

Additional context, learnings, or observations about the project.
```

### Footer

```markdown
---

**Last Updated:** YYYY-MM-DD
```

## Required vs Optional Sections

**Required:**
- Header (name, status, started date)
- Overview
- Goals
- Current State

**Recommended:**
- Key Decisions
- Things3 Tasks
- Timeline
- Last Updated footer

**Optional:**
- Technical Approach (for technical projects)
- Team & Stakeholders (for collaborative projects)
- Resources (if external links needed)
- Related Notes/Sessions (filled over time)
- Notes (as needed)

## Update Frequency

- **Weekly:** Current State section
- **As they occur:** Key Decisions, Related Sessions
- **Monthly:** Timeline estimates, Goals review
- **On completion:** Status, Completed date

## Integration with CLAUDE.md

When project is created, add summary entry to CLAUDE.md:

```markdown
# Active Projects

## Project Name
- **Status**: Active
- **Started**: YYYY-MM-DD
- **Goal**: Brief one-line description
- **Details**: [[project-filename]]
```

When project completes, entry can be archived (if CLAUDE.md > 280 lines).

## Example Full Template

See: `Projects/_template.md` for the complete template file.

## Example Populated Project

See: `Projects/obsidian-smart-assistant.md` for a real-world example.
