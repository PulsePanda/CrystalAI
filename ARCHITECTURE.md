# CrystalAI Architecture

CrystalAI is a Claude Code framework that provides structured state management, skills, agents, and continuity across sessions. It lives at `~/.claude/` and acts as the agent's persistent memory and behavioral layer.

If you also use an Obsidian vault (or any note-taking system), keep the boundaries clean: the vault holds human content readable without any AI agent; CrystalAI holds all agent infrastructure, state, and skills. They are separate systems that complement each other.

## Why This Structure?

- **Independence**: Your notes work without the agent; the agent works without your notes
- **Versioning**: CrystalAI is a git repo with tracked schemas and templates
- **Distribution**: Can be cloned, configured, and used by anyone
- **Clean boundaries**: No confusion about where things belong

---

## Decision Tree: Where Does This Go?

```
Is this human-authored content that exists without an AI agent?
  YES -> Your notes / vault / docs (outside CrystalAI)
    Is it a project tracking doc? -> Your project tracker
    Is it a daily note? -> Your daily notes
    Is it a quick capture? -> Your inbox
    Is it reference for a life/work area? -> Your area folders
  NO -> CrystalAI (~/.claude/)
    Is it about an external service the agent connects to? -> state/integrations/[name]/
    Is it about a server/machine the agent runs on? -> state/environments/[name].md
    Is it about an org, company, or person? -> state/entities/[name].md
    Is it a behavioral rule or standing order? -> state/behavioral/[domain].md
    Is it a copy-paste execution reference? -> state/patterns/[name].md
    Is it a correction/feedback from the user? -> state/feedback/ (queue for /weekly)
    Is it a session log? -> state/sessions/
    Is it live operational state (logs, queues, manifests)? -> state/operational/
    Is it general reference that doesn't fit above? -> state/memory/
```

> **Note:** CrystalAI includes a built-in `vault/` folder (`~/.claude/vault/`) for users who don't have an existing notes app. This is a supported location for daily notes, projects, and area content. The decision tree above describes the conceptual boundary — not a hard filesystem rule.

---

## State Hierarchy

```
state/
├── _schemas/           # Git-tracked schema templates for each category
├── environments/       # One file per execution environment (laptop, server, etc.)
├── integrations/       # One dir per external service (calendar, task manager, etc.)
├── entities/           # Orgs, companies, people the agent needs to know about
├── behavioral/         # Rules grouped by domain (communication, tasks, tools, etc.)
├── patterns/           # Copy-paste execution references (scripts, workflows, etc.)
├── memory/             # General reference memory (lessons learned, schedules, etc.)
├── operational/        # Live operational state (logs, queues, error tracking)
├── sessions/           # Session logs from /compress
├── feedback/           # Processing queue for user corrections
│   └── archive/        # Processed feedback files
└── glossary.md         # Quick-lookup decoder ring for project-specific terms
```

Each category has a schema in `_schemas/`. When creating a new entry, the agent reads the schema and follows it.

---

## Growth Protocols

### The agent CAN do autonomously:
- Create a new file in an existing state category (following the schema in `state/_schemas/`)
- Create a new integration dir in `state/integrations/` when a new service is connected
- Create a new entity file when a new org/company/person becomes relevant
- Add rules to an existing behavioral domain file
- Create a new feedback file when the user gives a correction
- Absorb feedback into behavioral files during `/weekly`

### The agent MUST ask the user before:
- Creating a new state category (new directory under `state/`)
- Creating a new behavioral domain (new file in `state/behavioral/`)
- Restructuring existing directories
- Changing schemas
- Moving files between categories
- Modifying this file (ARCHITECTURE.md)

---

## Anti-Patterns

- **Never create agent files in your notes/vault** (skills, state, memory, scripts belong in `~/.claude/`)
- **Never hardcode personal config in git-tracked skill files** (use `crystal.local.yaml` + `${VARIABLES}`)
- **Never let MEMORY.md grow past ~50 lines** (it is an index, not storage)
- **Never create flat files in `state/` root** — everything goes in a category
- **Never duplicate information between CLAUDE.md files** (global, project, and plugin each own their scope)
- **Never store secrets/credentials in any file** except designated secure locations

