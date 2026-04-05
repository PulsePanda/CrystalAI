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

## /compress integration

Implemented in Step 5c of /compress. Scans the session log for named people, updates `last-contact` on existing person files, and optionally appends a brief dated note to Context if the session had significant person-related content. Creates stubs only when name + role/org/meaningful interaction is present. Skips name-only mentions.

## Process-Email Integration

/process-email is a personal skill (not in the core CrystalAI manifest) and cannot be modified here. This section documents how it should integrate with people files when the skill is next updated.

When processing an email or thread:

1. **Identify sender and recipients** from email metadata. For each named person:
   - Glob `${VAULT_PATH}/Areas/People/*.md` for a matching file (by name or `aliases` in frontmatter, case-insensitive).
   - **If file exists:** update `last-contact` in frontmatter to the email date.
   - **If file exists and the email contains significant person-relevant content** (decisions made, action items assigned to or from them, notable context about the relationship): add a brief timestamped note to the **Context** or **Notes** section of their person file.
   - **If no file exists** and this person is a frequent correspondent with enough context (at least name + email address or organization): suggest creating a stub. Do not auto-create without user confirmation.
   - **If no file exists** and there is minimal context (name only, one-off contact): skip — do not create a person file.

2. **Significant content threshold:** An email qualifies for a Context/Notes update if it contains a decision, a commitment, a preference, or meaningful background about the person — not routine scheduling or acknowledgments.

3. **Wikilinks:** Where the processed email output references people by name, add `[[Person Name]]` wikilinks.

This behavior is implemented in the user's personal `/process-email` skill, not in core. The source-of-truth table above already reflects the intended behavior (`/process-email` → updates existing, does not create new).
