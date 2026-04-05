# People Integration

People are first-class objects in the vault at `Areas/People/`. Each person gets a markdown file that accumulates context over time from multiple sources.

## How people files get created and updated

| Source | Creates new? | Updates existing? | What it adds |
|--------|-------------|-------------------|-------------|
| /meeting | Yes (stubs) | Yes | Meeting history, last-contact |
| /compress | No | Yes | Last-contact, decisions, context from session |
| /process-inbox | Yes (if enough context) | Yes | Any person-relevant context from captures |
| /process-email | No | Yes | Last-contact, email context |
| people-profiler agent | Yes (stubs) | Yes | Bulk scan of recent sessions/meetings |
| Manual | Yes | Yes | User creates/edits directly in Obsidian |

## Schema

Person files use the template at `vault/_Templates/person.md`.

### Frontmatter

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `type` | string | Yes | Always `person` |
| `date-created` | date | Yes | When the file was created (YYYY-MM-DD) |
| `last-contact` | date | No | Date of most recent interaction |
| `tags` | array | Yes | Always includes `person` |
| `aliases` | array | No | Alternate names, nicknames, abbreviations |

### Body Sections

| Section | Purpose | Updated by |
|---------|---------|------------|
| **Identity** | Contact info table — name, role, org, email, phone, location, LinkedIn | Manual, /process-inbox, people-profiler |
| **Context** | Free-text: how you know them, why they matter | Manual, /process-inbox |
| **Working Style & Preferences** | Communication style, decision patterns, things to remember | Manual, /process-inbox |
| **Key Decisions** | Timestamped decisions with source links | /meeting, /compress, manual |
| **Meeting History** | Timestamped meeting entries with wikilinks | /meeting |
| **Project Involvement** | Links to projects and their role | Manual, /project-load |
| **Notes** | Catch-all for anything that doesn't fit above | Any source |

### Field usage by relationship type

- **Work colleagues:** Identity (full), Context, Working Style, Meeting History, Key Decisions
- **Clients/vendors:** Identity (full), Context, Key Decisions, Project Involvement
- **Personal contacts:** Identity (partial), Context, Notes
- **One-off contacts:** Should not get files unless they become recurring

## Rules

1. Never create a person file with only a name — require at least one additional field
2. Stub files are expected — they get enriched over time
3. Always check for duplicates before creating (glob for name and aliases)
4. One-off contacts don't get files unless they become recurring
5. Family members get files only if they intersect with tracked work/projects

## UserPromptSubmit classifier integration

The classifier (in Branch 1) detects person-context signals and injects routing hints. Keywords: "told me", "said that", "feedback from", "met with", "talked to", "spoke with", "mentioned that". When detected, Claude receives a hint to check Areas/People/ for the relevant person.

## Deferred: /compress integration

/compress will be updated to check session mentions against Areas/People/ — but that change depends on Branch 1 (lifecycle hooks) merging first. After Branch 1 merges, add to compress: scan session for person names, update last-contact for mentioned people, add significant new context to person files.

## Deferred: /process-email integration

/process-email integration is documented here but should be implemented when the email processing skill is next modified. The integration: when processing emails, check sender/recipients against Areas/People/, update last-contact, add email context if significant.
