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

## What's Included

- **17 skills** -- reusable, structured capabilities invoked with `/skill-name`
- **170+ specialized agents** -- subagents across engineering, design, marketing, sales, game dev, project management, and more
- **State management** -- behavioral rules, integrations, entities, patterns, memory, sessions, feedback, and a glossary
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
| `/note` | `/note`, "create a note" | Creates a timestamped note in your inbox and opens it for editing. |
| `/process-inbox` | "process my inbox" | Transforms rough inbox captures into structured notes and tasks. |
| `/project` | "create a project" | Creates new project files and folders with proper structure. |
| `/project-load` | "load project X" | Loads context for an existing project, lists projects, or files content into one. |
| `/calendar-booking` | "book a meeting", "when am I free" | Checks availability and creates calendar events with natural time formatting. |
| `/meeting` | "create meeting note" | Creates structured meeting notes with attendees, agenda, and action items. |

## Agents

CrystalAI includes 170+ specialized agents across engineering, design, marketing, sales, game development, spatial computing, project management, and more. Claude automatically selects the right agent for a task, or you can request one directly: "use the code reviewer agent to review this PR."

See [agents/README.md](agents/README.md) for the full catalog and instructions on adding your own.

## Customization

CrystalAI is a starting point, not a finished product. You are expected to make it yours.

- **Behavioral rules** -- Add files to `state/behavioral/` to define how Claude communicates, handles errors, formats output, or anything else. Schemas are in `state/_schemas/`.
- **Integrations** -- Add a directory to `state/integrations/` for each external service (calendar, task manager, email). Document connection details, API shapes, and gotchas.
- **Entities** -- Add files to `state/entities/` for people, companies, or organizations Claude should know about.
- **Patterns** -- Add files to `state/patterns/` for reusable execution references (scripts, workflows, command sequences).
- **Skills** -- Use `/skill-creator` to build new skills. Never write SKILL.md files by hand.
- **Agents** -- Add markdown files to `agents/` with frontmatter and a system prompt. See [agents/README.md](agents/README.md).

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