---

## File Lifecycle

- **Feedback:** created in `state/feedback/` -> absorbed into `state/behavioral/` during `/weekly` -> archived in `state/feedback/archive/`
- **Session logs:** created by `/compress` in `state/sessions/` -> referenced by `/resume` -> eventually aged out
- **Auto-memory:** new files land in `~/.claude/projects/.../memory/` -> swept to `state/` during `/weekly`
- **Operational logs:** appended continuously -> rotated to keep only recent entries (e.g., 3 days)

---

## Config & Variables

- `crystal.local.yaml` — personal config (paths, emails, IDs, server IPs). Gitignored.
- `crystal.secrets.yaml` — credential paths and sensitive identifiers. Gitignored.
- Both have `.template` versions for distribution (git-tracked).
- Skills reference `~/.claude` (plugin path, provided by Claude Code at runtime) and `${VAULT_PATH}` or other variables from config.
- Agent reads config at skill start when environment-specific values are needed.
- Reads `crystal.secrets.yaml` only when credential paths are needed for API calls.

---

## Plugin System

CrystalAI supports layering domain-specific plugins on top of the base framework. A plugin is a separate git repo with its own skills, state, and CLAUDE.md, namespaced to avoid collisions with the base layer.

### Plugin structure:
```
my-plugin/
├── CLAUDE.md           # Plugin-specific agent instructions
├── skills/             # Skills namespaced like `plug:*`
├── state/              # Plugin-specific state (optional)
└── README.md
```

### How plugins work:
- Listed in the base `~/.claude/CLAUDE.md` under `# Plugins`
- Claude Code loads plugin CLAUDE.md files based on scope (user-level or project-level)
- Skills are namespaced (e.g., `biz:invoice`, `ops:deploy`) to avoid colliding with base skills
- Plugins can reference base state (read) but should not write to base state categories

### When to create a plugin vs. adding to base:
- **Base**: Personal productivity, general-purpose skills, universal behavioral rules
- **Plugin**: Domain-specific workflows (business ops, specific project tooling, team conventions)

---

## Vault

`vault/` is CrystalAI's built-in memory layer for long-term, human-readable content. It ships with the repo and lives at `~/.claude/vault/` after install. It is a first-class component alongside `skills/`, `state/`, and `agents/`.

Structure:
- `vault/+Inbox/` — quick captures
- `vault/Daily Notes/` — one file per day, auto-created by `/resume` and `/compress`
- `vault/Areas/` — life and work area notes
- `vault/_Templates/` — note templates (`daily-note.md` is used automatically)

Projects no longer live inside the vault. They are tracked at `~/Documents/Projects/`, seeded from the `_template/` in that directory. See the `project` and `project-load` skills for the current folder layout (`_project.md` tracker, `CLAUDE.md` for session context, and a `_meta/` directory holding `reference/`, `deliverables/`, and `notes/`). This lets a project directory double as a working code repo with its own git history while keeping project-management files gitignored.

Users who prefer a different notes app (Obsidian, Notion, etc.) can point `vault_path` in `crystal.local.yaml` to their existing folder. The built-in vault is always available as the default.

---

## Skills

Skills are structured, repeatable capabilities the agent can invoke. They live in `~/.claude/skills/` and are created via the `/skill-creator` skill (never manually).

Each skill directory contains:
- `SKILL.md` — the skill definition (trigger, steps, outputs)
- `reference/` — supporting docs, API shapes, gotchas
- Any scripts or templates the skill needs

Skills are invoked with `/skill-name` syntax in conversation.

---

## Agents

Agents are specialized subagents that handle specific domains. They live in `~/.claude/agents/` and are spawned via the Agent tool when a task matches their specialty.

The agent catalog should be checked before performing any task inline. If a matching agent exists, delegate to it.

---

## Getting Started

1. Clone this repo to `~/.claude/`
2. Copy `crystal.local.yaml.template` to `crystal.local.yaml` and fill in your values
3. Copy `crystal.secrets.yaml.template` to `crystal.secrets.yaml` and fill in credential paths
4. Run `/onboard` to walk through initial setup
5. Start a Claude Code session — CLAUDE.md loads automatically
