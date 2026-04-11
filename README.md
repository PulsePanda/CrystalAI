# CrystalAI -- A Claude Code Starter Framework

A working `~/.claude/` structure that turns Claude Code from a chatbot into a personal AI operating system.

## What This Is

CrystalAI is a framework that gives Claude Code skills, agents, state management, and memory out of the box. It provides the scaffolding that makes Claude Code remember your preferences, follow your rules, and execute complex workflows consistently across sessions. Clone it, run `/onboarding`, and Claude Code becomes dramatically more useful. Works for developers, business owners, IT admins, artists -- anyone who uses Claude Code.

## Quick Start

```bash
# Back up any existing ~/.claude/ content first
mv ~/.claude ~/.claude-backup  # skip if ~/.claude/ doesn't exist

git clone https://github.com/PulsePanda/CrystalAI.git ~/.claude
```

Then open Claude Code and run:

```
/onboarding
```

The onboarding wizard detects your environment, interviews you about your preferences, generates config files, and walks you through creating your first skill.

## Architecture: Core and Personal Layers

CrystalAI separates cleanly into two layers:

- **Core layer** -- Skills, agents, scripts, commands, and framework docs shipped by CrystalAI. Updated by the maintainer. Users don't edit these directly.
- **Personal layer** -- Memory, behavioral rules, entities, integrations, session history, custom skills, and skill configs. Owned by the user. Never overwritten by updates.

This means updates are safe: `git pull` brings new features and fixes without touching your customizations. Core skills that need per-user settings (like which calendars to check) read from config files in `skill-configs/` -- the skill logic updates, your config stays.

See [docs/core-personal-boundary.md](docs/core-personal-boundary.md) for the full path-to-layer mapping.

## What's Included

- **22 core skills** -- reusable, structured capabilities invoked with `/skill-name`
- **170+ specialized agents** -- subagents across engineering, design, marketing, sales, game dev, project management, and more
- **3 vault maintenance agents** -- vault-librarian, cross-linker, people-profiler
- **Lifecycle hooks** -- SessionStart, PreCompact, PostToolUse, UserPromptSubmit, Stop
- **State management** -- behavioral rules, integrations, entities, patterns, memory, sessions, feedback, and a glossary
- **Upgrade system** -- `/crystalai-upgrade` diffs, backs up, and applies updates with AI-assisted merges
- **People schema** -- first-class person files in your vault, auto-maintained by skills
- **Skill configs** -- per-user customization of core skills via YAML config files
- **Onboarding wizard** -- configures everything through a guided conversation
- **Architecture docs and schemas** -- templates for every state category so the framework grows cleanly

## The Session Lifecycle

CrystalAI is built around a three-phase loop:

1. **Resume** (`/resume`) -- At the start of a session, loads your last session log, today's calendar and tasks, and active project context. You pick up where you left off.
2. **Work** -- You do your thing. Skills, agents, and behavioral rules work in the background to keep Claude consistent and useful.
3. **Compress** (`/compress`) -- At the end of a session, saves a searchable session log, extracts pending tasks, updates your daily note, and runs a hygiene pass. Nothing is lost.

## Skills Reference

