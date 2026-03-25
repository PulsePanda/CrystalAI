# CrystalAI Architecture

CrystalAI is a Claude Code plugin — "the secretary." VaultyBoi is an Obsidian vault — "the notebook." They are separate: the vault holds human content readable without any AI agent; the plugin holds all agent infrastructure, state, and skills.

## Why Separate?
- Independence: vault works as a plain Obsidian vault; plugin works as a standalone Claude Code plugin
- Versioning: plugin is a git repo with tracked schemas and templates
- Distribution: plugin can be cloned, configured, and used by anyone
- Clean boundaries: no confusion about where things belong

## Sync Model
- **Vault** — Syncthing (MacBook <-> Heart)
- **Plugin** — Syncthing (MacBook <-> Heart) + Git for versioning/distribution
- **Canopy** — UmbrellaAI via git only

## Relationship to UmbrellaAI
| Plugin | Scope | Content |
|--------|-------|---------|
| CrystalAI | Personal — everything Austin-specific | Skills, behavioral rules, memory, state, writing style, integrations |
| UmbrellaAI | Business — Umbrella Systems operations | Business skills, SOPs, assets, Canopy scripts, business context |

Both plugins load at user scope. Cloned skills are intentionally duplicated — each tailors to its context.

---

## Decision Tree: Where Does This Go?

```
Is this human-authored content that exists without an AI agent?
  YES → Vault (VaultyBoi)
    Is it a project tracking doc? → Projects/
    Is it a daily note? → Daily Notes/
    Is it a quick capture? → +Inbox/
    Is it creative/content work? → Areas/Content/
    Is it reference for a life area? → Areas/[area]/
  NO → Plugin (CrystalAI)
    Is it about an external service the agent connects to? → state/integrations/[name]/
    Is it about a server/machine the agent runs on? → state/environments/[name].md
    Is it about an org, school, or person? → state/entities/[name].md
    Is it a behavioral rule or standing order? → state/behavioral/[domain].md
    Is it a copy-paste execution reference? → state/patterns/[name].md
    Is it a correction/feedback from Austin? → state/feedback/ (queue for /weekly)
    Is it a session log? → state/sessions/
    Is it live operational state (logs, queues, manifests)? → state/operational/
    Is it general reference that doesn't fit above? → state/memory/
```

---

## Growth Protocols

### The agent CAN do autonomously:
- Create a new file in an existing state category (following the schema in `state/_schemas/`)
- Create a new integration dir in `state/integrations/` when a new service is connected
- Create a new entity file when a new org/school/person becomes relevant
- Add rules to an existing behavioral domain file
- Create a new feedback file when Austin gives a correction
- Absorb feedback into behavioral files during `/weekly`

### The agent MUST ask Austin before:
- Creating a new state category (new directory under `state/`)
- Creating a new behavioral domain (new file in `state/behavioral/`)
- Restructuring existing directories
- Changing schemas
- Moving files between categories
- Modifying this file (ARCHITECTURE.md)

---

## Anti-Patterns
- Never create agent files in the vault (skills, state, memory, scripts)
- Never hardcode personal config in git-tracked skill files (use `crystal.local.yaml` + `${VARIABLES}`)
- Never let MEMORY.md grow past ~50 lines (it's an index, not storage)
- Never create flat files in state/ root — everything goes in a category
- Never duplicate information between CLAUDE.md files (global, vault, plugin each own their scope)
- Never store secrets/credentials in any file except designated secure locations

---

## File Lifecycle
- **Feedback:** created in `state/feedback/` → absorbed into `state/behavioral/` during `/weekly` → archived in `state/feedback/archive/`
- **Session logs:** created by `/compress` in `state/sessions/` → referenced by `/resume` → eventually aged out
- **Heart log:** appended continuously → rotated to keep only 3 days
- **Auto-memory:** new files land in `~/.claude/projects/.../memory/` → swept to `state/` during `/weekly`
- **Projects:** created in vault `Projects/` → moved to `Projects/Archive/` when complete

---

## Config & Variables
- `crystal.local.yaml` — personal config (paths, emails, IDs, server IPs). Gitignored.
- `crystal.secrets.yaml` — credential paths and sensitive identifiers. Gitignored.
- Both have `.template` versions for distribution (git-tracked).
- Skills reference `${CRYSTAL_ROOT}` (plugin path) and `${VAULT_PATH}` (vault path from config).
- Agent reads config at skill start when environment-specific values are needed.
- Reads `crystal.secrets.yaml` only when credential paths are needed for API calls.

---

## State Hierarchy

```
state/
├── _schemas/           # Git-tracked schema templates
├── environments/       # One file per execution environment
├── integrations/       # One dir per external service
├── entities/           # Orgs, schools, people
├── behavioral/         # Rules grouped by domain
├── patterns/           # Copy-paste execution references
├── memory/             # General reference memory
├── operational/        # Live operational state
├── sessions/           # Session logs
├── feedback/           # Processing queue (not permanent storage)
│   └── archive/        # Processed feedback files
└── glossary.md         # Quick-lookup decoder ring
```

Each category has a schema in `_schemas/`. When creating a new entry, the agent reads the schema and follows it.