| Skill | Trigger | What It Does |
|-------|---------|--------------|
| `/onboarding` | `/onboard` | First-run setup wizard. Detects environment, interviews you, generates config. |
| `/resume` | `/resume`, "what was I working on" | Restores context from last session, loads today's tasks and calendar. |
| `/compress` | `/compress`, "wrap up" | Saves session log, extracts tasks, updates daily note, runs hygiene. |
| `/auto-fix` | Automatic on error | Diagnoses failed operations, applies known fixes, retries, documents new errors. |
| `/feedback` | User corrects behavior | Logs corrections permanently so you never repeat yourself. |
| `/docs` | `/docs`, "update documentation" | Scans session context and updates project files, skills, memory, and rules. |
| `/weekly` | `/weekly`, "weekly review" | Synthesizes the week into permanent memory, consolidates state, surfaces commitments. |
| `/deep-research` | "deep research", "comprehensive analysis" | Multi-source research with citation tracking, verification, and report generation. |
| `/write` | `/write`, "draft an email" | Drafts content in your personal writing style. Learns from corrections. |
| `/teach` | `/teach`, "learn from this email" | Analyzes your writing samples to extract patterns and update your style guide. |
| `/grill-me` | "grill me", "stress-test my plan" | Interrogates your plan or design until every assumption is tested. |
| `/brainstorm` | "let's brainstorm", "explore options" | Structured brainstorming: diverge, cluster, converge, decide, capture. |
| `/dispatch` | "dispatch this", "build me X" | Multi-agent autonomous task execution with planning, judging, and quality loops. |
| `/note` | `/note`, "create a note" | Creates a timestamped note in your inbox and opens it for editing. |
| `/process-inbox` | "process my inbox" | Transforms rough inbox captures into structured notes and tasks. |
| `/project` | "create a project" | Creates new project files and folders with proper structure. |
| `/project-load` | "load project X" | Loads context for an existing project, lists projects, or files content into one. |
| `/project-archive` | "archive the X project" | Moves completed projects to Archive/YYYY/ and updates frontmatter. |
| `/calendar-booking` | "book a meeting", "when am I free" | Checks availability and creates calendar events with natural time formatting. |
| `/meeting` | "create meeting note" | Creates structured meeting notes with attendees, agenda, and action items. |
| `/install` | "install this skill" | Installs skills and agents from files, archives, or GitHub URLs. |
| `/core-skill-creator` | "create a core skill" | Grill-me + skill-creator wrapper ensuring core skill quality standards. |

## Skill Customization

Core skills ship with sensible defaults but can be customized per user via config files:

```bash
# Copy an example config and customize
cp docs/skill-configs-examples/resume.yaml ~/.claude/skill-configs/resume.yaml
```

Config files support skill-specific settings and `post_steps` to chain additional skills. See [docs/skill-configs.md](docs/skill-configs.md).

## Agents

CrystalAI includes 170+ specialized agents across engineering, design, marketing, sales, game development, spatial computing, project management, and more. Claude automatically selects the right agent for a task, or you can request one directly: "use the code reviewer agent to review this PR."

See [agents/README.md](agents/README.md) for the full catalog and instructions on adding your own.

## Vault Maintenance Agents

Three agents keep your vault healthy:

- **vault-librarian** -- finds orphan notes, stale frontmatter, broken links, and misplaced files
- **cross-linker** -- detects unlinked mentions and suggests wikilinks
- **people-profiler** -- scans sessions and meetings to create and update person files

## Updating

```bash
cd ~/.claude
/crystalai-upgrade
```

The upgrade system diffs the repo against your installation, backs up everything, applies core updates, and walks you through merging customized files (settings.json, CLAUDE.md). Your personal data is never touched.

## Customization

CrystalAI is a starting point, not a finished product. You are expected to make it yours.

- **Behavioral rules** -- Add files to `state/behavioral/` to define how Claude communicates, handles errors, formats output, or anything else. Schemas are in `state/_schemas/`.
- **Integrations** -- Add a directory to `state/integrations/` for each external service (calendar, task manager, email). Document connection details, API shapes, and gotchas.
- **Entities** -- Add files to `state/entities/` for people, companies, or organizations Claude should know about.
- **Patterns** -- Add files to `state/patterns/` for reusable execution references (scripts, workflows, command sequences).
- **Skills** -- Use `/skill-creator` to build new skills. Use `/core-skill-creator` for skills intended for the core framework.
- **Agents** -- Add markdown files to `agents/` with frontmatter and a system prompt. See [agents/README.md](agents/README.md).
- **Skill configs** -- Customize core skill behavior via YAML files in `skill-configs/`. See [docs/skill-configs.md](docs/skill-configs.md).

## Plugin System

Domain-specific functionality can be layered on top of CrystalAI as plugins. A plugin is a separate git repo with its own skills, state, and CLAUDE.md, namespaced to avoid collisions with the base layer.

For example, a business operations plugin might namespace its skills as `biz:invoice`, `biz:timesheet`, etc. Plugins are listed in your `CLAUDE.md` under the `# Plugins` section so Claude loads them automatically.

See `ARCHITECTURE.md` for the full plugin specification.

## Requirements

- **Claude Code** (required)
- **macOS, Windows, or Linux**
- **Git** (to clone the repo)
- **Obsidian** (optional -- for note-taking integration via `/note`, `/process-inbox`, `/project`)
- **A task manager** (optional -- for task extraction in `/compress` and `/resume`)

## License

MIT
